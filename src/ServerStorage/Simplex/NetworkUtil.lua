--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- An easy RemoteEvent and RemoteFunction manager.
-- This module has been modified for use with Simplex: The easy-to-use interaction system.

local NetworkUtil = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local networkCache = {
	Event = {},
	Function = {},
}
local remoteFolder

local Simplex
local REMOTE_FOLDER_NAME = "Network"

function NetworkUtil:GetRemoteEvent(name)
	if networkCache.Event[name] then
		Simplex:Debug(nil, "RemoteEvent", name, "already exists")
		return networkCache.Event[name]
	end

	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = remoteFolder

	return remoteEvent
end

function NetworkUtil:GetRemoteFunction(name)
	if networkCache.Function[name] then
		Simplex:Debug(nil, "RemoteFunction", name, "already exists")
		return networkCache.Function[name]
	end

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = remoteFolder

	return remoteFunction
end

function NetworkUtil:Init(simplex)
	Simplex = simplex
	if not ReplicatedStorage.Simplex:FindFirstChild(REMOTE_FOLDER_NAME) then
		local rmFolder = Instance.new("Folder")
		rmFolder.Name = REMOTE_FOLDER_NAME
		rmFolder.Parent = ReplicatedStorage.Simplex
		remoteFolder = rmFolder
	end
end

return NetworkUtil