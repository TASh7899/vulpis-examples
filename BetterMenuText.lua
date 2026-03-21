local elements = require("utils.core.elements")

function Window()
	return { title = "Vulpis Engine Showcase", w = 1024, h = 768, resizable = true }
end

-- 1. Reusable Sidebar Navigation Component
local function SidebarItem(label, id, icon, isCollapsed)
	local isHovered = useState(id .. "_hover", false)
	local activeTab = useState("active_tab", "Dashboard")
	local isActive = activeTab == id
	local bgColor = isActive and "#3B82F6" or (isHovered and "#2D2D3A" or "transparent")

	local itemChildren = {}

	-- Icon wrapper to stabilize centering
	table.insert(
		itemChildren,
		elements.HBox({
			style = {
				w = 40,
				justifyContent = "center",
				alignItems = "center",
			},
			children = {
				elements.Text({
					text = icon,
					style = { color = isActive and "#FFFFFF" or "#A1A1AA", fontSize = 18 },
				}),
			},
		})
	)

	if not isCollapsed then
		table.insert(
			itemChildren,
			elements.Text({
				text = label,
				style = { color = isActive and "#FFFFFF" or "#A1A1AA", fontSize = 16 },
			})
		)
	end

	return elements.Button({
		id = id,
		style = {
			w = "100%",
			h = 45,
			paddingLeft = 10,
			paddingRight = 10,
			justifyContent = "start",
			alignItems = "center",
			BGColor = bgColor,
			marginBottom = 4,
		},
		onMouseEnter = function()
			setState(id .. "_hover", true)
		end,
		onMouseLeave = function()
			setState(id .. "_hover", false)
		end,
		onClick = function()
			setState("active_tab", id)
		end,
		children = itemChildren,
	})
end

-- 2. Reusable Content Card Component
local function SettingsCard(tab, index, title, desc)
	local stateKey = tab .. "_count"
	return elements.VBox({
		key = tab .. "_card_" .. index,
		style = { w = "100%", padding = 24, BGColor = "#27272A", marginBottom = 16, flexShrink = 0 },
		children = {
			elements.HBox({
				style = { w = "100%", justifyContent = "space-between", alignItems = "center", marginBottom = 8 },
				children = {
					elements.Text({ text = title, style = { color = "#FFFFFF", fontSize = 18 } }),
					elements.Button({
						style = { padding = 5, BGColor = "#EF4444" },
						onClick = function()
							local count = useState(stateKey, 3)
							setState(stateKey, count - 1)
						end,
						children = { elements.Text({ text = "Delete", style = { color = "#FFF", fontSize = 12 } }) },
					}),
				},
			}),
			elements.Text({
				text = desc,
				style = { color = "#A1A1AA", fontSize = 14, wordWrap = true, w = "100%", minWidth = 0 },
			}),
		},
	})
end

-- 3. Main Application Layout
function App()
	local activeTab = useState("active_tab", "Dashboard")
	local isCollapsed = useState("sidebar_collapsed", false)
	local showModal = useState("show_modal", false)

	local counts = {
		Dashboard = useState("Dashboard_count", 2),
		Projects = useState("Projects_count", 4),
		Analytics = useState("Analytics_count", 3),
		Settings = useState("Settings_count", 1),
	}

	local currentCount = counts[activeTab] or 0
	local sidebarWidth = isCollapsed and 60 or 260

	-- Header Logic (Contains the toggle button)
	local headerChildren = {}
	if not isCollapsed then
		table.insert(
			headerChildren,
			elements.Text({
				text = "VULPIS",
				style = { color = "#FFFFFF", fontSize = 24, paddingLeft = 10 },
			})
		)
	end
	table.insert(
		headerChildren,
		elements.Button({
			style = { w = 36, h = 36, BGColor = "transparent", justifyContent = "center", alignItems = "center" },
			focusable = true,
			onClick = function()
				setState("sidebar_collapsed", not isCollapsed)
			end,
			children = {
				elements.Text({ text = isCollapsed and ">" or "×", style = { color = "#A1A1AA", fontSize = 28 } }),
			},
		})
	)

	-- Generate Content Cards
	local cards = {}
	local tabDescriptions = {
		Dashboard = "System health monitoring and active engine instances.",
		Projects = "Configuration for C++ and Lua source directories.",
		Analytics = "Real-time frame timings and memory usage tracking.",
		Settings = "Global engine preferences and rendering toggles.",
	}

	for i = 1, currentCount do
		table.insert(cards, SettingsCard(activeTab, i, activeTab .. " Item #" .. i, tabDescriptions[activeTab]))
	end

	local appRoot = elements.HBox({
		style = { w = "100%", h = "100%", BGColor = "#18181B" },
		children = {
			-- LEFT: SIDEBAR
			elements.VBox({
				style = {
					w = sidebarWidth,
					h = "100%",
					BGColor = "#1F1F22",
					padding = 10,
					justifyContent = isCollapsed and "start" or "space-between",
					flexShrink = 0,
				},
				children = {
					elements.VBox({
						style = { w = "100%" },
						children = {
							-- Header/Toggle Area
							elements.HBox({
								style = {
									w = "100%",
									justifyContent = isCollapsed and "center" or "space-between",
									alignItems = "center",
									marginBottom = isCollapsed and 0 or 40,
								},
								children = headerChildren,
							}),

								-- ONLY SHOW BUTTONS IF NOT COLLAPSED
							not isCollapsed and SidebarItem("Dashboard", "Dashboard", "D", isCollapsed) or nil,
							not isCollapsed and SidebarItem("Projects", "Projects", "P", isCollapsed) or nil,
							not isCollapsed and SidebarItem("Analytics", "Analytics", "A", isCollapsed) or nil,
							not isCollapsed and SidebarItem("Settings", "Settings", "S", isCollapsed) or nil,
						},
					}),

							-- ONLY SHOW PROFILE IF NOT COLLAPSED
					not isCollapsed
							and elements.HBox({
								style = {
									w = "100%",
									padding = 12,
									BGColor = "#2D2D3A",
									alignItems = "center",
									justifyContent = "start",
								},
								children = {
									elements.HBox({
										style = {
											w = 36,
											h = 36,
											BGColor = "#3B82F6",
											justifyContent = "center",
											alignItems = "center",
											marginRight = 12,
											flexShrink = 0,
										},
										children = {
											elements.Text({ text = "TG", style = { color = "#FFF", fontSize = 12 } }),
										},
									}),
									elements.VBox({
										style = { flexShrink = 1 },
										children = {
											elements.Text({
												text = "Tanush Gupta",
												style = { color = "#FFFFFF", fontSize = 14 },
											}),
											elements.Text({
												text = "Dev",
												style = { color = "#A1A1AA", fontSize = 11 },
											}),
										},
									}),
								},
							})
						or nil,
				},
			}),

			-- RIGHT: MAIN CONTENT AREA
			elements.VBox({
				style = {
					flexGrow = 1,
					flexShrink = 1,
					w = "100%",
					minWidth = 0,
					h = "100%",
					padding = 40,
					overflow = "scroll",
				},
				children = {
					elements.HBox({
						style = {
							w = "100%",
							justifyContent = "space-between",
							alignItems = "center",
							marginBottom = 40,
							flexShrink = 0,
						},
						children = {
							elements.Text({ text = activeTab, style = { color = "#FFFFFF", fontSize = 32 } }),
							elements.Button({
								style = {
									BGColor = "#3B82F6",
									paddingLeft = 20,
									paddingRight = 20,
									paddingTop = 10,
									paddingBottom = 10,
								},
								onClick = function()
									setState("show_modal", true)
								end,
								children = {
									elements.Text({
										text = "+ Add " .. activeTab .. " Card",
										style = { color = "#FFF" },
									}),
								},
							}),
						},
					}),
					elements.VBox({ style = { w = "100%" }, children = cards }),
				},
			}),
		},
	})

	-- MODAL OVERLAY
	if showModal then
		return elements.Box({
			style = { w = "100%", h = "100%" },
			children = {
				appRoot,
				elements.VBox({
					style = {
						position = "absolute",
						left = 0,
						top = 0,
						w = "100%",
						h = "100%",
						BGColor = "#000000",
						opacity = 0.8,
						justifyContent = "center",
						alignItems = "center",
					},
					children = {
						elements.VBox({
							style = { w = 450, padding = 30, BGColor = "#1F1F22" },
							children = {
								elements.Text({
									text = "Add New " .. activeTab .. " Entry",
									style = { color = "#FFFFFF", fontSize = 24, marginBottom = 15 },
								}),
								elements.Text({
									text = "This card will only be added to the " .. activeTab .. " section.",
									style = {
										color = "#A1A1AA",
										fontSize = 14,
										wordWrap = true,
										minWidth = 0,
										marginBottom = 30,
									},
								}),
								elements.HBox({
									style = { w = "100%", justifyContent = "end" },
									children = {
										elements.Button({
											style = {
												padding = 10,
												paddingLeft = 20,
												paddingRight = 20,
												BGColor = "#3F3F46",
											},
											onClick = function()
												setState("show_modal", false)
											end,
											children = {
												elements.Text({ text = "Cancel", style = { color = "#FFF" } }),
											},
										}),
										elements.Box({ style = { w = 15 } }),
										elements.Button({
											style = {
												padding = 10,
												paddingLeft = 20,
												paddingRight = 20,
												BGColor = "#3B82F6",
											},
											onClick = function()
												setState(activeTab .. "_count", currentCount + 1)
												setState("show_modal", false)
											end,
											children = {
												elements.Text({ text = "Confirm", style = { color = "#FFF" } }),
											},
										}),
									},
								}),
							},
						}),
					},
				}),
			},
		})
	end

	return appRoot
end
