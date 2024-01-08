local Climb = {}

local starterPlayer = game:GetService('StarterPlayer')
local playerService = game:GetService('Players')
local tweenService = game:GetService('TweenService')

local Modules = starterPlayer.StarterPlayerScripts.Modules
local MovementConfiguration = require(Modules.Movement.MovementConfiguration)
local PlayerState = require(Modules.PlayerState)

local Input = require(Modules.Inputs.Input)
local MoveHandler = require(Modules.Movement.Climb.Extra.Move)

local player = playerService.LocalPlayer

local tweenInfo = TweenInfo.new(
    0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0
)

local tweenRunning

local GripAnim = Modules.Movement.Climb.GripAnim
local LoadedAnims = {}

-- PRIVATE

player.CharacterAdded:Connect(function(character)
    if LoadedAnims ~= {} then LoadedAnims = {} end
    PlayerState.isClimbing = false
end)

-- PUBLIC

function Climb.StartClimb()
    if not player.Character then return end
    if not MovementConfiguration.availableLedge then return end
    if player.Character.Humanoid.FloorMaterial == Enum.Material.Air then return end
    if tweenRunning then tweenRunning:Stop() tweenRunning = nil end

    -- load anim and check
    if not LoadedAnims['GripAnim'] then
        LoadedAnims['GripAnim'] = player.Character.Humanoid.Animator:LoadAnimation(GripAnim)
    end

    LoadedAnims['GripAnim']:Play()

    PlayerState.isClimbing = true
    player.Character.Humanoid.AutoRotate = false

    local characterSize = player.Character:GetExtentsSize()
    MovementConfiguration.currentLedge.LedgeCFrame -= Vector3.new(0, characterSize.Y/3, 0)  -- Ajuste para quitar la altura

    --print('Climbing..')

    local newCFrame = MovementConfiguration.currentLedge.LedgeCFrame * CFrame.new(0, 0, player.Character.HumanoidRootPart.Size.Z/1.5)

    local tweenRunning = tweenService:Create(
        player.Character.HumanoidRootPart,
        tweenInfo,
        {CFrame = newCFrame}
    )
    

    player.Character[MovementConfiguration.Ledge_OriginPart].Anchored = true
    player.Character.Humanoid.PlatformStand = true
    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)

    tweenRunning:Play()

    tweenRunning.Completed:Connect(function(playbackState)
        --print('Climbed')
        tweenRunning = nil
    end)
end

function Climb.EndClimb()
    if not player.Character then return end
    if tweenRunning then tweenRunning:Stop() tweenRunning = nil end
    player.Character[MovementConfiguration.Ledge_OriginPart].Anchored = false
    player.Character.Humanoid.PlatformStand = false
    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
    if LoadedAnims['GripAnim'] then if LoadedAnims['GripAnim'].IsPlaying then LoadedAnims['GripAnim']:Stop() end end
    
    player.Character.HumanoidRootPart.Velocity = Vector3.new(0,50,0)
    PlayerState.isClimbing = false
    player.Character.Humanoid.AutoRotate = true
end

-- events
Input.MoveSignal.Event:Connect(MoveHandler.Move)

return Climb