local Knit = require(game.ReplicatedStorage.Packages.knit)
local janitor = require(game.ReplicatedStorage.Packages.janitor)

local Players = game:GetService("Players")
local BehaviorController = Knit.CreateController { Name = "BehaviorController" }

function BehaviorController:DispatchSignal(target_controller: string, data: any)
    local Controller = Knit.GetController(target_controller or ""); assert(Controller)
    return Controller:ReciveSignal(data)
end

function BehaviorController:Listen(connection: any)
    self._janitor:Add(connection)
end

function BehaviorController:KnitStart()
    local Player = Players.LocalPlayer

    -- Janitor Seutp
    self._janitor = janitor.new()
    local function wrapPlayerLeft()
        self._janitor:Cleanup()
        warn(self.Name .. " stopped at " .. os.clock())
    end
    Player.Destroying:Connect(wrapPlayerLeft)
    ---------------

    -- Signal Recive Setup
    local function ActivateBehaviorWrapper(component_instance: Instance, behavior_name: string, controller: string)
        self:DispatchSignal(controller, {
            Instance = component_instance,
            Behavior = behavior_name,
            Index = "Activate"
        })
    end
    local function DeactivateBehaviorWrapper(component_instance: Instance, behavior_name: string, controller: string)
        self:DispatchSignal(controller, {
            Instance = component_instance,
            Behavior = behavior_name,
            Index = "Deactivate"
        })
    end

    local BehaviorService = Knit.GetService("BehaviorService")
    self:Listen(BehaviorService.ActivateBehavior:Connect(ActivateBehaviorWrapper))
    self:Listen(BehaviorService.DeactivateBehavior:Connect(DeactivateBehaviorWrapper))
    ------------------------

    warn(self.Name .. " started at " .. os.clock())
end

return BehaviorController
