function Window()
	return { title = "Vulpis Animation Demo", w = 800, h = 600 }
end

-- Simulation State
local sim = {
	time = 0,
	centerX = 0,
	paused = false,
}

function on_tick(dt)
	if sim.paused then
		return
	end

	sim.time = sim.time + dt

	sim.centerX = sim.centerX + (100 * dt)
	if sim.centerX > 850 then
		sim.centerX = -50
	end

	setState("sim_time", sim.time)
end

-- 2. THE UI
function App()
	-- Subscribe to state updates
	local t = useState("sim_time", 0)
	local isPaused = useState("paused", false)

	-- Sync local state with simulation
	sim.paused = isPaused

	-- Helper to calculate orbiting position
	local function getOrbitStyle(offset_angle, radius, color)
		local speed = 3
		local angle = t * speed + offset_angle

		-- Math.sin/cos create the rotation path
		local localX = math.cos(angle) * radius
		local localY = math.sin(angle) * radius

		return {
			type = "vbox",
			style = {
				-- Absolute positioning is key for free movement
				position = "absolute",
				w = 40,
				h = 40,
				BGColor = color,

				-- Center X moves, Local X orbits
				marginLeft = sim.centerX + localX,
				marginTop = 300 + localY, -- 300 is vertical center
			},
		}
	end

	return {
		type = "vbox",
		style = { w = "100%", h = "100%", BGColor = "#202020" },
		children = {

			-- Orbiting Squares (The "Rotation")
			getOrbitStyle(0, 100, "#FF5252"), -- Red
			getOrbitStyle(math.pi / 2, 100, "#448AFF"), -- Blue
			getOrbitStyle(math.pi, 100, "#69F0AE"), -- Green
			getOrbitStyle(3 * math.pi / 2, 100, "#E040FB"), -- Purple

			-- UI Overlay (Pause Button)
			{
				type = "vbox",
				style = {
					w = "100%",
					alignItems = "center",
					marginTop = 50,
				},
				children = {
					{
						type = "text",
						text = "Orbiting Animation Demo",
						style = { fontSize = 32, color = "#FFFFFF", marginBottom = 20 },
					},
					{
						type = "vbox",
						onClick = function()
							setState("paused", not isPaused)
						end,
						style = {
							w = 150,
							h = 50,
							BGColor = isPaused and "#4CAF50" or "#FF5722",
							alignItems = "center",
							justifyContent = "center",
						},
						children = {
							{
								type = "text",
								text = isPaused and "RESUME" or "PAUSE",
								style = { fontSize = 18, color = "white" },
							},
						},
					},
				},
			},
		},
	}
end
