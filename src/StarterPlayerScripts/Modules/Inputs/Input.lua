local InputHandler = {}

local userInputService = game:GetService('UserInputService')
local starterPlayer = game:GetService("StarterPlayer")

local Modules = starterPlayer.StarterPlayerScripts.Modules
local MovementConfiguration = require(Modules.Movement.MovementConfiguration)
local PlayerState = require(Modules.PlayerState)

InputHandler.StartLedgeSignal = Instance.new("BindableEvent")
InputHandler.EndLedgeSignal = Instance.new("BindableEvent")
InputHandler.MoveSignal = Instance.new("BindableEvent")

-- PRIVATE

function HandleInputBegan(input, typing)
    if typing then return end

    if input.KeyCode == Enum.KeyCode.Space then
        if not MovementConfiguration.availableLedge then return end

        if not PlayerState.isClimbing then
            InputHandler.StartLedgeSignal:Fire()
        else
            InputHandler.EndLedgeSignal:Fire()
        end
    elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
        InputHandler.MoveSignal:Fire(userInputService:GetStringForKeyCode(input.KeyCode))
    end
end

-- events
userInputService.InputBegan:Connect(HandleInputBegan)

return InputHandler
