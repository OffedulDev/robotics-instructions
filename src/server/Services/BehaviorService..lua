local Knit = require(game.ReplicatedStorage.Packages.knit)
local Promise = require(game.ReplicatedStorage.Packages.promise)
local janitor = require(game.ReplicatedStorage.Packages.janitor)

local CollectionService = game:GetService("CollectionService")
local BehaviorService = Knit.CreateService {
    Name = "BehaviorService",
    Client = {
        ActivateBehavior = Knit.CreateSignal(),
        DeactivateBehavior = Knit.CreateSignal()
    },
    ComponentsData = require(script.Parent.Parent.Modules.Behaviors),
    Components = {}
}

function BehaviorService:CreateBehaviorObject(behavior: string, controller: string, component_instance: Instance, created_at: number)

    local BehaviorObject = {
        Name = behavior or "NotGiven",
        Controller = controller,
        Clock = created_at,
        Instance = component_instance
    }
    local function CleanBehavior()
        if (BehaviorObject.Attached_Player == nil) then return end
        self.Client.DeactivateBehavior:Fire(BehaviorObject.Attached_Player, BehaviorObject.Name, BehaviorObject.Controller)    
    end
    local function ActivateBehavior(requesting_player: Player)
        if not (BehaviorObject.Attached_Player == nil) then
            BehaviorObject.CleanBehavior()
        end
        self.Client.ActivateBehavior:Fire(requesting_player, BehaviorObject.Instance, BehaviorObject.Name, BehaviorObject.Controller)
        
        BehaviorObject.Attached_Player = requesting_player
    end

    BehaviorObject.CleanBehavior = CleanBehavior
    BehaviorObject.ActivateBehavior = ActivateBehavior
    warn("BehaviorObject " .. BehaviorObject.Name .. " created at " .. math.round(BehaviorObject.Clock))

    return BehaviorObject
end

function BehaviorService:GetBehaviorObject(behavior_name: string, opposite_controller: string, component_instance: Instance)
    return self:CreateBehaviorObject(behavior_name, opposite_controller, component_instance, os.clock())
end

function BehaviorService:ReloadComponents()
     local Components = CollectionService:GetTagged("Component")
     local Rendered_Components = {}

     for _, Component in ipairs(Components) do
        local ComponentData = {}
        for _, v in ipairs(self.ComponentsData) do
            if (CollectionService:HasTag(Component, v.Tag)) then
                ComponentData = v
                break
            end
        end

        local BehaviorObject = self:GetBehaviorObject(ComponentData.Tag, ComponentData.Controller, Component)
        table.insert(Rendered_Components, BehaviorObject)
     end

     self.Components = Rendered_Components
end

function BehaviorService:KnitStart()
    self:ReloadComponents()

    --testing
    task.spawn(function()
        task.wait(5)
        print("activating stuff")
        for _, cp in ipairs(self.Components) do
            cp.ActivateBehavior(game:GetService("Players").ActualStudios)
        end
    end)

    warn(self.Name .. " started at " .. os.clock())
end

return BehaviorService
