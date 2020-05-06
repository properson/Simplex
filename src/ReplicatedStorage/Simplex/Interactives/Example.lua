--[[

	The example/template interaction. It basically only prints to the console.
	Includes a basic hook which 

]]

return {
	-- Data
	Name = "Example", -- The internal name for this interaction
	DisplayName = "(Example) Print to console", -- The name displayed to the user
	
	-- Gameplay
	HoldDelay = 0, -- How long the key must be held down for it to activate
	DisableAfterUse = false -- If true, the interaction will not be able to be used again until set
}