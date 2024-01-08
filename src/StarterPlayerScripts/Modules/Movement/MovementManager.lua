local MovementManager = {}

local starterPlayer = game:GetService("StarterPlayer")
local runService = game:GetService('RunService')

local Modules = starterPlayer.StarterPlayerScripts.Modules
local LedgeHandler = require(Modules.Movement.Ledge.LedgeHandler)
local Input = require(Modules.Inputs.Input)
local Climb = require(Modules.Movement.Climb.ClimbHandler)

-- events

runService.Heartbeat:Connect(LedgeHandler.handler)
Input.StartLedgeSignal.Event:Connect(Climb.StartClimb)
Input.EndLedgeSignal.Event:Connect(Climb.EndClimb)

return MovementManager