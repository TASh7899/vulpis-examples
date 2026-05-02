-- needs a websocket chat server in node.js

local elements = require("utils.core.elements")
local store = require("utils.core.store")
local TextInput = require("utils.core.textInput")
local ws = require("utils.core.ws")
local json = require("utils.core.json")

math.randomseed(os.time())
local MY_USERNAME = "Vulpis_" .. tostring(math.random(1000, 9999))

local useChatStore = store.create(function(get, set)
	return {
		status = "Disconnected",
		messages = {},
		input_text = "",
		socket = nil,

		setInputText = function(text)
			set({ input_text = text })
		end,

		connect = function()
			set({ status = "Connecting to Localhost..." })

			local newSocket = ws.connect("ws://localhost:8080", function(event)
				if event.type == "open" then
					set({ status = "Connected as " .. MY_USERNAME })
				elseif event.type == "message" then
					local ok, incomingData = pcall(json.decode, event.data)

					if ok and incomingData.sender and incomingData.text then
						-- ==========================================
						-- FIX 1: Create a NEW table so VDOM detects the change!
						-- ==========================================
						local newMessages = {}
						for _, msg in ipairs(get().messages) do
							table.insert(newMessages, msg)
						end

						-- Add the new message
						table.insert(newMessages, {
							sender = incomingData.sender,
							text = incomingData.text,
						})

						-- Set the state with the NEW table
						set({ messages = newMessages })
					end
				elseif event.type == "error" or event.type == "close" then
					set({ status = "Disconnected", socket = nil })
				end
			end)

			set({ socket = newSocket })
		end,

		sendMessage = function()
			local state = get()
			if state.socket and state.input_text ~= "" then
				local payload = {
					sender = MY_USERNAME,
					text = state.input_text,
				}

				state.socket:send(payload)

				-- ==========================================
				-- FIX 2: Create a NEW table for outgoing messages too!
				-- ==========================================
				local newMessages = {}
				for _, msg in ipairs(state.messages) do
					table.insert(newMessages, msg)
				end

				table.insert(newMessages, { sender = "Me", text = state.input_text })

				set({ messages = newMessages, input_text = "" })
			end
		end,
	}
end)

-- Automatically connect when the app starts
local init_state = useChatStore()
if init_state.status == "Disconnected" and not init_state.socket then
	init_state.connect()
end

-- ==========================================
-- 2. WINDOW CONFIGURATION
-- ==========================================
function Window()
	return {
		title = "Vulpis Chat - " .. MY_USERNAME,
		w = 450,
		h = 700,
		mode = "windowed",
		resizable = true,
	}
end

-- ==========================================
-- 3. MAIN APPLICATION VIEW
-- ==========================================
function App()
	local state = useChatStore()

	local statusColor = "#EF4444"
	if state.status:match("Connected") then
		statusColor = "#10B981"
	elseif state.status:match("Connecting") then
		statusColor = "#F59E0B"
	end

	local messageNodes = {}
	for i, msg in ipairs(state.messages) do
		local isMe = msg.sender == "Me"
		table.insert(
			messageNodes,
			elements.VBox({
				style = {
					w = "100%",
					alignItems = isMe and "end" or "start",
					marginBottom = 15,
				},
				children = {
					elements.Text({
						text = msg.sender,
						style = { fontSize = 12, color = "#A1A1AA", marginBottom = 4 },
					}),
					elements.VBox({
						style = {
							BGColor = isMe and "#3B82F6" or "#3F3F46",
							paddingTop = 10,
							paddingBottom = 10,
							paddingLeft = 15,
							paddingRight = 15,
							borderRadius = 12,
							maxWidth = 300,
						},
						children = {
							elements.Text({
								text = msg.text,
								style = { fontSize = 16, color = "#FFFFFF" },
							}),
						},
					}),
				},
			})
		)
	end

	return elements.VBox({
		style = {
			w = "100%",
			h = "100%",
			BGColor = "#18181B",
			padding = 20,
		},
		children = {
			elements.HBox({
				style = {
					w = "100%",
					h = 60,
					BGColor = "#27272A",
					borderRadius = 10,
					alignItems = "center",
					justifyContent = "space-between",
					paddingLeft = 20,
					paddingRight = 20,
					marginBottom = 20,
					flexShrink = 0,
				},
				children = {
					elements.Text({
						text = "Global Chat",
						style = { fontSize = 20, fontWeight = "bold", color = "#FFFFFF" },
					}),
					elements.HBox({
						style = { alignItems = "center", gap = 8 },
						children = {
							elements.VBox({ style = { w = 12, h = 12, borderRadius = 6, BGColor = statusColor } }),
							elements.Text({ text = state.status, style = { fontSize = 14, color = statusColor } }),
						},
					}),
				},
			}),

			elements.VBox({
				style = {
					w = "100%",
					flexGrow = 1,
					flexShrink = 1,
					BGColor = "#27272A",
					borderRadius = 10,
					padding = 15,
					overflow = "scroll",
					autoScroll = "bottom",
					marginBottom = 20,
				},
				children = messageNodes,
			}),

			elements.HBox({
				style = { w = "100%", h = 50, gap = 15, flexShrink = 0 },
				children = {
					TextInput({
						value = state.input_text,
						placeholder = "Type a message...",
						onChange = function(text)
							state.setInputText(text)
						end,
						onSubmit = function()
							state.sendMessage()
						end,
						style = {
							flexGrow = 1,
							h = "100%",
							BGColor = "#3F3F46",
							color = "#FFFFFF",
							borderRadius = 8,
							paddingLeft = 15,
							fontSize = 16,
							borderWidth = 2,
							borderColor = "#52525B",
						},
					}),
					elements.Button({
						text = "SEND",
						style = {
							w = 90,
							h = "100%",
							BGColor = "#10B981",
							color = "#FFFFFF",
							borderRadius = 8,
							fontWeight = "bold",
							fontSize = 16,
						},
						onClick = function()
							state.sendMessage()
						end,
					}),
				},
			}),
		},
	})
end
