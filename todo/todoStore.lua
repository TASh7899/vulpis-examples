local store = require("utils.core.store")

-- A file path where we will save the notes (will be created in the run directory)
local SAVE_FILE = "todos_save.txt"

-- Helper function to save todos to a file
local function saveTodosToFile(todos)
	local file = io.open(SAVE_FILE, "w")
	if file then
		for _, todo in ipairs(todos) do
			-- Save in a simple format: id|_|completed|_|text
			file:write(tostring(todo.id) .. "|_|" .. tostring(todo.completed) .. "|_|" .. todo.text .. "\n")
		end
		file:close()
	else
		print("Warning: Could not open save file for writing.")
	end
end

-- Helper function to load todos from a file
local function loadTodosFromFile()
	local todos = {}
	local file = io.open(SAVE_FILE, "r")
	if file then
		for line in file:lines() do
			-- Parse the simple format
			local id, compStr, text = line:match("^(.-)|_|(.-)|_|(.*)$")
			if id and compStr and text then
				table.insert(todos, {
					id = id,
					completed = (compStr == "true"),
					text = text,
				})
			end
		end
		file:close()
	end
	return todos
end

local useTodoStore = store.create(function(get, set)
	-- Load from file when the store is first created
	local initialTodos = loadTodosFromFile()

	return {
		todos = initialTodos,
		filter = "all", -- Can be 'all', 'active', or 'completed'

		addTodo = function(text)
			if not text or text == "" then
				return
			end
			local state = get()

			local newTodos = {}
			for _, v in ipairs(state.todos) do
				table.insert(newTodos, v)
			end

			local newId = tostring(os.time()) .. tostring(math.random(1000))
			table.insert(newTodos, { id = newId, text = text, completed = false })

			set({ todos = newTodos })
			saveTodosToFile(newTodos) -- Save to disk
		end,

		toggleTodo = function(id)
			local state = get()
			local newTodos = {}
			for _, v in ipairs(state.todos) do
				if v.id == id then
					table.insert(newTodos, { id = v.id, text = v.text, completed = not v.completed })
				else
					table.insert(newTodos, v)
				end
			end

			set({ todos = newTodos })
			saveTodosToFile(newTodos) -- Save to disk
		end,

		deleteTodo = function(id)
			local state = get()
			local newTodos = {}
			for _, v in ipairs(state.todos) do
				if v.id ~= id then
					table.insert(newTodos, v)
				end
			end

			set({ todos = newTodos })
			saveTodosToFile(newTodos) -- Save to disk
		end,

		setFilter = function(newFilter)
			set({ filter = newFilter })
		end,
	}
end)

return useTodoStore
