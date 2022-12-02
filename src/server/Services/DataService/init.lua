local Knit = require(game.ReplicatedStorage.Packages.knit)
local janitor = require(game.ReplicatedStorage.Packages.janitor)
local promise = require(game.ReplicatedStorage.Packages.promise)

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
    Chace = {},
    Queue = {},

    Datastore = game:GetService("DataStoreService"):GetDataStore("STORE_DATA_1")
}

function DataService.Client:LoadKey(key: string)
    return self:LoadKey(key)
end

function DataService:LoadKey(key: string)
    if not (self.Chace[key] == nil) then
        return self.Chace[key]
    end

    local data = self.Datastore:GetAsync(key);

    self.Chace[key] = data
    return data
end

function DataService:AddToQueue(key: string, data: any)
    table.insert(self.Queue, data)

    if (#self.Queue == 1) then
        return promise.new(function(resolve, reject)
            self.Datastore:SetAsync(key, data)
            table.clear(self.Queue)
            resolve()
        end)
    else
        return promise.new(function(resolve, reject)
            repeat task.wait() until #self.Queue == 1
            self.Datastore:SetAsync(key, data)

            table.remove(self.Queue, 1)
            resolve()
        end)
    end
end

-- Player Support

function DataService:EditPlayer(player: Player, key: string, new_value: any)
    local data = self:LoadKey(player.UserId); assert(data, "Tried editing player, but there isn't a player?")

    data[key] = new_value
    self:AddToQueue(player.UserId, data)
end

function DataService:RegisterPlayerTemplate(player: Player)
    local template = require(script.Template)
    self:AddToQueue(player.UserId, template)
end

function DataService:GetPlayerData(player: Player)
    local data = self:LoadKey(player.UserId)

    return data
end



function DataService:KnitStart()
    self._janitor = janitor.new()

    self._janitor:Add(game:GetService("Players").PlayerAdded:Connect(function(player)
        local data = self:LoadKey(player.UserId)

        if (data == nil) then
            self:RegisterPlayerTemplate(player)
        end
    end))
    warn("DataService idle at " .. os.clock())
end

return DataService
