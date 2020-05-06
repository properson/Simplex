-- A basic hook for sitting in a chair. Character will always exist.
-- If the hook does not return anything, the interaction will be activated.
-- Otherwise, it will not run.

return function(_, character)
    if character.Humanoid.Seated then
        return true
    end
end