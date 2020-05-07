--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- Handles interaction in-range detection.

local InteractionProximityHandler = {}
InteractionProximityHandler.CharacterHandler = nil
InteractionProximityHandler.NearestPoint = nil

local CollectionService = game:GetService("CollectionService")

local character
local humanoidRoot
local closest
local interactionsAvailable = {}
local hooks = {}

local Simplex
local EventManager
local Character

local INTERACTION_POLL_INTERVAL = 0.125
local COLLECTION_SERVICE_TAG = "Interaction"
local DISABLED_TAG = "Simplex:Disabled" -- Yet again, another tag to kill ValueObjects
local CAMERA = workspace.CurrentCamera

local function addTag(point)
    interactionsAvailable[point] = point
end

local function removeTag(point)
    interactionsAvailable[point] = nil
end

-- Inspired from the endorsed Dune Buggy by Roblox
local function getClosestInteraction()
    if
        character and
        humanoidRoot and
        character.Humanoid.Health > 0
    then
        local closestInter
        local closestDist = math.huge

        for _, point in pairs(interactionsAvailable) do
            if point:IsA("BasePart") then
                local tags = CollectionService:GetTags(point)
                local _, visible = CAMERA:WorldToViewportPoint(point.Position)

                if visible then
                    local dist = (humanoidRoot.Position - point.Position).Magnitude

                    if closestDist < dist and dist < 12.5 and not table.find(tags, DISABLED_TAG) then

                    end
                end
            end
        end
    end
end

-- Runs the handler. Identical to ::Setup
function InteractionProximityHandler:Run()
    CollectionService:GetInstanceAddedSignal(COLLECTION_SERVICE_TAG):Connect(addTag)
    CollectionService:GetInstanceRemovedSignal(COLLECTION_SERVICE_TAG):Connect(removeTag)

    for _, point in ipairs(CollectionService:GetTagged(COLLECTION_SERVICE_TAG)) do
        addTag(point)
    end

    while true do
        local closestInteraction = getClosestInteraction()
        if closestInteraction and closestInteraction ~= closest then
            closest = closestInteraction
            self.NearestPoint = closest
            EventManager.InteractionInRange:Fire(closest)
        elseif closest then
            EventManager.InteractionOutOfRange:Fire(closest)
            self.NearestPoint = nil
        end

        wait(INTERACTION_POLL_INTERVAL)
    end
end

function InteractionProximityHandler:Init(simplex)
    Simplex = simplex
    EventManager = Simplex.Client.EventManager
    Character = require(script.Character)

    Simplex:Wrap(Character)
    self.CharacterHandler = Character

    character = Character.Character or Character.CharacterAdded:Wait()
    humanoidRoot = character:WaitForChild("HumanoidRootPart")
    Character.CharacterAdded:Connect(function(theCharacter)
        character = theCharacter
        humanoidRoot = theCharacter:WaitForChild("HumanoidRootPart")
    end)

    self:Run()
end

return InteractionProximityHandler