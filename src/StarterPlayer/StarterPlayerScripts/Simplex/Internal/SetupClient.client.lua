--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- Registers global variables for the client.
-- Side note: _G IS NOT BAD IN MOST CASES WeirdChamp

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SIMPLEX_FOLDERS = {
	shared = ReplicatedStorage:WaitForChild("Simplex"),
	client = script.Parent.Parent
}
local DEBUG_ENABLED = true

local Simplex = {
	Shared = {},
	Client = {},
	Player = game:GetService("Players").LocalPlayer
}
_G.Simplex = Simplex

local function parseDebugString(...)
	return ("$SimplexClient:%s -> %s"):format(getfenv(3).script.Name, tostring(...))
end
function Simplex.Debug(_, msgType, ...)
	if not DEBUG_ENABLED then return end
	local parsed = parseDebugString(...)
	
	if msgType then
		if msgType:lower() == "error" then
			error(parsed)
			return
		elseif msgType:lower() == "warn" then
			warn(parsed)
			return
		end
	end
	
	print(parsed)
end
function Simplex.Wrap(_, module)
	if not module:IsA("ModuleScript") then
		return
	end
	
	if type(module.Init) == "function" then
		module:Init()
	end
end
function Simplex.GetCharacter()
	local character = Simplex.Player.Character or Simplex.Player.CharacterAdded:Wait()
	return character
end

local function initializeEnvironment(name)
	local success, err = pcall(function()
		for _, resource in ipairs(SIMPLEX_FOLDERS[name:lower()]:GetChildren()) do
			if resource:IsA("ModuleScript") then
				local requiredResource = require(resource)
				Simplex[name][resource.Name] = requiredResource
			end
		end
	end)
	
	if not err then
		Simplex:Debug(nil, "Successfully registered resources: args[1]:"..name)
	else
		Simplex:Debug("warn", ("An error occurred while registering resources:\n%s"):format(err))
	end
end

local function initializeAll()
	local function init(obj)
		for str, object in pairs(obj) do
			if type(object) == "table" then
				if type(object.Init) == "function" then
					object:Init(Simplex)
				end
			else
				init(object)
			end
		end
	end
	
	init(Simplex.Client)
	init(Simplex.Shared)
end

local interactives = {}
local function registerInteractives()
	local folder = SIMPLEX_FOLDERS.shared.Interactives
	
	for _, module in ipairs(folder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local required = require(module)
			interactives[module.Name] = required
		end
	end
	
	Simplex:Debug(nil, "Registered shared interactives")
end

initializeEnvironment("Shared")
initializeEnvironment("Client")
registerInteractives()

_G.Simplex.Interactives = interactives

initializeAll()