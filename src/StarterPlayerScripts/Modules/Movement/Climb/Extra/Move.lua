local MoveHandler = {}

local starterPlayer = game:GetService('StarterPlayer')
local playerService = game:GetService('Players')
local tweenService = game:GetService('TweenService')

local player = playerService.LocalPlayer

local Modules = starterPlayer.StarterPlayerScripts.Modules
local ClimbSettings = require(Modules.Movement.Climb.ClimbSettings)
local PlayerState = require(Modules.PlayerState)

local MoveStuds = ClimbSettings.MoveStuds

local tweenInfo = TweenInfo.new(
    0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0
)

local tweenCreated

function MoveHandler.Move(key)
    if not player.Character then return end
    if not PlayerState.isClimbing then return end
    if tweenCreated then return end

    local humanoidRootPart = player.Character.HumanoidRootPart
    local newCFrame = CFrame.new(0,0,0)

    if key == 'A' then
        newCFrame =  CFrame.new(-MoveStuds,0,0)
    elseif key == 'D' then
        newCFrame = CFrame.new(MoveStuds,0,0)
    end
    --player.Character.HumanoidRootPart.CFrame *= newCFrame

    tweenCreated = tweenService:Create(
        humanoidRootPart,
        tweenInfo,
        {CFrame = humanoidRootPart.CFrame*newCFrame}
    )

    tweenCreated:Play()
    tweenCreated.Completed:Connect(function(playbackState)
        tweenCreated = nil
    end)

end

return MoveHandler