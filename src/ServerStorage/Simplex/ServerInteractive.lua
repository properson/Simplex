--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- The server-based object for an interactive.

local ServerInteractive = {}
ServerInteractive.__index = ServerInteractive

local Players = game:GetService("Players")

local Simplex
local Event
local CancelActivatingEvent -- If multiple players were activating the interactive at the same time,
-- then we would call all clients to stop activating it.

local SIMPLEX_CALLBACKS
local DEFAULT_RANGE = 10


function ServerInteractive.new(part, configuration, id)
	local self = setmetatable({
		Part = part,
		ID = id,
		Ready = true,
		Finished = Event.new(),
		_configuration = nil,
		_hook = nil,
	}, ServerInteractive)

	-- Receive the actual configuration
	if SIMPLEX_CALLBACKS[configuration] then
		self._configuration = require(SIMPLEX_CALLBACKS[configuration])
	else
		Simplex:Debug("warn", "Interactive configuration "..configuration.." has no callback.")
	end

	-- Get the hook, if any
	local hookModule = Simplex:GetHook(configuration)
	if hookModule then
		self._hook = hookModule
	end

	return self
end

-- Unnecessary setter?
function ServerInteractive:SetReady(state)
	self.Ready = state
end

function ServerInteractive:HookPass(player)
	local didReturn = self._hook(player, player.Character)
	return didReturn and "Failed" or "Pass"
end

function ServerInteractive:Activate(player)
	-- Extra check (just in case)
	if not self:CanPlayerActivate(player) then
		return
	end

	self.Ready = false

	-- The first-to-activate client can disable the interface by itself
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if player ~= otherPlayer then
			CancelActivatingEvent:FireClient(otherPlayer, self.Part, self.ID)
		end
	end

	if type(self._configuration) == "function" then
		self._configuration(player, player.Character, self.Part)
	end
end

function ServerInteractive:CanPlayerActivate(player)
	if not player.Character then
		return false
	end

	local character = player.Character

	-- Character checks
	if not character:FindFirstChild("Humanoid") then
		return false
	end
	if character.Humanoid.Health <= 0 then
		return false
	end

	-- Position checks
	if (character.HumanoidRootPart.Position - self.Part.Position).Magnitude < DEFAULT_RANGE then
		return false
	end

	-- Self-checks
	if not self.Ready then
		return false
	end

	-- Hook-based checks
	if self:HookPass(player) == "Failed" then
		return false
	end

	return true
end

function ServerInteractive:Destroy()
	self.Finished:Destroy()

	for _, player in ipairs(Players:GetPlayers()) do
		CancelActivatingEvent:FireClient(player, self.Part, self.ID)
	end

	self.Ready = false
end

function ServerInteractive:Setup()
	CancelActivatingEvent = Simplex.Server.NetworkUtil:GetRemoteEvent("CancelActivation")
end

function ServerInteractive:Init(simplex)
	Simplex = simplex
	Event = Simplex.Shared.Event
	SIMPLEX_CALLBACKS = Simplex.Callbacks

	self:Setup()
end

-- Alias for ::Destroy
ServerInteractive.Cleanup = ServerInteractive.Destroy

return ServerInteractive
