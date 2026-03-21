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
	-- Always pack the icon container
	table.insert(
		itemChildren,
		elements.HBox({
			style = { w = 40, justifyContent = "center", alignItems = "center" },
			children = {
				elements.Text({
					text = icon,
					style = { color = isActive and "#FFFFFF" or "#A1A1AA", fontSize = 18 },
				}),
			},
		})
	)

	-- Only add text if expanded
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
							local currentVal = useState(stateKey, 2)
							setState(stateKey, currentVal - 1)
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
	local isCollapsed = useState("sidebar_collapsed", true)
	local showModal = useState("show_modal", false)

	-- Fetch states using unique keys to ensure they persist across renders
	local dashboardCount = useState("Dashboard_count", 2)
	local projectsCount = useState("Projects_count", 2)
	local analyticsCount = useState("Analytics_count", 2)
	local settingsCount = useState("Settings_count", 2)

	local counts =
		{ Dashboard = dashboardCount, Projects = projectsCount, Analytics = analyticsCount, Settings = settingsCount }
	local currentCount = counts[activeTab] or 0
	local sidebarWidth = isCollapsed and 60 or 260

	-- Pack Sidebar Header
	local headerChildren = {}
	if not isCollapsed then
		table.insert(
			headerChildren,
			elements.Text({ text = "VULPIS", style = { color = "#FFFFFF", fontSize = 24, paddingLeft = 10 } })
		)
	end
	table.insert(
		headerChildren,
		elements.Button({
			style = { w = 36, h = 36, BGColor = "transparent", justifyContent = "center", alignItems = "center" },
			onClick = function()
				setState("sidebar_collapsed", not isCollapsed)
			end,
			children = {
				elements.Text({ text = isCollapsed and ">" or "×", style = { color = "#A1A1AA", fontSize = 28 } }),
			},
		})
	)

	-- Build Card List
	local cardElements = {}
	for i = 1, currentCount do
		table.insert(
			cardElements,
			SettingsCard(activeTab, i, activeTab .. " Item #" .. i, "Active section: " .. activeTab)
		)
	end

	-- ┏╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┓
	-- ╏ BUILD PACKED ROOT CHILDREN TABLE    ╏
	-- ┗╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍╍┛
	local rootChildren = {}

	-- 1. Main Content always at index 1
	table.insert(
		rootChildren,
		elements.VBox({
			style = { w = "100%", h = "100%", padding = 40, paddingLeft = 80, overflow = "scroll" },
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
							children = { elements.Text({ text = "+ Add " .. activeTab, style = { color = "#FFF" } }) },
						}),
					},
				}),
				elements.VBox({ style = { w = "100%" }, children = cardElements }),
			},
		})
	)

	-- 2. Dull Overlay (only inserted if open - no nil holes)
	if not isCollapsed then
		table.insert(
			rootChildren,
			elements.Button({
				style = {
					position = "absolute",
					left = 0,
					top = 0,
					w = "100%",
					h = "100%",
					BGColor = "#000000",
					opacity = 0.5,
				},
				onClick = function()
					setState("sidebar_collapsed", true)
				end,
				children = {},
			})
		)
	end

	-- 3. Sidebar (Always packed next)
	local sidebarInnerChildren = {}
	table.insert(
		sidebarInnerChildren,
		elements.HBox({
			style = {
				w = "100%",
				justifyContent = isCollapsed and "center" or "space-between",
				alignItems = "center",
				marginBottom = isCollapsed and 0 or 40,
			},
			children = headerChildren,
		})
	)

	if not isCollapsed then
		table.insert(sidebarInnerChildren, SidebarItem("Dashboard", "Dashboard", "D", isCollapsed))
		table.insert(sidebarInnerChildren, SidebarItem("Projects", "Projects", "P", isCollapsed))
		table.insert(sidebarInnerChildren, SidebarItem("Analytics", "Analytics", "A", isCollapsed))
		table.insert(sidebarInnerChildren, SidebarItem("Settings", "Settings", "S", isCollapsed))
	end

	table.insert(
		rootChildren,
		elements.VBox({
			style = {
				position = "absolute",
				left = 0,
				top = 0,
				w = sidebarWidth,
				h = "100%",
				BGColor = "#1F1F22",
				padding = 10,
				borderRightWidth = 1,
				borderRightColor = "#333333",
			},
			children = sidebarInnerChildren,
		})
	)

	-- 4. Modal Overlay (Only inserted if active)
	if showModal then
		table.insert(
			rootChildren,
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
								text = "Add Entry to " .. activeTab,
								style = { color = "#FFFFFF", fontSize = 24, marginBottom = 15 },
							}),
							elements.HBox({
								style = { w = "100%", justifyContent = "end" },
								children = {
									elements.Button({
										style = { padding = 10, paddingLeft = 20, BGColor = "#3F3F46" },
										onClick = function()
											setState("show_modal", false)
										end,
										children = { elements.Text({ text = "Cancel", style = { color = "#FFF" } }) },
									}),
									elements.Box({ style = { w = 15 } }),
									elements.Button({
										style = { padding = 10, paddingLeft = 20, BGColor = "#3B82F6" },
										onClick = function()
											setState(activeTab .. "_count", currentCount + 1)
											setState("show_modal", false)
										end,
										children = { elements.Text({ text = "Confirm", style = { color = "#FFF" } }) },
									}),
								},
							}),
						},
					}),
				},
			})
		)
	end

	return elements.Box({
		style = { w = "100%", h = "100%", BGColor = "#18181B" },
		children = rootChildren, -- Always packed and continuous!
	})
end
