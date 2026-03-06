local elements = require("utils.core.elements")
local TextInput = require("utils.core.textInput")

function App()
	-- Global states for our Controlled components
	local controlledText = useState("test_controlled", "")
	local numericText = useState("test_numeric", "")
	local uppercaseText = useState("test_upper", "")

	-- State to display submissions from Uncontrolled components
	local submittedText = useState("test_submit", "Nothing submitted yet.")

	return elements.VBox({
		style = {
			w = "100%",
			h = "100%",
			padding = 20,
			gap = 10,
			BGColor = "#1e1e2e", -- Dark background for the whole app
			overflow = "scroll",
		},
		children = {
			elements.Text("TextInput Intensive Test Suite", {
				fontSize = 24,
				color = "#a6e3a1",
				fontWeight = "bold",
				marginBottom = 10,
			}),

			-- ==========================================
			-- TEST 1: Uncontrolled + Placeholder + Submit
			-- ==========================================
			elements.Text("1. Uncontrolled (Type & hit Enter):", { color = "#cdd6f4" }),
			TextInput({
				placeholder = "Type here and press enter...",
				theme = "dark",
				onSubmit = function(text)
					setState("test_submit", text)
				end,
			}),

			-- ==========================================
			-- TEST 2: Uncontrolled + DefaultValue
			-- ==========================================
			elements.Text("2. Uncontrolled with Default Value:", { color = "#cdd6f4", marginTop = 10 }),
			TextInput({
				defaultValue = "I am a default value!",
				theme = "light",
				onSubmit = function(text)
					setState("test_submit", text)
				end,
			}),

			-- Result Label for Tests 1 & 2
			elements.Text("Last Submitted: " .. submittedText, { color = "#f38ba8", marginBottom = 10 }),

			-- ==========================================
			-- TEST 3: Fully Controlled (State Mirroring)
			-- ==========================================
			elements.Text("3. Fully Controlled (Mirrors State):", { color = "#cdd6f4", marginTop = 10 }),
			TextInput({
				value = controlledText,
				placeholder = "I mirror the state exactly...",
				theme = "dark",
				onChange = function(newText)
					setState("test_controlled", newText)
				end,
			}),
			elements.Text("Controlled State: " .. controlledText, { color = "#fab387", marginBottom = 10 }),

			-- ==========================================
			-- TEST 4: Controlled + Formatting (Uppercase)
			-- ==========================================
			elements.Text("4. Controlled Formatting (Forces Uppercase):", { color = "#cdd6f4", marginTop = 10 }),
			TextInput({
				value = uppercaseText,
				placeholder = "type lowercase, i force uppercase...",
				theme = "dark",
				onChange = function(newText)
					-- Forcing the state to immediately uppercase whatever is typed
					setState("test_upper", string.upper(newText))
				end,
			}),

			-- ==========================================
			-- TEST 5: Controlled + Validation (Numbers Only)
			-- ==========================================
			elements.Text("5. Controlled Validation (Numbers Only):", { color = "#cdd6f4", marginTop = 20 }),
			TextInput({
				value = numericText,
				placeholder = "Try typing letters (they will fail)...",
				theme = "high_contrast",
				onChange = function(newText)
					-- Only accept if the new text is completely empty OR contains only digits
					if newText == "" or string.match(newText, "^%d+$") then
						setState("test_numeric", newText)
					end
				end,
			}),
			elements.Text("Numeric State: " .. numericText, { color = "#fab387", marginBottom = 10 }),

			-- ==========================================
			-- TEST 6: External State Override (The "Clear" Button)
			-- ==========================================
			elements.Box({
				type = "hbox",
				style = {
					padding = 10,
					BGColor = "#f38ba8",
					w = 200,
					justifyContent = "center",
					marginTop = 20,
					cursor = "pointer",
				},
				onClick = function()
					-- This clears the CONTROLLED states.
					-- You will notice Tests 3, 4, and 5 instantly go blank.
					-- Tests 1 and 2 will keep their text because they are UNCONTROLLED!
					setState("test_controlled", "")
					setState("test_upper", "")
					setState("test_numeric", "")
					setState("test_submit", "Cleared external states!")
				end,
				children = {
					elements.Text("Clear Controlled States", { color = "#1e1e2e", fontWeight = "bold" }),
				},
			}),
		},
	})
end
