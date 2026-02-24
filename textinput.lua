local elements = require("utils.core.elements")
local store = require("utils.core.store")

-- ==========================================
-- 1. TIMERS & SETTINGS
-- ==========================================
local backspace_timer = 0
local REPEAT_DELAY = 0.4 -- Hold for 0.4 seconds before it starts auto-deleting
local REPEAT_RATE = 0.04 -- Delete a character every 0.04 seconds once repeating

-- ==========================================
-- 2. DEFINE THE TEXT STORE
-- ==========================================
local useTextStore = store.create(function(set, get)
	return {
		text = "",
		modifiers = "None",

		typeCharacter = function(char)
			set({ text = get().text .. char })
		end,

		backspace = function()
			local current = get().text
			if #current > 0 then
				set({ text = string.sub(current, 1, -2) })
			end
		end,

		setModifiers = function(mod_str)
			set({ modifiers = mod_str })
		end,
	}
end)

-- ==========================================
-- 3. WINDOW CONFIG
-- ==========================================
function Window()
	return { title = "Typing & Modifier Test", mode = "windowed", w = 800, h = 600, resizable = true }
end

-- ==========================================
-- 4. GLOBAL INPUT HOOKS
-- ==========================================
function on_text_input(char)
	useTextStore().typeCharacter(char)
end

function on_key_down(key, mods)
	if key == "Backspace" then
		useTextStore().backspace()
		backspace_timer = 0 -- Reset the hold timer if they tap the key manually
	end
end

function on_tick(dt)
	local actions = useTextStore()

	-- ---------------------------------------------------------
	-- FEATURE 1: Custom Backspace Key Repeat Logic
	-- ---------------------------------------------------------
	if vulpis.isKeyHeld("Backspace") then
		backspace_timer = backspace_timer + dt

		-- If we have held it longer than the initial delay...
		if backspace_timer > REPEAT_DELAY then
			-- Use a while loop to handle high-framerate/low-framerate consistency
			while backspace_timer > REPEAT_DELAY + REPEAT_RATE do
				actions.backspace()
				-- Subtract the rate so the timer loops perfectly
				backspace_timer = backspace_timer - REPEAT_RATE
			end
		end
	else
		-- Instantly reset the timer when the key is released
		backspace_timer = 0
	end

	-- ---------------------------------------------------------
	-- FEATURE 2: Real-time Modifier Polling
	-- ---------------------------------------------------------
	local m = {}
	if vulpis.isKeyHeld("Left Ctrl") or vulpis.isKeyHeld("Right Ctrl") then
		table.insert(m, "Ctrl")
	end
	if vulpis.isKeyHeld("Left Shift") or vulpis.isKeyHeld("Right Shift") then
		table.insert(m, "Shift")
	end
	if vulpis.isKeyHeld("Left Alt") or vulpis.isKeyHeld("Right Alt") then
		table.insert(m, "Alt")
	end

	local mod_str = #m > 0 and table.concat(m, " + ") or "None"

	-- Only update the store if the modifier state actually changed!
	if actions.modifiers ~= mod_str then
		actions.setModifiers(mod_str)
	end
end

-- ==========================================
-- 5. UI RENDERER
-- ==========================================
function App()
	local state = useTextStore()

	return elements.VBox({
		style = {
			w = 800,
			h = 600,
			padding = 50,
			gap = 30,
			BGColor = "#1E1E24",
			alignItems = "center",
			justifyContent = "center",
		},
		children = {
			elements.Text("Start typing below:", { fontSize = 24, color = "#888899" }),

			-- Display the typed text
			elements.Text(state.text .. "_", { fontSize = 48, color = "#00FFCC" }),

			-- Display the real-time modifier keys
			elements.Text("Modifiers Held: " .. state.modifiers, { fontSize = 20, color = "#FF9999" }),
		},
	})
end
