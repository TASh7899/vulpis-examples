local elements = require("utils.core.elements")

function Window()
	return {
		title = "Vulpis Image Engine Test",
		w = 1000,
		h = 700,
		resizable = true,
	}
end

function App()
	return elements.VBox({
		style = {
			w = "100%",
			h = "100%",
			BGColor = "#121212", -- Deep dark background
			alignItems = "center",
			justifyContent = "center",
			gap = 30,
			padding = 40,
		},
		children = {
			elements.Text({
				text = "Web Image & Cache Recovery Test",
				style = {
					fontSize = 28,
					color = "#ffffff",
					fontWeight = "bold",
				},
			}),

			-- Image Gallery
			elements.HBox({
				style = {
					gap = 40,
					alignItems = "center",
					justifyContent = "center",
				},
				children = {
					-- Test 1: Standard Rounded Box with Border
					elements.Image({
						-- High-res 4K image to ensure the skeleton loader is visible while downloading
						src = "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop",
						style = {
							w = 250,
							h = 250,
							fit = "cover",
							borderRadius = 20, -- Testing SDF Corners
							borderWidth = 4, -- Testing transparent center border
							borderColor = "#3b82f6", -- Blue border
						},
					}),

					-- Test 2: Perfect Circle with Border
					elements.Image({
						src = "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2670&auto=format&fit=crop",
						style = {
							w = 250,
							h = 250,
							fit = "cover",
							borderRadius = 125, -- Half of W/H makes a perfect circle
							borderWidth = 4,
							borderColor = "#10b981", -- Green border
						},
					}),

					-- Test 3: Background Image Box
					elements.Box({
						style = {
							w = 250,
							h = 250,
							BGImage = "https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=2670&auto=format&fit=crop",
							BGFit = "cover",
							borderRadius = 20,
							borderWidth = 4,
							borderColor = "#ef4444", -- Red border
							alignItems = "center",
							justifyContent = "center",
						},
						children = {
							elements.Text({
								text = "BG Image",
								style = {
									color = "#ffffff",
									fontWeight = "bold",
									fontSize = 20,
									-- Add a dark semi-transparent background to text so it's readable
									BGColor = "rgba(0,0,0,150)",
									padding = 10,
									borderRadius = 8,
								},
							}),
						},
					}),
				},
			}),

			-- Test 4: Cache Wipe Auto-Recovery
			elements.Button({
				text = "Clear Cache (Test Auto-Recovery)",
				style = {
					marginTop = 40,
					paddingTop = 15,
					paddingBottom = 15,
					paddingLeft = 30,
					paddingRight = 30,
					BGColor = "#3b82f6",
					borderRadius = 8,
					color = "#ffffff",
					fontWeight = "bold",
				},
				onClick = function()
					print("Executing Hot Cache Wipe...")
					vulpis.clearCache()
				end,
			}),
		},
	})
end
