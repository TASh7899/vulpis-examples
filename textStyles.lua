function Window()
	return { title = "Vulpis Typography One-Screen", width = 800, height = 600, resizable = true }
end

local function SectionTitle(text)
	return { type = "text", text = text, style = { fontSize = 14, color = "#888888", marginBottom = 5 } }
end

local function Row(children)
	return { type = "hbox", style = { gap = 20, alignItems = "center", marginBottom = 15 }, children = children }
end

local function Label(text, styleOverride)
	local s = { fontSize = 18, color = "#ffffff" }
	for k, v in pairs(styleOverride or {}) do
		s[k] = v
	end
	return { type = "text", text = text, style = s }
end

function App()
	return {
		type = "vbox",
		style = {
			w = "100%",
			h = "100%",
			BGColor = "#181818",
			padding = 40,
			justifyContent = "center", -- Center everything vertically
			alignItems = "center", -- Center everything horizontally
		},
		children = {
			-- Main Title
			{
				type = "text",
				text = "Vulpis Typography Engine",
				style = {
					fontSize = 32,
					fontWeight = "very-bold",
					color = "#4CAF50",
					marginBottom = 30,
					textDecoration = "underline",
				},
			},

			-- ROW 1: Faked Renderer Styles
			SectionTitle("1. Renderer Generated Styles (Faked)"),
			Row({
				Label("Normal"),
				Label("Faked Bold", { fontWeight = "bold", color = "#ffcc00" }),
				Label("Faked Italic", { fontStyle = "italics", color = "#00ccff" }),
				Label("Bold + Italic", { fontWeight = "bold", fontStyle = "italics", color = "#ff88ff" }),
			}),

			-- ROW 2: Decorations
			SectionTitle("2. Text Decorations"),
			Row({
				Label("Underlined Text", { textDecoration = "underline" }),
				Label("Strike through", { textDecoration = "strike-through", color = "#FFFFFF" }),

				Label("Bold & Underlined", { fontWeight = "bold", textDecoration = "underline" }),
			}),

			-- ROW 3: Sizing & Weights
			SectionTitle("3. Sizing & Dynamic Weights"),
			Row({
				Label("Tiny(12)", { fontSize = 12, color = "#aaaaaa" }),
				Label("Regular(20)", { fontSize = 20 }),
				Label("Large(28)", { fontSize = 28, fontWeight = "bold" }),
				Label("Thin Weight", { fontWeight = "thin", color = "#cccccc" }),
			}),

			-- ROW 4: Real Variants (If file exists) vs Fallback
			SectionTitle("4. Registered Variants Logic (demo_font)"),
			Row({
				Label("Base Font", { fontFamily = "demo_font" }),
				Label("Mapped Bold", { fontFamily = "demo_font", fontWeight = "bold", color = "#FFD700" }),
				Label("Mapped Italic", { fontFamily = "demo_font", fontStyle = "italics", color = "#00BFFF" }),
				Label("Bold Italic", {
					fontFamily = "demo_font",
					fontSize = 30,
					fontStyle = "italics",
					fontWeight = "bold",
					color = "#FFFFFF",
				}),
				Label("Bold Italic", {
					fontFamily = "demo_font",
					fontSize = 30,
					textDecoration = "strike-through",
					color = "#FFFFFF",
				}),
			}),
		},
	}
end
