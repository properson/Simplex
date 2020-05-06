--|> SIMPLEX | Easy-to-use interaction system <|--

-- ShutoExpressway
-- The client-based object for an interactive.

local ClientInteractive = {}
ClientInteractive.__index = ClientInteractive

local Simplex

function ClientInteractive.new()
	local self = setmetatable({
		
	}, ClientInteractive)
	
	
	
	return self
end

function ClientInteractive:Init(simplex)
	Simplex = simplex
end

return ClientInteractive
