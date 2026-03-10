local elements = require("utils.core.elements")
local TextInput = require("utils.core.textInput")
local useTodoStore = require("todoStore")

local VBox = elements.VBox
local HBox = elements.HBox
local Text = elements.Text
local Button = elements.Button

-- Modern Color Palette (Catppuccin Mocha inspired)
local theme = {
	bg = "#1e1e2e",
	card = "#181825",
	surface = "#313244",
	text = "#cdd6f4",
	subtext = "#a6adc8",
	primary = "#89b4fa",
	primaryText = "#11111b",
	success = "#a6e3a1",
	danger = "#f38ba8",
	border = "#45475a",
}

function App()
	-- Global State
	local state = useTodoStore()

	-- Local State for the Input Box
	local inputText = useState("todo_input_text", "")

	-- Derived State: Filter the todos and count active ones
	local filteredTodos = {}
	local activeCount = 0

	for _, todo in ipairs(state.todos) do
		if not todo.completed then
			activeCount = activeCount + 1
		end

		if state.filter == "all" then
			table.insert(filteredTodos, todo)
		elseif state.filter == "active" and not todo.completed then
			table.insert(filteredTodos, todo)
		elseif state.filter == "completed" and todo.completed then
			table.insert(filteredTodos, todo)
		end
	end

	-- Handlers
	local function handleAddTodo()
		if inputText ~= "" then
			state.addTodo(inputText)
			setState("todo_input_text", "") -- Clear input
		end
	end

	-- Reusable UI Component: Filter Button
	local function FilterButton(label, filterValue)
		local isActive = state.filter == filterValue
		return Button({
			text = label,
			onClick = function()
				state.setFilter(filterValue)
			end,
			style = {
				BGColor = isActive and theme.primary or theme.surface,
				color = isActive and theme.primaryText or theme.text,
				paddingTop = 6,
				paddingBottom = 6,
				paddingLeft = 14,
				paddingRight = 14,
				marginRight = 10,
				borderRadius = 6,
				fontWeight = isActive and "bold" or "normal",
			},
		})
	end

	-- Render the List of Todos
	local todoElements = {}
	for _, todo in ipairs(filteredTodos) do
		table.insert(
			todoElements,
			HBox({
				key = "todo_" .. todo.id,
				style = {
					w = "100%",
					padding = 15,
					marginBottom = 10,
					BGColor = theme.surface,
					borderRadius = 8,
					alignItems = "center",
					justifyContent = "space-between",
				},
				children = {
					-- Left Side: Checkbox & Text
					HBox({
						style = { alignItems = "center", flex = 1 },
						children = {
							Button({
								text = todo.completed and "✓" or " ",
								onClick = function()
									state.toggleTodo(todo.id)
								end,
								style = {
									w = 24,
									h = 24,
									paddingTop = 0,
									paddingBottom = 0,
									paddingLeft = 0,
									paddingRight = 0,
									BGColor = todo.completed and theme.success or theme.bg,
									color = theme.primaryText,
									borderRadius = 12,
									marginRight = 15,
									borderWidth = 2,
									borderColor = todo.completed and theme.success or theme.subtext,
									justifyContent = "center",
									alignItems = "center",
								},
							}),
							Text({
								text = todo.text,
								style = {
									color = todo.completed and theme.subtext or theme.text,
									fontSize = 16,
									textDecoration = todo.completed and "line-through" or "none",
								},
							}),
						},
					}),
					-- Right Side: Delete Button
					Button({
						text = "x",
						onClick = function()
							state.deleteTodo(todo.id)
						end,
						style = {
							BGColor = "transparent",
							color = theme.danger,
							fontSize = 16,
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

	-- Determine children for the scrollable list area
	local listChildren
	if #todoElements > 0 then
		listChildren = todoElements
	else
		listChildren = {
			Text({
				key = "empty_state", -- Safely matched by your patched VDOM
				text = "No tasks here. You're all caught up!",
				style = { color = theme.subtext, alignSelf = "center", marginTop = 50 },
			}),
		}
	end

	-- Main Layout Assembly
	return VBox({
		style = {
			w = "100%",
			h = "100%",
			padding = 40,
			BGColor = theme.bg,
			alignItems = "center",
		},
		children = {
			-- App Card Container
			VBox({
				style = {
					w = 500,
					h = 500,
					overflow = "scroll",
					padding = 30,
					BGColor = theme.card,
					borderRadius = 12,
				},
				children = {
					-- Header Title
					Text({
						text = "Tasks",
						style = {
							fontSize = 32,
							fontWeight = "bold",
							color = theme.text,
							marginBottom = 24,
						},
					}),

					-- Input Row
					HBox({
						style = { w = "100%", marginBottom = 24, alignItems = "center" },
						children = {
							TextInput({
								id = "main_todo_input",
								value = inputText,
								placeholder = "What needs to be done?",
								onChange = function(val)
									setState("todo_input_text", val)
								end,
								onSubmit = handleAddTodo,
								theme = "dark",
								style = {
									flex = 1,
									h = 45,
									marginRight = 10,
									borderRadius = 8,
									BGColor = theme.surface,
									color = theme.text,
								},
							}),
							Button({
								text = "Add",
								onClick = handleAddTodo,
								style = {
									h = 45,
									paddingLeft = 20,
									paddingRight = 20,
									BGColor = theme.primary,
									color = theme.primaryText,
									fontWeight = "bold",
									borderRadius = 8,
								},
							}),
						},
					}),

					-- Filters Row
					HBox({
						style = { marginBottom = 20 },
						children = {
							FilterButton("All", "all"),
							FilterButton("Active", "active"),
							FilterButton("Completed", "completed"),
						},
					}),

					-- Scrollable List Area
					VBox({
						style = { w = "100%", minHeight = 200 },
						children = listChildren,
					}),

					-- Status Footer
					HBox({
						style = {
							w = "100%",
							marginTop = 20,
							paddingTop = 20,
							borderTopWidth = 1,
							borderColor = theme.surface,
							justifyContent = "space-between",
						},
						children = {
							Text({
								text = tostring(activeCount) .. " items left",
								style = { color = theme.subtext, fontSize = 14 },
							}),
						},
					}),
				},
			}),
		},
	})
end

return App
