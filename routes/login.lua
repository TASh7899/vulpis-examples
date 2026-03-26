local elements = require("utils.core.elements")
local router = require("utils.core.router")

local function LoginScreen()
	local isAuthenticating = useState("is_auth", false)

	local function handleLogin()
		if isAuthenticating then
			return
		end
		setState("is_auth", true)

		-- Fake a 1-second network delay to show the loading state, then switch screens!
		vulpis.httpGet("https://httpbin.org/delay/1", function(res)
			setState("is_auth", false)
			router.push("/dossier")
		end)
	end

	return elements.VBox({
		style = { w = "100%", h = "100%", BGColor = "#09090B", alignItems = "center", justifyContent = "center" },
		children = {
			elements.VBox({
				style = {
					w = 350,
					padding = 30,
					BGColor = "#18181B",
					borderRadius = 12,
					borderWidth = 1,
					borderColor = "#27272A",
				},
				children = {
					elements.Text({
						text = "SYSTEM LOGIN",
						style = { color = "#FFFFFF", fontSize = 24, marginBottom = 20 },
					}),

					elements.Button({
						style = {
							w = "100%",
							padding = 15,
							borderRadius = 8,
							BGColor = isAuthenticating and "#3F3F46" or "#06B6D4",
							alignItems = "center",
							justifyContent = "center",
						},
						onClick = handleLogin,
						children = {
							elements.Text({
								text = isAuthenticating and "AUTHENTICATING..." or "ENTER MAINFRAME",
								style = { color = isAuthenticating and "#A1A1AA" or "#000000", fontSize = 16 },
							}),
						},
					}),
				},
			}),
		},
	})
end

-- CRITICAL: Return the function itself!
return LoginScreen
