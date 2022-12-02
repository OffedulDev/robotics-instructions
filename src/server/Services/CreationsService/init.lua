local Knit = require(game.ReplicatedStorage.Packages.knit)
local janitor = require(game.ReplicatedStorage.Packages.janitor)


local CollectionService = game:GetService("CollectionService")
local CreationsService = Knit.CreateService {
    Name = "CreationsService",
    Client = {},
}

function CreationsService:AnchorModel(model: Model, condition: boolean)
    condition = condition or true

    for _,v in ipairs(model:GetChildren()) do
        if (v:IsA("Model")) then
            self:AnchorModel(v, condition)
            continue
        end

        pcall(function()
            v.Anchored = condition
        end)
    end
end

function CreationsService:WeldModel(model: Model, to: Part)
    for _,v in ipairs(model:GetChildren()) do
        if (v:IsA("Model")) then
            self:WeldModel(v, to)
            continue
        end

        pcall(function()
            local wc = Instance.new("WeldConstraint", model)
            wc.Part0 = v
            wc.Part1 = to
        end)
    end
end

function CreationsService:RenderCreations()
    local Creations = CollectionService:GetTagged("Creation")
    local ComponentsService = Knit.GetService("BehaviorService")

    for _, Creation in ipairs(Creations) do
        assert(Creation:IsA("Model"), "Creation isn't a model.")

        --self:AnchorModel(Creation)
        self:WeldModel(Creation, Creation.PrimaryPart)
        --self:AnchorModel(Creation, false)
    end
end

function CreationsService:Listen(connection: any)
    self._janitor:Add(connection)
end

function CreationsService:KnitStart()
    self._janitor = janitor.new()
    self:RenderCreations()


    self:Listen(CollectionService.TagAdded:Connect(function(instance, tag)
        if (tag == "Creation") then
            self:RenderCreations()
        end
    end))
    self:Listen(CollectionService.TagRemoved:Connect(function(instance, tag)
        if (tag == "Creation") then
            self:RenderCreations()
        end
    end))

    warn(self.Name .. " started at " .. os.clock())    
end

return CreationsService
