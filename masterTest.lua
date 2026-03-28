-- =========================================================================
-- VULPIS ENGINE - CORE UTILITIES TEST SUITE (app.lua)
-- =========================================================================

local elements = require("utils.core.elements")
local TextInput = require("utils.core.textInput")
local router = require("utils.core.router")
local store = require("utils.core.store")
local tools = require("utils.core.tools")
local json = require("utils.core.json")

-- -------------------------------------------------------------------------
-- 1. WINDOW & ENGINE LIFECYCLE
-- -------------------------------------------------------------------------

function Window()
	return {
		title = "Vulpis Core Utils Debug App",
		w = 1125, -- Widened slightly to fit the new nav bar
		h = 800,
		resizable = true,
		mode = "windowed",
	}
end

function on_tick(dt)
	tools.updateFPS(dt)
end

function on_render()
	tools.drawFPS()
end

-- -------------------------------------------------------------------------
-- 2. GLOBAL STORE SETUP
-- -------------------------------------------------------------------------

local useAppStore = store.create(function(get, set)
	return {
		globalCount = 0,
		increment = function()
			set({ globalCount = get().globalCount + 1 })
		end,
		decrement = function()
			set({ globalCount = get().globalCount - 1 })
		end,
	}
end)

-- -------------------------------------------------------------------------
-- 3. SHARED UI COMPONENTS
-- -------------------------------------------------------------------------

local function NavBar()
	local function NavItem(label, path)
		local currentPath = useState("__router_current_path", "/")
		local isActive = currentPath == path

		return elements.Button({
			text = label,
			onClick = function()
				router.push(path)
			end,
			style = {
				BGColor = isActive and "#89b4fa" or "#313244",
				color = isActive and "#1e1e2e" or "#cdd6f4",
				paddingLeft = 12,
				paddingRight = 12,
				paddingTop = 8,
				paddingBottom = 8,
				borderRadius = 6,
				marginBottom = 10,
			},
		})
	end

	return elements.HBox({
		style = {
			w = "100%",
			minHeight = 60,
			BGColor = "#11111b",
			alignItems = "center",
			paddingLeft = 20,
			paddingTop = 10,
			paddingRight = 20,
			spacing = 10,
			flexWrap = "wrap",
			borderBottomWidth = 2,
			borderColor = "#1e1e2e",
		},
		children = {
			elements.Text(
				"Vulpis Debug",
				{ color = "#f38ba8", fontWeight = "bold", marginRight = 15, marginBottom = 10 }
			),
			NavItem("Store", "/"),
			NavItem("Inputs", "/inputs"),
			NavItem("Events", "/events"),
			NavItem("Keys", "/keys"), -- NEW
			NavItem("Network", "/network"),
			NavItem("Images", "/images"), -- NEW
			NavItem("Drag", "/drag"),
			NavItem("Layout", "/layout"),
			NavItem("Z-Index", "/zindex"), -- NEW
			NavItem("Typography", "/typography"),
			NavItem("Scroll", "/scroll"),
		},
	})
end

local function PageLayout(title, contentChildren)
	return elements.VBox({
		style = { w = "100%", h = "100%", BGColor = "#1e1e2e" },
		children = {
			NavBar(),
			elements.VBox({
				style = { w = "100%", flexGrow = 1, padding = 30, overflow = "scroll", spacing = 20 },
				children = {
					elements.Text(title, {
						color = "#cba6f7",
						fontSize = 28,
						fontWeight = "bold",
						borderBottomWidth = 1,
						borderColor = "#313244",
						paddingBottom = 10,
					}),
					elements.VBox({ style = { spacing = 20, w = "100%" }, children = contentChildren }),
				},
			}),
		},
	})
end

-- -------------------------------------------------------------------------
-- 4. SCREENS
-- -------------------------------------------------------------------------

local function HomeScreen()
	local state = useAppStore()
	return PageLayout("Global Store & Basic Elements", {
		elements.Text("Testing 'utils/core/store.lua' and 'utils/core/elements.lua'.", { color = "#a6adc8" }),
		elements.HBox({
			style = { alignItems = "center", spacing = 20, marginTop = 20 },
			children = {
				elements.Button({
					text = "-",
					onClick = state.decrement,
					style = { BGColor = "#f38ba8", color = "#11111b", fontSize = 20, w = 40, h = 40 },
				}),
				elements.Text(
					"Count: " .. state.globalCount,
					{ fontSize = 24, color = "#a6e3a1", fontWeight = "bold" }
				),
				elements.Button({
					text = "+",
					onClick = state.increment,
					style = { BGColor = "#a6e3a1", color = "#11111b", fontSize = 20, w = 40, h = 40 },
				}),
			},
		}),
		elements.Box({ style = { w = "100%", h = 2, BGColor = "#313244", marginTop = 20, marginBottom = 20 } }),
		elements.Text("Flexbox Elements Test:", { color = "#cdd6f4", fontWeight = "bold" }),
		elements.HBox({
			style = {
				w = "100%",
				h = 100,
				BGColor = "#181825",
				justifyContent = "space-around",
				alignItems = "center",
				borderRadius = 8,
			},
			children = {
				elements.Box({ style = { w = 60, h = 60, BGColor = "#fab387", borderRadius = 12 } }),
				elements.Box({ style = { w = 60, h = 60, BGColor = "#f9e2af", borderRadius = 30 } }),
				elements.Box({ style = { w = 60, h = 60, BGColor = "#74c7ec", borderRadius = 12 } }),
			},
		}),
	})
end

local function InputsScreen()
	local nameInput = useState("nameInput", "")
	return PageLayout("Text Inputs & Selection", {
		elements.VBox({
			style = { spacing = 10, marginTop = 20 },
			children = {
				elements.Text("Controlled TextInput:", { color = "#cdd6f4" }),
				TextInput({
					id = "debug_name_input",
					value = nameInput,
					placeholder = "Enter your name...",
					theme = "dark",
					style = { w = 400, borderRadius = 6, borderColor = "#cba6f7", borderWidth = 1 },
					onChange = function(val)
						setState("nameInput", val)
					end,
				}),
				elements.Text("Live output: " .. nameInput, { color = "#f9e2af", marginTop = 10 }),
			},
		}),
		elements.VBox({
			style = { spacing = 10, marginTop = 30 },
			children = {
				elements.Text(
					"Selectable Standard Text (Double click/drag to select, Ctrl+C to copy):",
					{ color = "#cdd6f4" }
				),
				elements.Text({
					text = "The quick brown fox jumps over the lazy dog. Try selecting this text and copying it to your system clipboard!",
					allowSelection = true,
					style = {
						w = 400,
						wordWrap = true,
						BGColor = "#181825",
						padding = 15,
						borderRadius = 8,
						color = "#89dceb",
					},
				}),
			},
		}),
	})
end

local function EventsScreen()
	local lastEvent = useState("lastEvent", "None")
	local mousePos = useState("mousePos", "x: 0, y: 0")
	local isHovered = useState("eventBoxHovered", false)

	return PageLayout("Mouse Events", {
		elements.Text("Interact with the box below to test the mouse event system.", { color = "#a6adc8" }),
		elements.HBox({
			style = { spacing = 30, marginTop = 20, alignItems = "center" },
			children = {
				elements.Box({
					style = {
						w = 200,
						h = 200,
						BGColor = isHovered and "#a6e3a1" or "#89b4fa",
						alignItems = "center",
						justifyContent = "center",
						borderRadius = 12,
						cursor = "pointer",
					},
					onMouseEnter = function()
						setState("lastEvent", "MouseEnter")
						setState("eventBoxHovered", true)
					end,
					onMouseLeave = function()
						setState("lastEvent", "MouseLeave")
						setState("eventBoxHovered", false)
					end,
					onMouseDown = function()
						setState("lastEvent", "MouseDown")
					end,
					onMouseUp = function()
						setState("lastEvent", "MouseUp")
					end,
					onMouseMove = function(x, y)
						setState("mousePos", "x: " .. x .. ", y: " .. y)
					end,
					children = { elements.Text("Mouse Target", { color = "#11111b", fontWeight = "bold" }) },
				}),
				elements.VBox({
					style = { spacing = 10, BGColor = "#181825", padding = 20, borderRadius = 8, w = 300 },
					children = {
						elements.Text("Event Log", {
							color = "#cba6f7",
							fontWeight = "bold",
							borderBottomWidth = 1,
							borderColor = "#313244",
							paddingBottom = 5,
						}),
						elements.Text("Last Trigger: " .. lastEvent, { color = "#f9e2af" }),
						elements.Text("Local Mouse: " .. mousePos, { color = "#f38ba8" }),
					},
				}),
			},
		}),
	})
end

-- NEW SCREEN: Keyboard Events
local function KeysScreen()
	local lastKey = useState("lastKey", "None")
	local mods = useState("keyMods", "None")
	local isFocused = useState("keysFocused", false)

	return PageLayout("Keyboard Events & Focus", {
		elements.Text(
			"Click the target box below to give it focus, then type on your keyboard.",
			{ color = "#a6adc8" }
		),
		elements.Box({
			focusable = true,
			style = {
				w = 400,
				h = 200,
				BGColor = isFocused and "#313244" or "#181825",
				borderWidth = 2,
				borderColor = isFocused and "#a6e3a1" or "#45475a",
				alignItems = "center",
				justifyContent = "center",
				borderRadius = 8,
				marginTop = 20,
			},
			onFocus = function()
				setState("keysFocused", true)
			end,
			onBlur = function()
				setState("keysFocused", false)
			end,
			onKeyDown = function(key, modTable)
				setState("lastKey", key)
				local m = {}
				if modTable.ctrl then
					table.insert(m, "Ctrl")
				end
				if modTable.shift then
					table.insert(m, "Shift")
				end
				if modTable.alt then
					table.insert(m, "Alt")
				end
				setState("keyMods", #m > 0 and table.concat(m, " + ") or "None")
			end,
			children = {
				elements.VBox({
					style = { spacing = 10, alignItems = "center" },
					children = {
						elements.Text(
							isFocused and "Focused (Typing Active)" or "Click Here to Focus",
							{ color = isFocused and "#a6e3a1" or "#a6adc8", fontWeight = "bold" }
						),
						elements.Text("Last Key: " .. lastKey, { color = "#f9e2af", fontSize = 24 }),
						elements.Text("Modifiers: " .. mods, { color = "#f38ba8" }),
					},
				}),
			},
		}),
	})
end

local function NetworkScreen()
	local reqStatus = useState("reqStatus", "Idle")
	local reqData = useState("reqData", nil)

	return PageLayout("Networking & JSON", {
		elements.HBox({
			style = { spacing = 30, marginTop = 20, alignItems = "flex-start", w = "100%" },
			children = {
				elements.VBox({
					style = { spacing = 15 },
					children = {
						elements.Button({
							text = "Fetch Random Fact",
							style = { BGColor = "#89b4fa" },
							onClick = function()
								setState("reqStatus", "Loading...")
								vulpis.httpGet("https://catfact.ninja/fact", function(res)
									if res.status == 200 then
										setState("reqStatus", "Success (" .. res.status .. ")")
										setState("reqData", json.decode(res.body).fact)
									else
										setState("reqStatus", "Error (" .. res.status .. ")")
									end
								end)
							end,
						}),
						elements.Text("Status: " .. reqStatus, { color = "#f38ba8" }),
					},
				}),
				elements.VBox({
					style = {
						flexGrow = 1,
						flexShrink = 1,
						minWidth = 0,
						minHeight = 100,
						BGColor = "#181825",
						padding = 15,
						borderRadius = 8,
					},
					children = {
						elements.Text(
							reqData or "No data fetched yet.",
							{ color = "#cdd6f4", wordWrap = true, w = "100%", flexShrink = 1 }
						),
					},
				}),
			},
		}),
	})
end

-- NEW SCREEN: Images & Fit Modes
local function ImagesScreen()
	local imgSrc = "https://picsum.photos/400/200" -- A 2:1 aspect ratio image

	return PageLayout("Images & Fit Algorithms", {
		elements.Text(
			"Testing 'fit' properties on images (Container is 150x150, Source Image is 400x200)",
			{ color = "#a6adc8" }
		),
		elements.HBox({
			style = { w = "100%", spacing = 30, flexWrap = "wrap", marginTop = 20 },
			children = {
				elements.VBox({
					style = { spacing = 10, alignItems = "center" },
					children = {
						elements.Text("cover", { color = "#cba6f7", fontWeight = "bold" }),
						elements.Image({
							src = imgSrc,
							style = {
								w = 150,
								h = 150,
								fit = "cover",
								borderRadius = 12,
								borderWidth = 2,
								borderColor = "#313244",
								BGColor = "#181825",
							},
						}),
					},
				}),
				elements.VBox({
					style = { spacing = 10, alignItems = "center" },
					children = {
						elements.Text("contain", { color = "#cba6f7", fontWeight = "bold" }),
						elements.Image({
							src = imgSrc,
							style = {
								w = 150,
								h = 150,
								fit = "contain",
								borderRadius = 12,
								borderWidth = 2,
								borderColor = "#313244",
								BGColor = "#181825",
							},
						}),
					},
				}),
				elements.VBox({
					style = { spacing = 10, alignItems = "center" },
					children = {
						elements.Text("fill (stretch)", { color = "#cba6f7", fontWeight = "bold" }),
						elements.Image({
							src = imgSrc,
							style = {
								w = 150,
								h = 150,
								fit = "fill",
								borderRadius = 12,
								borderWidth = 2,
								borderColor = "#313244",
								BGColor = "#181825",
							},
						}),
					},
				}),
			},
		}),
	})
end

local function DragScreen()
	local dragX = useState("dragNodeX", 0)
	local dragY = useState("dragNodeY", 0)

	return elements.VBox({
		style = { w = "100%", h = "100%", BGColor = "#1e1e2e" },
		children = {
			NavBar(),
			elements.Box({
				style = { w = "100%", flexGrow = 1, overflow = "hidden" },
				children = {
					elements.Text(
						"Absolute Positioning & Drag Events",
						{ color = "#cba6f7", fontSize = 24, padding = 20 }
					),
					elements.VBox({
						draggable = true,
						onDragEnd = function(dropId, dx, dy)
							setState("dragNodeX", dragX + dx)
							setState("dragNodeY", dragY + dy)
						end,
						style = {
							position = "absolute",
							left = 300 + dragX,
							top = 200 + dragY,
							w = 150,
							h = 150,
							BGColor = "#a6e3a1",
							borderRadius = 20,
							borderWidth = 4,
							borderColor = "#11111b",
							alignItems = "center",
							justifyContent = "center",
							cursor = "pointer",
						},
						children = {
							elements.Text("Drag Me", { color = "#11111b", fontWeight = "bold", fontSize = 20 }),
						},
					}),
				},
			}),
		},
	})
end

local function LayoutScreen()
	local wrappedItems = {}
	for i = 1, 15 do
		table.insert(
			wrappedItems,
			elements.Box({
				style = {
					w = 60,
					h = 40,
					BGColor = "#f5c2e7",
					borderRadius = 4,
					alignItems = "center",
					justifyContent = "center",
				},
				children = { elements.Text(tostring(i), { color = "#11111b" }) },
			})
		)
	end

	return PageLayout("Advanced Layout", {
		elements.Text("Yoga Flex Wrap Test:", { color = "#cba6f7", fontWeight = "bold" }),
		elements.HBox({
			style = { w = "100%", flexWrap = "wrap", spacing = 10, BGColor = "#181825", padding = 15, borderRadius = 8 },
			children = wrappedItems,
		}),
	})
end

-- NEW SCREEN: Z-Index & Clipping
local function ZIndexScreen()
	return PageLayout("Z-Index & Overflow Clipping", {
		elements.HBox({
			style = { w = "100%", spacing = 50, marginTop = 20 },
			children = {
				-- Z-Index Test
				elements.VBox({
					style = {
						w = 300,
						h = 300,
						BGColor = "#181825",
						borderRadius = 8,
						position = "relative",
						overflow = "hidden",
					},
					children = {
						elements.Text(
							"Z-Index Stacking (Absolute)",
							{ color = "#cba6f7", padding = 15, fontWeight = "bold" }
						),

						-- Red rendered first (in DOM), but highest Z-Index
						elements.Box({
							style = {
								position = "absolute",
								left = 50,
								top = 70,
								w = 100,
								h = 100,
								BGColor = "#f38ba8",
								zIndex = 3,
								alignItems = "center",
								justifyContent = "center",
								borderRadius = 8,
								borderWidth = 2,
								borderColor = "#11111b",
							},
							children = { elements.Text("Z: 3", { color = "#11111b", fontWeight = "bold" }) },
						}),
						-- Green rendered second
						elements.Box({
							style = {
								position = "absolute",
								left = 80,
								top = 100,
								w = 100,
								h = 100,
								BGColor = "#a6e3a1",
								zIndex = 2,
								alignItems = "center",
								justifyContent = "center",
								borderRadius = 8,
								borderWidth = 2,
								borderColor = "#11111b",
							},
							children = { elements.Text("Z: 2", { color = "#11111b", fontWeight = "bold" }) },
						}),
						-- Blue rendered third (normally on top), but lowest Z-Index
						elements.Box({
							style = {
								position = "absolute",
								left = 110,
								top = 130,
								w = 100,
								h = 100,
								BGColor = "#89b4fa",
								zIndex = 1,
								alignItems = "center",
								justifyContent = "center",
								borderRadius = 8,
								borderWidth = 2,
								borderColor = "#11111b",
							},
							children = { elements.Text("Z: 1", { color = "#11111b", fontWeight = "bold" }) },
						}),
					},
				}),

				-- Overflow Test
				elements.VBox({
					style = {
						w = 300,
						h = 300,
						BGColor = "#181825",
						borderRadius = 8,
						alignItems = "center",
						justifyContent = "center",
					},
					children = {
						elements.Text(
							"Circular Overflow Clipping",
							{ color = "#cba6f7", paddingBottom = 20, fontWeight = "bold" }
						),
						elements.Box({
							style = {
								w = 150,
								h = 150,
								BGColor = "#313244",
								borderRadius = 75,
								overflow = "hidden",
								borderWidth = 4,
								borderColor = "#FF0000",
								alignItems = "center",
							},
							children = {
								-- A rectangle that should be cut off by the circle's borders
								elements.Box({ style = { w = 200, h = 60, BGColor = "#fab387", marginTop = 60 } }),
							},
						}),
					},
				}),
			},
		}),
	})
end

local function TypographyScreen()
	return PageLayout("Typography & Font Rendering", {
		elements.HBox({
			style = { spacing = 50, w = "100%", alignItems = "flex-start" },
			children = {
				elements.VBox({
					style = { spacing = 10 },
					children = {
						elements.Text("Font Weights", {
							color = "#cba6f7",
							fontWeight = "bold",
							fontSize = 20,
							borderBottomWidth = 1,
							borderColor = "#313244",
							paddingBottom = 5,
						}),
						elements.Text("Thin Weight", { fontWeight = "thin", color = "#cdd6f4", fontSize = 18 }),
						elements.Text("Regular Weight", { fontWeight = "regular", color = "#cdd6f4", fontSize = 18 }),
						elements.Text("Bold Weight", { fontWeight = "bold", color = "#cdd6f4", fontSize = 18 }),
						elements.Text(
							"Very Bold Weight",
							{ fontWeight = "very-bold", color = "#cdd6f4", fontSize = 18 }
						),
					},
				}),
				elements.VBox({
					style = { spacing = 10 },
					children = {
						elements.Text("Styles & Decorations", {
							color = "#cba6f7",
							fontWeight = "bold",
							fontSize = 20,
							borderBottomWidth = 1,
							borderColor = "#313244",
							paddingBottom = 5,
						}),
						elements.Text("Italics Style", { fontStyle = "italics", color = "#a6e3a1", fontSize = 18 }),
						elements.Text(
							"Underlined Text",
							{ textDecoration = "underline", color = "#89dceb", fontSize = 18 }
						),
						elements.Text(
							"Strike-through Text",
							{ textDecoration = "strike-through", color = "#f38ba8", fontSize = 18 }
						),
					},
				}),
			},
		}),
		elements.Text(
			"Word Wrap & Bounds Constraint:",
			{ color = "#cba6f7", fontWeight = "bold", fontSize = 20, marginTop = 30 }
		),
		elements.Box({
			style = {
				w = 350,
				BGColor = "#181825",
				padding = 15,
				borderRadius = 8,
				borderWidth = 1,
				borderColor = "#45475a",
			},
			children = {
				elements.Text(
					"This is a long paragraph designed to test the word wrapping algorithms in the font registry. It should seamlessly break into multiple lines without overflowing the boundaries of its 350px wide parent container.",
					{ color = "#bac2de", wordWrap = true, w = "100%", fontSize = 16 }
				),
			},
		}),
	})
end

local function ScrollScreen()
	local listItems = {}
	for i = 1, 100 do
		table.insert(
			listItems,
			elements.HBox({
				style = {
					w = "100%",
					h = 50,
					BGColor = (i % 2 == 0) and "#313244" or "#181825",
					alignItems = "center",
					paddingLeft = 15,
					paddingRight = 15,
					borderRadius = 6,
				},
				children = {
					elements.Text("List Item #" .. i, { color = "#cdd6f4", fontWeight = "bold" }),
					elements.Box({ style = { flexGrow = 1 } }),
					elements.Button({
						text = "Action",
						style = {
							BGColor = "#cba6f7",
							color = "#11111b",
							paddingTop = 5,
							paddingBottom = 5,
							paddingLeft = 10,
							paddingRight = 10,
						},
					}),
				},
			})
		)
	end

	return PageLayout("Scroll & Layout Performance Test", {
		elements.Text(
			"Testing a nested view with `overflow = 'scroll'` containing 100 complex nodes.",
			{ color = "#a6adc8" }
		),
		elements.VBox({
			style = {
				w = "100%",
				h = 450,
				overflow = "scroll",
				BGColor = "#11111b",
				padding = 10,
				spacing = 10,
				borderRadius = 8,
				borderWidth = 2,
				borderColor = "#45475a",
			},
			children = listItems,
		}),
	})
end

-- -------------------------------------------------------------------------
-- 5. ROUTER INITIALIZATION & APP ENTRY
-- -------------------------------------------------------------------------

router.define({
	["/"] = HomeScreen,
	["/inputs"] = InputsScreen,
	["/events"] = EventsScreen,
	["/keys"] = KeysScreen, -- NEW
	["/network"] = NetworkScreen,
	["/images"] = ImagesScreen, -- NEW
	["/drag"] = DragScreen,
	["/layout"] = LayoutScreen,
	["/zindex"] = ZIndexScreen, -- NEW
	["/typography"] = TypographyScreen,
	["/scroll"] = ScrollScreen,
})

function App()
	return router.render()
end
