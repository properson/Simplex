--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- The core system for Simplex on the server.

--[[

	local Simplex = _G.Simplex.Core

	Simplex::Create
		Registers an interactive. Automatically adds respective CollectionService tags.
			[Instance] part,
				The BasePart used to adorn and service the interactive
			[String] interactiveType,
				The type of interactive that will be used. (e.g. EnterVehicle, OpenDoor)
			[optional:Function] finishCallback,
				The callback to be executed after the interactive has fired its Finished event
				(NOT what you're thinking of, the function (e.g. open a door) is located in the interactive's
				Callback module.)

	Simplex::Destroy
		Unregisters an interactive and removes all references. This function is called automatically
		when the interactive's adornee is de-parented.
			[multiple:InteractiveObject/Instance] interactive,
				The interactive to destroy.	Can be set to a part wrapped with an interactive, if it exists.

--]]

local SimplexCore = {}

local interactiveCache = {}

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local Simplex
local FinishInteractiveEvent
local ServerInteractive
local Interactives

local COLLECTION_SERVICE_TAG = "Interaction"
local PREFIXES = {
	Name = "Name:"
}

-- Attempts to receive an interaction from it's assigned part.
local function findInteractiveByPart(part)
	for _, data in pairs(interactiveCache) do
		if data.Part == part then
			return data
		end
	end
end

-- Executes when an instance with the tag COLLECTION_SERVICE_TAG has it removed
local function onInstanceRemoved(instance)
	if instance:IsA("BasePart") then
		local entry = findInteractiveByPart(instance)

		if entry then
			entry.Object:Destroy()
			interactiveCache[entry.Object] = nil
		end
	end
end

-- Wraps necessary CollectionService tags for a part.
local function wrapTags(part, interactiveData)
	CollectionService:AddTag(part, COLLECTION_SERVICE_TAG)
	--[[
		Name is a tag reserved for use from clients. It will help with determinating interaction data.

		Why not ValueObjects:
			1. They can cause unnecessary instance clutter.
			2. CollectionService tags are more recent and easy to use.
	]]
	CollectionService:AddTag(part, string.format("%s:%s", PREFIXES.Name, interactiveData.Name))
end

function SimplexCore:Setup()
	FinishInteractiveEvent.OnServerEvent:Connect(function(player, part)
		local entry = findInteractiveByPart(part)

		if entry then
			if not entry.Object:CanPlayerActivate(player) then
				return
			end

			entry.Object:Activate(player)
		end
	end)
end

function SimplexCore:Create(part, interactiveType, finishCallback)
	local assignedTable = {}
	local interactive = Interactives[interactiveType]
	local id = interactive.Name..HttpService:GenerateGUID()

	local newInteractive = ServerInteractive.new(part, interactiveType, id)
	assignedTable.Name = interactive.Name
	assignedTable.ID = id
	assignedTable.Object = newInteractive
	assignedTable.Part = part
	interactiveCache[newInteractive] = assignedTable
	wrapTags(assignedTable.Part)

	if type(finishCallback) == "function" then
		newInteractive.Finished:Connect(function(player)
			finishCallback(player, newInteractive)
		end)
	end
end

function SimplexCore:Init(simplex)
	Simplex = simplex

	FinishInteractiveEvent = Simplex.Server.NetworkUtil:GetRemoteEvent("FinishInteractive")
	ServerInteractive = Simplex.Server.ServerInteractive
	Interactives = Simplex.Interactives

	self:Setup()
end

CollectionService:GetInstanceRemovedSignal(COLLECTION_SERVICE_TAG):Connect(onInstanceRemoved)

return SimplexCore