local LedgeHandler = {}

local starterPlayer = game:GetService('StarterPlayer')
local playerService = game:GetService('Players')
local debrisService = game:GetService('Debris')

local Modules = starterPlayer.StarterPlayerScripts.Modules
local MovementConfiguration = require(Modules.Movement.MovementConfiguration)
local PlayerState = require(Modules.PlayerState)

local player = playerService.LocalPlayer

local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- PRIVATE

function createRayToFindPart()
    if not player.Character then return end

    raycastParams.FilterDescendantsInstances = {player.Character, workspace.grips}

    local originPart = player.Character[MovementConfiguration.Ledge_OriginPart]
    local originPos = originPart.Position

    local offsetY = 0.1  -- Ajuste inicial en Y

    local lastRaycast

    while true do
        local raycast = workspace:Raycast(
            Vector3.new(originPos.X, originPos.Y + offsetY, originPos.Z),
            originPart.CFrame.LookVector * MovementConfiguration.Ledge_MaxRayDistance,
            raycastParams)

        if raycast and raycast.Instance:IsA('BasePart') then
            lastRaycast = raycast
            offsetY = offsetY + 0.1 -- Incrementar la posición en Y para el próximo raycast
        else
            break  -- Salir del bucle si no hay intersección o no es una BasePart
        end
    end

    if lastRaycast then
        local result = {
            StartPos = originPos,
            Raycast = lastRaycast
        }

        return result
    else
        return nil
    end
end

function findTheNearestLedge(findRayData)
    if not player.Character then return end
    if not findRayData then return end
    
    local rayPos = findRayData.Raycast.Position

    local ledgeYDistance = math.abs(player.Character[MovementConfiguration.Ledge_OriginPart].Position.Y - rayPos.Y)
    
    local ledgeCFrame = CFrame.new(rayPos, rayPos + (-findRayData.Raycast.Normal))

    return {
        LedgeCFrame = ledgeCFrame,
        LedgeYDistance = ledgeYDistance
    }
end

function createNeonPart(cframe, distanceYFromChar)
    local part = Instance.new("Part", workspace.grips)
    part.Size = Vector3.new(.5, .5, .5)
    part.BrickColor = distanceYFromChar > MovementConfiguration.Ledge_MaxYDistance and BrickColor.new("Bright red") or distanceYFromChar < MovementConfiguration.Ledge_MinYDistance and BrickColor.new("Bright red") or BrickColor.new("Bright blue")

    part.Material = Enum.Material.Neon
    part.Anchored = true
    part.CanCollide = false
    part.CFrame = cframe

    debrisService:AddItem(part, 0.3)
end

-- PUBLIC

function LedgeHandler.handler()
    if PlayerState.isClimbing then return end
    
    local findRayData = createRayToFindPart()
    local ledgeData = findTheNearestLedge(findRayData)

    if ledgeData then
        createNeonPart(ledgeData.LedgeCFrame, ledgeData.LedgeYDistance)

        if ledgeData.LedgeYDistance > MovementConfiguration.Ledge_MaxYDistance then
            MovementConfiguration.availableLedge = false
            MovementConfiguration.currentLedge = nil
            return
        end

        MovementConfiguration.availableLedge = true
        MovementConfiguration.currentLedge = ledgeData
        -- ledgeYMin es provisional, mejor hacer un sufacegui y ver cuanto es la y distance del que se posiciona mal y poner el numero correctamente o hacer otra funcion para quitar esa part falsa
    else
        MovementConfiguration.availableLedge = false
        MovementConfiguration.currentLedge = nil
    end
end

return LedgeHandler