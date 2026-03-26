local router = require("utils.core.router")

-- Import the component functions
local LoginScreen = require("login")
local DossierScreen = require("dossier")

function Window()
	return { title = "Vulpis // OS", w = 900, h = 650, resizable = true }
end

-- Register them with the router
router.define({
	["/"] = LoginScreen,
	["/dossier"] = DossierScreen,
})

function App()
	return router.render()
end
