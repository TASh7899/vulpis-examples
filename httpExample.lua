local elements = require("utils.core.elements")
local json = require("utils.core.json")

function Window()
	return { title = "Vulpis // SECURE DOSSIER", w = 900, h = 650, resizable = true }
end

-- A helper component to draw a clean "Data Row" (Label + Value)
local function DataRow(label, value)
	return elements.HBox({
		style = { w = "100%", justifyContent = "space-between", marginBottom = 12 },
		children = {
			elements.Text({ text = label, style = { color = "#A1A1AA", fontSize = 14 } }),
			elements.Text({ text = value, style = { color = "#FFFFFF", fontSize = 16 } }),
		},
	})
end

function App()
	-- 1. State Management (Defaults set to empty strings instead of nil)
	local isLoading = useState("is_loading", false)
	local fetchError = useState("fetch_error", "")
	local userDataStr = useState("user_data", "")

	-- 2. Decode the string back into a usable Lua table if it has data
	local userData = nil
	if userDataStr ~= "" then
		userData = json.decode(userDataStr)
	end

	-- The Fetch Logic
	local function fetchNewIdentity()
		if isLoading then
			return
		end

		setState("is_loading", true)
		setState("fetch_error", "")

		vulpis.httpGet("https://randomuser.me/api/", function(res)
			if res.status == 200 then
				local data = json.decode(res.body)
				if not data then
					setState("fetch_error", "JSON Parsing Failed! Check terminal.")
					setState("is_loading", false)
					return
				end

				local user = data.results[1]

				-- Format the data nicely into a table
				local formattedUser = {
					fullName = string.upper(user.name.first .. " " .. user.name.last),
					location = user.location.city .. ", " .. user.location.country,
					email = user.email,
					uuid = string.upper(string.sub(user.login.uuid, 1, 13)),
					username = "@" .. user.login.username,
					age = tostring(user.dob.age) .. " YRS",
				}

				-- 3. Encode the table into a standard String so C++ can save it safely!
				setState("user_data", json.encode(formattedUser))
			else
				local errMsg = (res.error and res.error ~= "") and res.error or "Unknown C++ Network Error"
				setState("fetch_error", "CONNECTION FAILED: " .. errMsg .. " (Status: " .. tostring(res.status) .. ")")
			end
			setState("is_loading", false)
		end)
	end

	-- Auto-fetch an identity on the very first render
	local hasInit = useState("has_init", false)
	if not hasInit then
		setState("has_init", true)
		fetchNewIdentity()
	end

	-- ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
	-- ╏ BUILD THE UI                                ╏
	-- ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛

	local cardContent = {}

	-- 4. Check against empty strings instead of nil
	if isLoading and not userData then
		-- Initial Loading State
		table.insert(
			cardContent,
			elements.Text({ text = "ESTABLISHING SECURE CONNECTION...", style = { color = "#06B6D4", fontSize = 18 } })
		)
	elseif fetchError ~= "" then
		-- Error State
		table.insert(cardContent, elements.Text({ text = fetchError, style = { color = "#EF4444", fontSize = 18 } }))
	elseif userData then
		-- The Aesthetic Dossier Card
		table.insert(
			cardContent,
			elements.VBox({
				style = { w = "100%" },
				children = {
					-- Header Section
					elements.HBox({
						style = {
							w = "100%",
							justifyContent = "space-between",
							alignItems = "center",
							marginBottom = 30,
							borderBottomWidth = 1,
							borderColor = "#333333",
							paddingBottom = 15,
						},
						children = {
							elements.Text({ text = "TARGET ACQUIRED", style = { color = "#06B6D4", fontSize = 14 } }),
							elements.Text({
								text = "ID: " .. userData.uuid,
								style = { color = "#52525B", fontSize = 14 },
							}),
						},
					}),

					-- Identity Name
					elements.Text({
						text = userData.fullName,
						style = { color = "#FFFFFF", fontSize = 36, marginBottom = 5 },
					}),
					elements.Text({
						text = userData.username,
						style = { color = "#3B82F6", fontSize = 16, marginBottom = 30 },
					}),

					-- Data Grid
					elements.VBox({
						style = {
							w = "100%",
							BGColor = "#121214",
							padding = 20,
							borderRadius = 8,
							borderWidth = 1,
							borderColor = "#27272A",
							marginBottom = 40,
						},
						children = {
							DataRow("CURRENT LOCATION", userData.location),
							DataRow("COMMUNICATIONS", userData.email),
							DataRow("LIFESPAN", userData.age),
						},
					}),
				},
			})
		)
	end

	return elements.VBox({
		style = { w = "100%", h = "100%", BGColor = "#09090B", alignItems = "center", justifyContent = "center" },
		children = {
			-- Main Floating Card
			elements.VBox({
				style = {
					w = 500,
					BGColor = "#18181B",
					padding = 40,
					borderRadius = 16,
					borderWidth = 1,
					borderColor = "#3F3F46",
				},
				children = {
					elements.VBox({
						style = { w = "100%", minHeight = 250, justifyContent = "center", alignItems = "center" },
						children = cardContent,
					}),

					-- Action Button
					elements.Button({
						style = {
							w = "100%",
							padding = 15,
							BGColor = isLoading and "#27272A" or "#FFFFFF",
							borderRadius = 8,
							alignItems = "center",
							justifyContent = "center",
							marginTop = 20,
						},
						onClick = fetchNewIdentity,
						children = {
							elements.Text({
								text = isLoading and "DECRYPTING..." or "FETCH NEW TARGET",
								style = { color = isLoading and "#A1A1AA" or "#000000", fontSize = 16 },
							}),
						},
					}),
				},
			}),
		},
	})
end

return App()
