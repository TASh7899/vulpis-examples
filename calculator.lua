local el = require("utils.core.elements")

function Window()
	return {
		title = "Vulpis Calculator",
		w = 360,
		h = 640,
		resizable = true,
		mode = "windowed",
	}
end

-- Button Component
local function CalcButton(label, color, flexWeight, onClick)
	return el.VBox({
		style = {
			flexGrow = flexWeight,
			BGColor = color,
			justifyContent = "center",
			alignItems = "center",
			borderRadius = 8,
			margin = 2,
		},
		onClick = onClick,
		children = {
			el.Text(label, { style = { color = "#FFFFFF", fontSize = 28, fontWeight = "bold" } }),
		},
	})
end

function App()
	-- STATE
	local display = useState("calc_disp", "0")
	local history = useState("calc_hist", "")

	local storedVal = useState("calc_stored", 0)
	local operator = useState("calc_op", nil)
	local newEntry = useState("calc_new", true)

	-- LOGIC
	local function onNum(num)
		local currentDisp = display
		if newEntry then
			currentDisp = num
			setState("calc_new", false)
		else
			if num == "." and string.find(currentDisp, "%.") then
				return
			end
			currentDisp = currentDisp .. num
		end
		setState("calc_disp", currentDisp)
	end

	local function onOp(op)
		local currentVal = tonumber(display)
		setState("calc_op", op)
		setState("calc_stored", currentVal)
		setState("calc_new", true)
		setState("calc_hist", currentVal .. " " .. op)
	end

	local function onEqual()
		if not operator then
			return
		end
		local val1 = tonumber(storedVal)
		local val2 = tonumber(display)
		local result = 0

		if operator == "+" then
			result = val1 + val2
		elseif operator == "-" then
			result = val1 - val2
		elseif operator == "*" then
			result = val1 * val2
		elseif operator == "/" then
			if val2 == 0 then
				result = "Error"
			else
				result = val1 / val2
			end
		end

		setState("calc_hist", val1 .. " " .. operator .. " " .. val2 .. " =")
		setState("calc_disp", tostring(result))
		setState("calc_op", nil)
		setState("calc_new", true)
	end

	local function onClear()
		setState("calc_disp", "0")
		setState("calc_hist", "")
		setState("calc_stored", 0)
		setState("calc_op", nil)
		setState("calc_new", true)
	end

	-- RENDER
	return el.VBox({
		style = {
			w = "100%",
			h = "100%",
			BGColor = "#121212",
			padding = 10,
			gap = 10,
			justifyContent = "space-between", -- Distribute Display and Buttons
		},
		children = {
			-- === DISPLAY AREA ===
			el.VBox({
				style = {
					w = "100%",
					h = "25%", -- Fixed height percentage
					minHeight = 120, -- Safety minimum
					BGColor = "#1E1E1E",
					justifyContent = "end",
					alignItems = "end",
					padding = 20,
					borderRadius = 10,
				},
				children = {
					el.Text(history, { style = { fontSize = 24, color = "#888888", marginBottom = 10 } }),
					el.Text(display, { style = { fontSize = 56, color = "#FFFFFF" } }),
				},
			}),

			-- === BUTTONS CONTAINER ===
			el.VBox({
				style = {
					w = "100%", -- Ensure full width
					flexGrow = 1, -- Take remaining height
					gap = 5,
				},
				children = {
					-- ROW 1
					el.HBox({
						style = {
							w = "100%", -- Force full width
							flexGrow = 1, -- Expand Height
							gap = 5,
							alignItems = "stretch", -- CRITICAL: Forces buttons to fill row height
						},
						children = {
							CalcButton("C", "#D9534F", 3, onClear),
							CalcButton("/", "#F0AD4E", 1, function()
								onOp("/")
							end),
						},
					}),
					-- ROW 2
					el.HBox({
						style = { w = "100%", flexGrow = 1, gap = 5, alignItems = "stretch" },
						children = {
							CalcButton("7", "#333", 1, function()
								onNum("7")
							end),
							CalcButton("8", "#333", 1, function()
								onNum("8")
							end),
							CalcButton("9", "#333", 1, function()
								onNum("9")
							end),
							CalcButton("x", "#F0AD4E", 1, function()
								onOp("*")
							end),
						},
					}),
					-- ROW 3
					el.HBox({
						style = { w = "100%", flexGrow = 1, gap = 5, alignItems = "stretch" },
						children = {
							CalcButton("4", "#333", 1, function()
								onNum("4")
							end),
							CalcButton("5", "#333", 1, function()
								onNum("5")
							end),
							CalcButton("6", "#333", 1, function()
								onNum("6")
							end),
							CalcButton("-", "#F0AD4E", 1, function()
								onOp("-")
							end),
						},
					}),
					-- ROW 4
					el.HBox({
						style = { w = "100%", flexGrow = 1, gap = 5, alignItems = "stretch" },
						children = {
							CalcButton("1", "#333", 1, function()
								onNum("1")
							end),
							CalcButton("2", "#333", 1, function()
								onNum("2")
							end),
							CalcButton("3", "#333", 1, function()
								onNum("3")
							end),
							CalcButton("+", "#F0AD4E", 1, function()
								onOp("+")
							end),
						},
					}),
					-- ROW 5
					el.HBox({
						style = { w = "100%", flexGrow = 1, gap = 5, alignItems = "stretch" },
						children = {
							CalcButton("0", "#333", 2, function()
								onNum("0")
							end),
							CalcButton(".", "#333", 1, function()
								onNum(".")
							end),
							CalcButton("=", "#5CB85C", 1, onEqual),
						},
					}),
				},
			}),
		},
	})
end
