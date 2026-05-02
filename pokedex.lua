local elements = require("utils.core.elements")
local store = require("utils.core.store")
local TextInput = require("utils.core.textInput")

-- ==========================================
-- 1. GLOBAL STATE STORE
-- ==========================================
local usePokeStore = store.create(function(get, set)
	return {
		poke_id = 1,
		poke_data = "",
		is_loading = false,
		search_query = "",

		setSearchQuery = function(text)
			set({ search_query = text })
		end,

		fetchPokemon = function(query)
			set({ is_loading = true })

			-- PokeAPI requires names to be lowercase
			if type(query) == "string" then
				query = query:lower()
			end

			local url = "https://pokeapi.co/api/v2/pokemon/" .. tostring(query)

			-- ==========================================
			-- USING THE NEW VULPIS.FETCH API
			-- ==========================================
			vulpis.fetch(url, {
				method = "GET",
				timeout = 8000, -- 8 second timeout so the UI doesn't hang on bad internet
			}, function(res)
				if res.status == 200 then
					-- Extract the numeric ID from the response so the NEXT/PREV buttons
					-- stay perfectly synced even if we searched by name!
					local parsedId = res.body:match('"id":(%d+)')
					local newId = parsedId and tonumber(parsedId) or get().poke_id

					set({
						poke_data = res.body,
						is_loading = false,
						poke_id = newId, -- Sync the ID
						search_query = "", -- Clear the search bar on success
					})
				else
					set({ poke_data = "", is_loading = false })
				end
			end)
		end,
	}
end)

-- Fetch the first Pokémon instantly on script load
local init_state = usePokeStore()
if init_state.poke_data == "" and not init_state.is_loading then
	init_state.fetchPokemon(1)
end

-- ==========================================
-- 2. WINDOW CONFIGURATION
-- ==========================================
function Window()
	return {
		title = "Vulpis Pokédex",
		w = 450,
		h = 800,
		mode = "windowed",
		resizable = false,
	}
end

-- ==========================================
-- 3. MAIN APPLICATION VIEW
-- ==========================================
function App()
	local state = usePokeStore()
	local rawData = state.poke_data

	-- Extracted Data Variables
	local name = state.is_loading and "Loading..." or "Not Found"
	local spriteUrl = ""
	local typeName = "???"
	local pHeight = "??"
	local pWeight = "??"

	-- Ultra-fast Regex Parsing (Bypasses Lua JSON depth limits)
	if not state.is_loading and rawData ~= "" then
		local parsedName = rawData:match('"species":{"name":"([^"]+)"')
		if parsedName then
			name = parsedName:sub(1, 1):upper() .. parsedName:sub(2)
		end

		local parsedSprite = rawData:match('"front_default":"([^"]+)"')
		if parsedSprite then
			spriteUrl = parsedSprite
		end

		local parsedType = rawData:match('"type":{"name":"([^"]+)"')
		if parsedType then
			typeName = parsedType:sub(1, 1):upper() .. parsedType:sub(2)
		end

		local h = rawData:match('"height":(%d+)')
		if h then
			pHeight = tostring(tonumber(h) / 10) .. "m"
		end

		local w = rawData:match('"weight":(%d+)')
		if w then
			pWeight = tostring(tonumber(w) / 10) .. "kg"
		end
	end

	-- Return the Virtual DOM Tree
	return elements.VBox({
		style = {
			w = "100%",
			h = "100%",
			BGColor = "#DC0A2D",
			padding = 20,
			alignItems = "center",
			gap = 15,
		},
		children = {
			-- TOP LED SENSORS
			elements.HBox({
				style = { w = "100%", alignItems = "start", gap = 15, marginBottom = 5 },
				children = {
					elements.VBox({
						style = {
							w = 70,
							h = 70,
							BGColor = "#28AAFD",
							borderRadius = 35,
							borderWidth = 4,
							borderColor = "#FFFFFF",
						},
					}),
					elements.HBox({
						style = { gap = 8, marginTop = 5 },
						children = {
							elements.VBox({
								style = {
									w = 16,
									h = 16,
									BGColor = "#FF0000",
									borderRadius = 8,
									borderWidth = 1,
									borderColor = "#550000",
								},
							}),
							elements.VBox({
								style = {
									w = 16,
									h = 16,
									BGColor = "#FFCC00",
									borderRadius = 8,
									borderWidth = 1,
									borderColor = "#555500",
								},
							}),
							elements.VBox({
								style = {
									w = 16,
									h = 16,
									BGColor = "#32CD32",
									borderRadius = 8,
									borderWidth = 1,
									borderColor = "#005500",
								},
							}),
						},
					}),
				},
			}),

			-- SEARCH BAR
			elements.HBox({
				style = { w = 340, justifyContent = "space-between", gap = 10 },
				children = {
					TextInput({
						value = state.search_query,
						placeholder = "Search name or ID...",
						onChange = function(text)
							state.setSearchQuery(text)
						end,
						onSubmit = function()
							if state.search_query ~= "" and not state.is_loading then
								state.fetchPokemon(state.search_query)
							end
						end,
						style = {
							w = 260,
							h = 40,
							BGColor = "#FFFFFF",
							color = "#111111",
							borderRadius = 5,
							paddingLeft = 10,
							fontSize = 16,
							borderWidth = 3,
							borderColor = "#333333",
						},
					}),
					elements.Button({
						text = "GO",
						style = {
							w = 70,
							h = 40,
							BGColor = "#51AD60",
							color = "#111111",
							borderRadius = 5,
							borderWidth = 3,
							borderColor = "#333333",
							fontWeight = "bold",
							fontSize = 16,
							alignItems = "center",
							justifyContent = "center",
						},
						onClick = function()
							if state.search_query ~= "" and not state.is_loading then
								state.fetchPokemon(state.search_query)
							end
						end,
					}),
				},
			}),

			-- MAIN DISPLAY BEZEL
			elements.VBox({
				style = {
					w = 340,
					h = 320,
					BGColor = "#DEDEDE",
					borderRadius = 15,
					padding = 15,
					alignItems = "center",
					borderWidth = 3,
					borderColor = "#333333",
				},
				children = {
					elements.HBox({
						style = { gap = 30, marginBottom = 10 },
						children = {
							elements.VBox({ style = { w = 8, h = 8, BGColor = "#DC0A2D", borderRadius = 4 } }),
							elements.VBox({ style = { w = 8, h = 8, BGColor = "#DC0A2D", borderRadius = 4 } }),
						},
					}),

					-- Actual Black Screen
					elements.VBox({
						style = {
							w = 270,
							h = 210,
							BGColor = "#232323",
							borderRadius = 10,
							alignItems = "center",
							justifyContent = "center",
						},
						children = {
							spriteUrl ~= "" and elements.Image({
								src = spriteUrl,
								style = { w = 190, h = 190, fit = "contain" },
							}) or elements.Text({
								text = state.is_loading and "..." or "?",
								style = { fontSize = 60, color = "#FFFFFF" },
							}),
						},
					}),

					elements.HBox({
						style = {
							w = "100%",
							justifyContent = "space-between",
							marginTop = 15,
							paddingLeft = 25,
							paddingRight = 25,
						},
						children = {
							elements.VBox({
								style = {
									w = 18,
									h = 18,
									BGColor = "#DC0A2D",
									borderRadius = 9,
									borderWidth = 1,
									borderColor = "#333333",
								},
							}),
							elements.VBox({
								style = { gap = 4 },
								children = {
									elements.VBox({ style = { w = 30, h = 3, BGColor = "#333333" } }),
									elements.VBox({ style = { w = 30, h = 3, BGColor = "#333333" } }),
									elements.VBox({ style = { w = 30, h = 3, BGColor = "#333333" } }),
								},
							}),
						},
					}),
				},
			}),

			-- RETRO GREEN INFO PANEL
			elements.VBox({
				style = {
					w = 340,
					BGColor = "#51AD60",
					borderRadius = 8,
					padding = 15,
					borderWidth = 4,
					borderColor = "#333333",
					gap = 8,
				},
				children = {
					elements.HBox({
						style = { w = "100%", justifyContent = "space-between" },
						children = {
							elements.Text({
								text = name,
								style = { fontSize = 28, fontWeight = "bold", color = "#111111" },
							}),
							elements.Text({
								text = string.format("#%03d", state.poke_id),
								style = { fontSize = 24, fontWeight = "bold", color = "#111111" },
							}),
						},
					}),
					elements.VBox({
						style = { w = "100%", h = 2, BGColor = "#3B8146", marginTop = 2, marginBottom = 2 },
					}),
					elements.HBox({
						style = { w = "100%", justifyContent = "space-between" },
						children = {
							elements.Text({
								text = "TYPE: " .. typeName,
								style = { fontSize = 16, color = "#222222", fontWeight = "bold" },
							}),
							elements.Text({
								text = "HT: " .. pHeight,
								style = { fontSize = 16, color = "#222222", fontWeight = "bold" },
							}),
							elements.Text({
								text = "WT: " .. pWeight,
								style = { fontSize = 16, color = "#222222", fontWeight = "bold" },
							}),
						},
					}),
				},
			}),

			-- HARDWARE NAVIGATION BUTTONS
			elements.HBox({
				style = { w = 340, justifyContent = "space-between", marginTop = 5 },
				children = {
					elements.Button({
						text = "< PREV",
						style = {
							BGColor = "#FFCC00",
							paddingTop = 15,
							paddingBottom = 15,
							paddingLeft = 30,
							paddingRight = 30,
							borderRadius = 8,
							borderWidth = 3,
							borderColor = "#333333",
							color = "#111111",
							fontWeight = "bold",
							fontSize = 18,
						},
						onClick = function()
							if state.poke_id > 1 and not state.is_loading then
								state.fetchPokemon(state.poke_id - 1)
							end
						end,
					}),
					elements.Button({
						text = "NEXT >",
						style = {
							BGColor = "#28AAFD",
							paddingTop = 15,
							paddingBottom = 15,
							paddingLeft = 30,
							paddingRight = 30,
							borderRadius = 8,
							borderWidth = 3,
							borderColor = "#333333",
							color = "#111111",
							fontWeight = "bold",
							fontSize = 18,
						},
						onClick = function()
							if not state.is_loading then
								state.fetchPokemon(state.poke_id + 1)
							end
						end,
					}),
				},
			}),
		},
	})
end
