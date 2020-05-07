--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- General character manager.

local Character = {}
Character.Character = nil
Character.CharacterAdded = nil
Character.Connections = {}

local Simplex
local EventManager

local function clearConnections()
    local _debugConnectionCount = #Character.Connections

    for id, connection in ipairs(Character.Connections) do
        if connection.Connected then
            connection:Disconnect()
        end
        table.remove(Character.Connections, id)
    end
    Character.Connections = {}

    Simplex:Debug(nil, ("Successfully disconnected %d signal connections"):format(_debugConnectionCount))
end

local function characterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")

    humanoid.Died:Connect(function()
        clearConnections()
    end)
end

function Character:AddConnection(rbxConnection)
    assert(typeof(rbxConnection) == "RBXScriptSignal", ("rbxConnection must be a RBXScriptSignal, got %s"):format(typeof(rbxConnection)))

    self.Connections[#self.Connections + 1] = rbxConnection
    Simplex:Debug(nil, "Successfully added 1 connection. Remember that all connections are cleared when the character dies.")
end

function Character:Run()
    local player = Simplex.Player

    if player.Character then
        self.Character = player.Character
    else
        self.Character = player.CharacterAdded:Wait()
    end
    self.CharacterAdded:Fire(self.Character)

    player.CharacterAdded:Connect(function(character)
        self.Character = character
        self.CharacterAdded:Fire(character)
    end)
end

function Character:Init(simplex)
    Simplex = simplex
    EventManager = Simplex.Client.EventManager

    self.CharacterAdded = EventManager.CharacterAdded

    self.CharacterAdded:Connect(function(character)
        characterAdded(character)
    end)

    self:Run()
end

return Character