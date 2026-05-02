-- src/app.lua

function Window()
	return {
		title = "Vulpis Secure Session Test",
		w = 800,
		h = 600,
		resizable = false,
	}
end

function App()
	-- Application State
	local logStatus = useState("log_status", "System Idle.\n\nReady to test SecureStorage DPAPI/POSIX implementation.")
	local isLoading = useState("is_loading", false)
	local authState = useState("auth_state", "checking session....")

	-- 1. Simulate a Secure Login (Sets the cookie)
	local function onLogin()
		setState("is_loading", true)
		setState("log_status", "[Network] Authenticating securely over HTTPS...")

		-- Force httpbin to issue a Set-Cookie header
		vulpis.fetch("https://httpbin.org/cookies/set/vulpis_auth_token/secure_hash_8472910", {
			method = "GET",
			timeout = 5000,
		}, function(res)
			setState("is_loading", false)
			if res.status == 200 then
				setState("auth_state", "Logged In")
				setState(
					"log_status",
					"[Success] Server issued a session cookie.\n\nThe C++ engine has intercepted the Set-Cookie header, encrypted it using SecureStorage, and saved it to 'secure_session.dat'."
				)
			else
				setState(
					"log_status",
					"[Error] Login Failed.\nStatus: " .. tostring(res.status) .. "\nDetails: " .. tostring(res.error)
				)
			end
		end)
	end

	-- 2. Verify the Encrypted Session (Reads and sends the cookie)
	local function onVerifySession()
		setState("is_loading", true)
		setState("log_status", "[Network] Verifying encrypted session state...")

		vulpis.fetch("https://httpbin.org/cookies", {
			method = "GET",
			timeout = 5000,
		}, function(res)
			setState("is_loading", false)
			if res.status == 200 then
				-- Check if httpbin echoed back our secure cookie
				if string.find(res.body, "vulpis_auth_token") then
					setState("auth_state", "Logged In") -- ADD THIS LINE
					setState(
						"log_status",
						"[Verified] The engine successfully decrypted 'secure_session.dat' in memory and injected the cookie into the request headers!\n\nServer Response:\n"
							.. res.body
					)
				else
					setState("auth_state", "Logged Out")
					setState(
						"log_status",
						"[Unverified] No cookie was sent to the server. The secure session file is either missing or could not be decrypted."
					)
				end
			else
				setState(
					"log_status",
					"[Error] Verification Request Failed.\nStatus: "
						.. tostring(res.status)
						.. "\nDetails: "
						.. tostring(res.error)
				)
			end
		end)
	end

	-- 3. Secure Logout (Wipes the cache and destroys the secure file)
	local function onLogout()
		local success = vulpis.clearCache()
		if success then
			setState("auth_state", "Logged Out")
			setState(
				"log_status",
				"[Logged Out] Cache cleared successfully. 'secure_session.dat' has been destroyed from the disk."
			)
		else
			setState("log_status", "[Error] Failed to clear the local cache directory.")
		end
	end

	local hasInitialized = useState("hasInitialized", false)
	if not hasInitialized then
		setState("hasInitialized", true)
		onVerifySession()
	end

	local authColor = "#ef4444"
	if authState == "Logged In" then
		authColor = "#10b981"
	elseif authState == "Checking Session..." then
		authColor = "#f59e0b"
	end

	return {
		type = "vbox",
		style = {
			w = "100%",
			h = "100%",
			padding = 40,
			spacing = 20,
			BGColor = "#0f172a", -- Slate 900
			alignItems = "center",
		},
		children = {
			-- Title Section
			{
				type = "vbox",
				style = { alignItems = "center", spacing = 5 },
				children = {
					{
						type = "text",
						text = "Authentication Matrix",
						style = { fontSize = 36, color = "#f8fafc", fontWeight = "bold" },
					},
					{
						type = "text",
						text = "Engine Status: " .. authState,
						style = { fontSize = 18, color = authColor, fontWeight = "semi-bold" },
					},
				},
			},

			-- Action Buttons
			{
				type = "hbox",
				style = { spacing = 15, marginTop = 20 },
				children = {
					-- Login Button
					{
						type = "vbox",
						style = {
							w = 150,
							h = 45,
							BGColor = isLoading and "#60a5fa" or "#2563eb",
							borderRadius = 6,
							alignItems = "center",
							justifyContent = "center",
						},
						focusable = true,
						onClick = isLoading and function() end or onLogin,
						children = {
							{
								type = "text",
								text = "1. Secure Login",
								style = { color = "#ffffff", fontWeight = "bold" },
							},
						},
					},
					-- Verify Button
					{
						type = "vbox",
						style = {
							w = 150,
							h = 45,
							BGColor = isLoading and "#34d399" or "#059669",
							borderRadius = 6,
							alignItems = "center",
							justifyContent = "center",
						},
						focusable = true,
						onClick = isLoading and function() end or onVerifySession,
						children = {
							{
								type = "text",
								text = "2. Verify Session",
								style = { color = "#ffffff", fontWeight = "bold" },
							},
						},
					},
					-- Logout Button
					{
						type = "vbox",
						style = {
							w = 150,
							h = 45,
							BGColor = isLoading and "#f87171" or "#dc2626",
							borderRadius = 6,
							alignItems = "center",
							justifyContent = "center",
						},
						focusable = true,
						onClick = isLoading and function() end or onLogout,
						children = {
							{
								type = "text",
								text = "3. Wipe Data",
								style = { color = "#ffffff", fontWeight = "bold" },
							},
						},
					},
				},
			},

			-- Secure Terminal Output
			{
				type = "vbox",
				style = {
					w = "100%",
					flexGrow = 1,
					BGColor = "#020617", -- Slate 950
					borderRadius = 8,
					borderWidth = 2,
					borderColor = "#334155",
					padding = 20,
					marginTop = 20,
				},
				children = {
					{
						type = "text",
						text = logStatus,
						style = {
							color = "#38bdf8", -- Terminal Blue
							fontSize = 15,
							wordWrap = true,
							fontFamily = "default",
						},
					},
				},
			},
		},
	}
end
