local items = {
	{ id = 1, text = "Task 1 (Drag to Trash)" },
	{ id = 2, text = "Task 2 (Drag to Trash)" },
	{ id = 3, text = "Task 3 (Drag to Trash)" },
	{ id = 4, text = "Task 4 (Drag to Trash)" },
}

local draggingIndex = nil

function App()
	local itemNodes = {}

	bgcolor = useState("bg", "#000000")

	for i, item in ipairs(items) do
		table.insert(itemNodes, {
			type = "text",
			text = item.text,
			draggable = true,
			style = {
				padding = 15,
				marginBottom = 10,
				BGColor = (draggingIndex == i) and "#333333" or "#444455",
				color = "#FFFFFF",
				w = 200,
			},

			onDragStart = function()
				draggingIndex = i
				setState("draggingIndex", i)
			end,

			onDrag = function(dx, dy)
				setState("bg", "#111111")
			end,

			-- THE MAGIC HAPPENS HERE: We receive the dropTargetId
			onDragEnd = function(dropTargetId, dx, dy)
				setState("bg", "#00000")

				if dropTargetId == "trash_bin" then
					local indexToRemove = useState("draggingIndex", nil)

					if indexToRemove then
						table.remove(items, indexToRemove)
					end
				end

				draggingIndex = nil
			end,
		})
	end

	local trashColor = draggingIndex and "#882222" or "#331111"
	local trashText = draggingIndex and "Drop Here" or "Trash Bin"

	return {
		type = "hbox",
		style = {
			w = "100%",
			h = "100%",
			padding = 40,
			gap = 50,
			BGColor = bgcolor,
		},
		children = {
			{
				type = "vbox",
				style = { w = 250 },
				children = itemNodes,
			},
			{
				type = "vbox",
				id = "trash_bin",
				style = {
					w = 250,
					h = 250,
					BGColor = trashColor,
					justifyContent = "center",
					alignItems = "center",
				},
				children = {
					{
						type = "text",
						text = trashText,
						style = {
							color = "#FFFFFF",
							fontSize = 20,
							fontWeight = "bold",
						},
					},
				},
			},
		},
	}
end

return App()
