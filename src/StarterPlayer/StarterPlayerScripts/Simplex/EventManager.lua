--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- Holds events for the Simplex client.

local EventManager = {}

local Simplex
local Event

local EVENT_LIST = {
    "InteractionInRange",
    "InteractionOutOfRange",
    "InteractionAdded",
    "InteractionRemoved",
    "CharacterAdded"
}

function EventManager:Setup()
    for _, eventName in ipairs(EVENT_LIST) do
        self[eventName] = Event.new()
    end
end

function EventManager:Init(simplex)
    Simplex = simplex
    Event = Simplex.Shared.Event

    self:Setup()
end

return EventManager