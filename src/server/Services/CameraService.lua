local Knit = require(game.ReplicatedStorage.Packages.knit)
local Promise = require(game.ReplicatedStorage.Packages.promise)

local CameraService = Knit.CreateService {
    Name = "CameraService",
    Client = {
        UpdateProperties = Knit.CreateSignal()
    },
}

function CameraService:UpdateCameraProperties(player: Player, properties: table)
    return Promise.new(function(resolve, reject)
        resolve(self.Client.UpdateProperties:Fire(player, properties))
    end):catch(warn)
end

function CameraService:SwitchCameraPreset(player: Player, preset: string)
    local PresetModule = script.Parent.Parent.Modules:FindFirstChild(preset); assert(PresetModule)
    
    return Promise.new(function(resolve)
        resolve(self:UpdateProperties(require(PresetModule)))
    end):andThen(function()
        warn("Switched to Camera Preset " .. preset)
    end):catch(warn)
end

function CameraService:KnitStart()
    warn(self.Name .. " started at " .. os.clock())
end
return CameraService
