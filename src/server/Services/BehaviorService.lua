local Knit = require(game.ReplicatedStorage.Packages.knit)
local Promise = require(game.ReplicatedStorage.Packages.promise)
local janitor = require(game.ReplicatedStorage.Packages.janitor)

local CollectionService = game:GetService("CollectionService")
local BehaviorService = Knit.CreateService {
    Name = "BehaviorService",
    Client = {},
    ComponentsData = require(script.Parent.Parent.Modules.Behaviors),
    Components = {}
}

function BehaviorService:CreateBehaviorObject(behavior: string, component_instance: Instance, created_at: number)

    local BehaviorObject = {
        Name = behavior or "NotGiven",
        Clock = created_at,
        Instance = component_instance
    }
    local function ActivateBehavior()
        local BehaviorModule = script.Parent.Parent.Modules:FindFirstChild(BehaviorObject.Name); assert(BehaviorModule)
        pcall(function()
            require(BehaviorModule):Handle(BehaviorObject)
        end)
    end

    BehaviorObject.ActivateBehavior = ActivateBehavior
    warn("BehaviorObject " .. BehaviorObject.Name .. " created at " .. math.round(BehaviorObject.Clock))

    return BehaviorObject
end

function BehaviorService:GetBehaviorObject(behavior_name: string, component_instance: Instance)
    return self:CreateBehaviorObject(behavior_name, component_instance, os.clock())
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

        local BehaviorObject = self:GetBehaviorObject(ComponentData.Tag, Component)
        table.insert(Rendered_Components, BehaviorObject)
     end

     self.Components = Rendered_Components
end

function BehaviorService:KnitStart()
    self:ReloadComponents()

    warn(self.Name .. " started at " .. os.clock())
end

return BehaviorService
