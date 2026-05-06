local elements = require("utils.core.elements")
local store = require("utils.core.store")
local TextInput = require("utils.core.textInput")
local json = require("utils.core.json")

-------------------------------------------------------------------------------
-- 1. GEMINI API CLIENT (Multi-Turn)
-------------------------------------------------------------------------------
local Gemini = {}
Gemini.__index = Gemini

function Gemini.new(apiKey)
	local cleanKey = ""
	if type(apiKey) == "string" then
		cleanKey = apiKey:match("^%s*(.-)%s*$")
	end

	return setmetatable({
		apiKey = cleanKey,
		baseUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent",
	}, Gemini)
end

function Gemini:chat(messages, callback)
	if type(self.apiKey) ~= "string" or self.apiKey == "" or self.apiKey == "YOUR_ACTUAL_API_KEY_HERE" then
		callback(nil, "System Error: Please put your real Gemini API key in the code!")
		return
	end

	local url = self.baseUrl .. "?key=" .. self.apiKey

	-- Format the conversation history for Gemini
	local apiContents = {}
	for _, msg in ipairs(messages) do
		table.insert(apiContents, {
			role = msg.role,
			parts = { { text = msg.text } },
		})
	end

	local requestBody = {
		system_instruction = {
			parts = {
				{
					text = "You are a helpful assistant. You must provide all of your answers in plain, raw text. Absolutely do not use any Markdown formatting, bolding, asterisks, bullet points, or code blocks",
				},
			},
		},
		contents = apiContents,
	}

	local okEncode, payload = pcall(json.encode, requestBody)

	if not okEncode then
		callback(nil, "System Error: Failed to build JSON payload.")
		return
	end

	vulpis.fetch(url, {
		method = "POST",
		body = payload,
		headers = { ["Content-Type"] = "application/json" },
		timeout = 60000,
	}, function(res)
		if not res then
			callback(nil, "Network Error: Failed to receive response.")
			return
		end

		local bodyText = res.body or ""
		local okDecode, data = pcall(json.decode, bodyText)
		local isDataTable = okDecode and type(data) == "table"

		if res.status == 200 and isDataTable and data.candidates and data.candidates[1] then
			local resultText = data.candidates[1].content.parts[1].text
			if resultText then
				callback(resultText, nil)
			else
				callback(nil, "API Error: Malformed success response.")
			end
		else
			local errorMessage = "HTTP Error: " .. tostring(res.status)
			if isDataTable and data.error and data.error.message then
				errorMessage = "Google API Error (" .. tostring(res.status) .. "): " .. tostring(data.error.message)
			end
			callback(nil, errorMessage)
		end
	end)
end

-------------------------------------------------------------------------------
-- 2. STATE MANAGEMENT
-------------------------------------------------------------------------------
local client = Gemini.new("YOUR_ACTUAL_API_KEY_HERE")

local useAppStore = store.create(function(get, set)
	return {
		userInput = "",
		messages = {}, -- Array to hold { role = "user" | "model", text = "..." }
		isLoading = false,
		errorMsg = nil,

		setUserInput = function(val)
			set({ userInput = val })
		end,

		addMessage = function(role, text)
			local currentMsgs = get().messages
			local newMsgs = {}
			-- Deep copy existing messages
			for _, m in ipairs(currentMsgs) do
				table.insert(newMsgs, m)
			end
			table.insert(newMsgs, { role = role, text = text })
			set({ messages = newMsgs })
		end,

		setLoading = function(loading)
			set({ isLoading = loading })
		end,

		setError = function(err)
			set({ errorMsg = err, isLoading = false })
		end,

		clearError = function()
			set({ errorMsg = nil })
		end,
	}
end)

local function submitPrompt(state, overrideText)
	local textToSubmit = overrideText or state.userInput
	local cleanInput = textToSubmit:match("^%s*(.-)%s*$") or ""

	if not state.isLoading and cleanInput ~= "" then
		state.clearError()
		state.addMessage("user", cleanInput)
		state.setUserInput("") -- Clear input box instantly
		state.setLoading(true)

		-- Build the history payload to send to the API
		local apiHistory = {}
		for _, m in ipairs(state.messages) do
			table.insert(apiHistory, m)
		end
		-- Removed the duplicate table.insert here

		client:chat(apiHistory, function(response, err)
			if err then
				state.setError(err)
			else
				state.addMessage("model", response)
				state.setLoading(false)
			end
		end)
	end
end
-------------------------------------------------------------------------------
-- 3. UI RENDERER
-------------------------------------------------------------------------------
function App()
	local state = useAppStore()

	-- Clean, Minimal Dark Theme
	local colors = {
		bg_main = "#0d1117",
		bg_card = "#161b22",
		bg_response = "#21262d",
		primary = "#2f81f7",
		primary_text = "#ffffff",
		accent = "#58a6ff",
		text_main = "#e6edf3",
		text_muted = "#8b949e",
		error_bg = "#3a1d1d",
		error_text = "#ff7b72",
		input_bg = "#0d1117",
		border_subtle = "#30363d",
	}

	local hasConversation = (#state.messages > 0) or state.isLoading
	local appWindowChildren = {}

	-- App Header (Fixed at top)
	table.insert(
		appWindowChildren,
		elements.HBox({
			style = {
				w = "100%",
				padding = 16,
				alignItems = "center",
				justifyContent = "center",
				BGColor = colors.bg_card,
				borderWidth = 1,
				borderColor = colors.border_subtle,
				flexShrink = 0,
				zIndex = 5,
			},
			children = {
				elements.Text({
					text = "Gemini",
					style = { fontSize = 16, color = colors.text_main, fontWeight = "bold" },
				}),
			},
		})
	)

	-- Dynamic Content Area
	local scrollAreaChildren = {}

	if not hasConversation then
		table.insert(
			scrollAreaChildren,
			elements.VBox({
				style = {
					w = "100%",
					flexGrow = 1,
					justifyContent = "center",
					alignItems = "center",
					gap = 24,
					marginTop = 60,
				},
				children = {
					elements.Text({
						text = "How can I help you today?",
						style = {
							fontSize = 32,
							color = colors.text_main,
							fontWeight = "bold",
							textAlign = "center",
						},
					}),
					-- Suggestion Chips
					elements.HBox({
						style = { gap = 12, justifyContent = "center", flexWrap = "wrap" },
						children = {
							elements.Button({
								text = "Explain browser compositing",
								onClick = function()
									submitPrompt(state, "Explain browser compositing")
								end,
								style = {
									padding = 12,
									borderRadius = 8,
									BGColor = colors.bg_response,
									color = colors.text_main,
									fontSize = 13,
									borderWidth = 1,
									borderColor = colors.border_subtle,
								},
							}),
							elements.Button({
								text = "High-protein recipes",
								onClick = function()
									submitPrompt(state, "High-protein recipes with no saturated fats")
								end,
								style = {
									padding = 12,
									borderRadius = 8,
									BGColor = colors.bg_response,
									color = colors.text_main,
									fontSize = 13,
									borderWidth = 1,
									borderColor = colors.border_subtle,
								},
							}),
						},
					}),
				},
			})
		)
	else
		for i, msg in ipairs(state.messages) do
			if msg.role == "user" then
				table.insert(
					scrollAreaChildren,
					elements.HBox({
						key = "user_msg_row_" .. i,
						style = { w = "100%", justifyContent = "end", marginBottom = 20 },
						children = {
							elements.VBox({
								style = { BGColor = colors.primary, padding = 16, borderRadius = 12, maxWidth = 550 },
								children = {
									elements.Text({
										id = "user_msg_" .. i,
										key = "user_msg_" .. i,
										text = msg.text,
										allowSelection = true,
										style = { color = colors.primary_text, fontSize = 15, wordWrap = true },
									}),
								},
							}),
						},
					})
				)
			elseif msg.role == "model" then
				table.insert(
					scrollAreaChildren,
					elements.HBox({
						key = "ai_msg_row_" .. i,
						style = { w = "100%", justifyContent = "start", marginBottom = 20 },
						children = {
							elements.VBox({
								style = {
									BGColor = colors.bg_response,
									padding = 16,
									borderRadius = 12,
									borderWidth = 1,
									borderColor = colors.border_subtle,
									maxWidth = 650,
								},
								children = {
									elements.Text({
										id = "ai_msg_" .. i,
										key = "ai_msg_" .. i,
										text = msg.text,
										allowSelection = true,
										style = {
											color = colors.text_main,
											fontSize = 15,
											wordWrap = true,
											lineHeight = 1.4,
										},
									}),
								},
							}),
						},
					})
				)
			end
		end

		-- Loading Indicator
		if state.isLoading then
			table.insert(
				scrollAreaChildren,
				elements.HBox({
					style = { w = "100%", justifyContent = "start", marginBottom = 20 },
					children = {
						elements.Text({
							text = "Generating response...",
							style = { color = colors.text_muted, fontSize = 14, fontStyle = "italics" },
						}),
					},
				})
			)
		end

		-- Error Indicator
		if state.errorMsg then
			table.insert(
				scrollAreaChildren,
				elements.HBox({
					style = { w = "100%", justifyContent = "center", marginBottom = 20 },
					children = {
						elements.VBox({
							style = {
								BGColor = colors.error_bg,
								padding = 12,
								borderRadius = 8,
								borderWidth = 1,
								borderColor = colors.error_text,
								maxWidth = 600,
							},
							children = {
								elements.Text({
									text = state.errorMsg,
									allowSelection = true,
									style = {
										color = colors.error_text,
										fontSize = 14,
										wordWrap = true,
										textAlign = "center",
									},
								}),
							},
						}),
					},
				})
			)
		end
	end

	-- Scroll Area
	table.insert(
		appWindowChildren,
		elements.VBox({
			style = {
				flexGrow = 1,
				flexShrink = 1,
				w = "100%",
				padding = 24,
				paddingBottom = 100,
				overflow = "auto",
				autoScroll = "bottom",
				BGColor = colors.bg_main,
			},
			children = scrollAreaChildren,
		})
	)

	-- [FLOATING INPUT AREA]
	table.insert(
		appWindowChildren,
		elements.VBox({
			style = {
				position = "absolute",
				bottom = 24,
				w = "100%",
				paddingLeft = 24,
				paddingRight = 24,
				zIndex = 10,
			},
			children = {
				elements.HBox({
					style = {
						w = "100%",
						gap = 12,
						alignItems = "center",
						BGColor = colors.input_bg,
						padding = 8,
						borderRadius = 24,
						borderWidth = 1,
						borderColor = colors.border_subtle,
					},
					children = {
						TextInput({
							id = "gemini_input_modern",
							value = state.userInput,
							placeholder = "Message Gemini...",
							onChange = state.setUserInput,
							onSubmit = function()
								submitPrompt(state)
							end,
							style = {
								flexGrow = 1,
								h = 40,
								BGColor = colors.input_bg,
								color = colors.text_main,
								fontSize = 15,
								borderRadius = 20,
								paddingLeft = 16,
								paddingRight = 10,
							},
						}),
						elements.Button({
							text = state.isLoading and "..." or ">",
							onClick = function()
								submitPrompt(state)
							end,
							style = {
								h = 40,
								w = 40,
								color = colors.primary_text,
								borderRadius = 20,
								BGColor = state.userInput:match("^%s*$") and colors.border_subtle or colors.primary,
								justifyContent = "center",
								alignItems = "center",
								fontWeight = "bold",
								fontSize = 18,
							},
						}),
					},
				}),
			},
		})
	)

	-- Main App Wrapper
	return elements.VBox({
		style = { w = "100%", h = "100%", alignItems = "center", BGColor = colors.bg_main },
		children = {
			elements.VBox({
				style = {
					w = "100%",
					maxWidth = 900,
					h = "100%",
					BGColor = colors.bg_main,
					overflow = "hidden",
					position = "relative",
				},
				children = appWindowChildren,
			}),
		},
	})
end
