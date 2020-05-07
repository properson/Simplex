--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- Registers global variables for the server.
-- Side note: _G IS NOT BAD IN MOST CASES WeirdChamp

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SIMPLEX_FOLDERS = {
	shared = ReplicatedStorage:WaitForChild("Simplex"),
	server = ServerStorage:WaitForChild("Simplex")
}
local DEBUG_ENABLED = true
local HOOK_NAME = "Hook"

local Simplex = {
	Shared = {},
	Server = {},
}
_G.Simplex = Simplex

local function parseDebugString(...)
	return ("$Simplex:%s -> %s"):format(getfenv(3).script.Name, tostring(...))
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
function Simplex.GetHook(self, name)
	local callback = self.Callbacks:FindFirstChild(name)

	if callback then
		local hook = callback:FindFirstChild(HOOK_NAME)

		if hook then
			return require(hook)
		end
	end
end

local function initializeEnvironment(name)
	local _, err = pcall(function()
		for _, resource in ipairs(SIMPLEX_FOLDERS[name:lower()]:GetChildren()) do
			coroutine.wrap(function()
				if resource:IsA("ModuleScript") then
					local requiredResource = require(resource)
					Simplex[name][resource.Name] = requiredResource
				end
			end)()
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
			if type(object) == "table" and str ~= "Server" and str ~= "Shared" then
				if type(object.Init) == "function" then
					object:Init(Simplex)
				end
			else
				init(object)
			end
		end
	end

	init(Simplex.Server)
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
initializeEnvironment("Server")
registerInteractives()

_G.Simplex.Core = Simplex.Server.SimplexCore
_G.Simplex.Callbacks = SIMPLEX_FOLDERS.server.ServerCallbacks
_G.Simplex.Interactives = interactives

initializeAll()