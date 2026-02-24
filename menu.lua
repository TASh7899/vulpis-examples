function Window()
	return { resizable = true }
end

local function createMenuButton(text, hoverStateKey, onClickAction)
	local isHovered = useState(hoverStateKey, false)
	return {
		type = "hbox",
		style = {
			w = "100%",
			h = 35,
			BGColor = isHovered and "#374151" or "#1f2937",
			alignItems = "center",
			paddingLeft = 10,
		},
		onMouseEnter = function()
			setState(hoverStateKey, true)
		end,
		onMouseLeave = function()
			setState(hoverStateKey, false)
		end,
		onClick = onClickAction,
		children = {
			{ type = "text", text = text, style = { color = "#f3f4f6", fontSize = 14 } },
		},
	}
end

function App()
	-- 1. App State
	local menuVisible = useState("menuVisible", false)
	local menuX = useState("menuX", 0)
	local menuY = useState("menuY", 0)
	local statusText = useState("statusText", "Welcome to Vulpis Engine!")
	local hoveredCard = useState("hoveredCard", -1)

	-- Functional States
	local cardCount = useState("cardCount", 5) -- Track how many cards exist
	local isLightMode = useState("isLightMode", false) -- Track the current theme

	-- 2. Theme Configuration
	local theme = {
		bgMain = isLightMode and "#f3f4f6" or "#030712",
		bgHeader = isLightMode and "#ffffff" or "#111827",
		bgCard = isLightMode and "#e5e7eb" or "#1f2937",
		bgCardHover = isLightMode and "#d1d5db" or "#374151",
		textMain = isLightMode and "#111827" or "#ffffff",
		textSub = isLightMode and "#4b5563" or "#9ca3af",
	}

	-- 3. Context Menu (With Invisible Overlay)
	local contextMenuOverlay = nil
	if menuVisible then
		contextMenuOverlay = {
			type = "vbox",
			-- 1. THE INVISIBLE BACKDROP
			style = {
				position = "absolute",
				left = 0,
				top = 0,
				w = "100%",
				h = "100%",
				-- No BGColor, so it's fully transparent and catches outside clicks
			},
			onClick = function()
				setState("menuVisible", false)
			end,
			onRightClick = function(x, y)
				-- If they right-click the backdrop, just move the menu
				setState("menuX", x)
				setState("menuY", y)
			end,

			-- 2. THE ACTUAL MENU
			children = {
				{
					type = "vbox",
					style = {
						position = "absolute",
						left = menuX,
						top = menuY,
						w = 180,
						BGColor = "#1f2937",
						padding = 5,
					},
					children = {
						-- ACTION 1: Add a card to the list
						createMenuButton("➕ Add New Card", "hoverMenu1", function()
							setState("cardCount", cardCount + 1)
							setState("statusText", "Added Card #" .. (cardCount + 1))
							setState("menuVisible", false)
						end),

						-- ACTION 2: Toggle Dark/Light Mode
						createMenuButton(
							isLightMode and "🌙 Dark Mode" or "☀️ Light Mode",
							"hoverMenu2",
							function()
								setState("isLightMode", not isLightMode)
								setState("statusText", isLightMode and "Dark Mode Enabled" or "Light Mode Enabled")
								setState("menuVisible", false)
							end
						),

						-- ACTION 3: Wipe all cards from the screen
						createMenuButton("🗑️ Clear All Cards", "hoverMenu3", function()
							setState("cardCount", 0)
							setState("statusText", "All cards cleared.")
							setState("menuVisible", false)
						end),
					},
				},
			},
		}
	end

	-- 4. Header Navbar
	local header = {
		type = "hbox",
		style = {
			position = "absolute", -- <--- ADD THIS to remove it from flex flow
			top = 0, -- <--- ADD THIS to pin it to the top
			left = 0, -- <--- ADD THIS
			w = "100%",
			h = 60,
			BGColor = theme.bgHeader,
			alignItems = "center",
			justifyContent = "space-between",
			paddingLeft = 20,
			paddingRight = 20,
		},
		children = {
			{
				type = "text",
				text = "🦊 Vulpis Dashboard",
				style = { color = "#3b82f6", fontSize = 24, fontWeight = "bold" },
			},
			{ type = "text", text = statusText, style = { color = theme.textSub, fontSize = 16 } },
		},
	}

	-- 5. Scrollable List of Cards (Dynamically generated based on cardCount state)
	local cardList = {}
	for i = 1, cardCount do
		local isHovered = (hoveredCard == i)
		table.insert(cardList, {
			type = "vbox",
			style = {
				w = "100%",
				h = 100,
				BGColor = isHovered and theme.bgCardHover or theme.bgCard,
				padding = 15,
				justifyContent = "center",
				gap = 8,
			},
			onMouseEnter = function()
				setState("hoveredCard", i)
			end,
			onMouseLeave = function()
				setState("hoveredCard", -1)
			end,
			onClick = function()
				setState("statusText", "You clicked Card #" .. i)
			end,
			onRightClick = function(x, y)
				setState("menuX", x)
				setState("menuY", y)
				setState("menuVisible", true)
			end,
			children = {
				{
					type = "text",
					text = "Dashboard Item #" .. i,
					style = { color = theme.textMain, fontSize = 18, fontWeight = "semi-bold" },
				},
				{
					type = "text",
					text = "Right-click to open actions menu.",
					style = { color = theme.textSub, fontSize = 14 },
				},
			},
		})
	end

	-- 6. Main Assembly
	return {
		type = "vbox",
		style = { w = "100%", h = "100%", BGColor = theme.bgMain },

		onRightClick = function(x, y)
			setState("menuX", x)
			setState("menuY", y)
			setState("menuVisible", true)
		end,
		children = {
			-- 1. CARDS DRAWN FIRST (Bottom Layer)
			-- We added marginTop = 60 so they start underneath the absolute header
			{
				type = "vbox",
				style = {
					flexGrow = 1,
					flexShrink = 1,
					w = "100%",
					marginTop = 60, -- <--- ADD THIS!
					padding = 20,
					gap = 15,
					overflow = "scroll",
				},
				children = cardList,
			},

			-- 2. HEADER DRAWN SECOND (Middle Layer)
			-- Because it is absolute, it floats perfectly over the scrolling cards
			header,

			-- 3. CONTEXT MENU DRAWN LAST (Top Layer)
			contextMenuOverlay,
		},
	}
end
