local function GetAllMexes()
    if WG then
        return WG.metalSpots or {}
    else
        return GG.metalSpots or {}
    end
end

-- ID -> index map
local mexIDs = {}
local idCount = 0
for i = 1, #GetAllMexes() do
    idCount = idCount + 1
    mexIDs[idCount] = i
end

local function GetMex(objectID)
    local index = mexIDs[objectID]
    return GetAllMexes()[index]
end

local function GetClosestMetalSpot(x, z) --is used by single mex placement, not used by areamex
	local bestSpot
	local bestDist = math.huge
	local bestID
	for mexID, _ in pairs(mexIDs) do
		local spot = GetMex(mexID)
		local dx, dz = x - spot.x, z - spot.z
		local dist = dx*dx + dz*dz
		if dist < bestDist then
			bestSpot = spot
			bestDist = dist
			bestID = mexID
		end
	end
	return bestSpot, math.sqrt(bestDist), bestID
end

MexBridge = ObjectBridge:extends{}
MexBridge.humanName                    = "Mex"
MexBridge.NoHorizontalDrag             = true
MexBridge.ValidObject                = function(objectID)
    return GetMex(objectID) ~= nil
end

MexBridge.GetObjectAt                  = function(x, z)
    local spot, dist, index = GetClosestMetalSpot(x, z)
    if dist < 50 then
        return index
    end
end

MexBridge.OnLuaUIAdded = function(objectID, object)
    mexBridge.s11n:Add(object, objectID)
    WG.UpdateMexDrawList()
end
MexBridge.OnLuaUIRemoved = function(objectID)
    mexBridge.s11n:Remove(objectID)
    WG.UpdateMexDrawList()
end
MexBridge.OnLuaUIUpdated = function(objectID, name, value)
    mexBridge.s11n:Set(objectID, name, value)
    WG.UpdateMexDrawList()
end

local function DrawLines(x1, x2, z1, z2, by)
    gl.Vertex(x1, by, z1)
    gl.Vertex(x2, by, z1)
    gl.Vertex(x2, by, z2)
    gl.Vertex(x1, by, z2)
    gl.Vertex(x1, by, z1)
end
MexBridge.DrawSelected                    = function(objectID)
    local pos = mexBridge.s11n:Get(objectID, "pos")
    local x1, x2 = pos.x - 20, pos.x + 20
    local z1, z2 = pos.z - 20, pos.z + 20
    gl.BeginEnd(GL.LINE_STRIP, DrawLines, x1, x2, z1, z2, pos.y)
end

mexBridge = MexBridge()
MexS11N = s11n:MakeNewS11N("mex")
function MexS11N:OnInit()
    self.funcs = {
        pos = {
            get = function(objectID)
                local metalSpot = GetMex(objectID)
                return {x = metalSpot.x, y = metalSpot.y, z = metalSpot.z}
            end,
            set = function(objectID, value)
                local metalSpot = GetMex(objectID)
                metalSpot.x = value.x
                metalSpot.z = value.z
                metalSpot.y = Spring.GetGroundHeight(value.x, value.z)
            end,
        },
        metal = {
            get = function(objectID)
                local metalSpot = GetMex(objectID)
                return metalSpot.metal
            end,
            set = function(objectID, value)
                local metalSpot = GetMex(objectID)
                metalSpot.metal = value
            end,
        },
    }
end
-- FIXME: Disable setting fields afterwards (faster)
function MexS11N:CreateObject(object, objectID)
    table.insert(GetAllMexes(), object)
    if not objectID then
        idCount = idCount + 1
        objectID = idCount
    end
    mexIDs[objectID] = #GetAllMexes()
    return objectID
end
function MexS11N:DestroyObject(objectID)
    -- remap ID -> index
    local index = mexIDs[objectID]
    mexIDs[objectID] = nil
    for k, v in pairs(mexIDs) do
        if v > index then
            mexIDs[k] = v - 1
        end
    end
    table.remove(GetAllMexes(), index)
end

function MexS11N:GetAllObjectIDs()
    local IDs = {}
    for mexID, _ in pairs(mexIDs) do
        table.insert(IDs, mexID)
    end
    return IDs
end


mexBridge.s11n = MexS11N()

ObjectBridge.Register("mex", mexBridge)
