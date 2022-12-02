local ProximityPromptService = game:GetService("ProximityPromptService")
local Knit = require(game.ReplicatedStorage.Packages.knit)
local Janitor = require(game.ReplicatedStorage.Packages.janitor)
local Promise = require(game.ReplicatedStorage.Packages.promise)

local CameraController = Knit.CreateController { Name = "CameraController" }
local Player = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera

function CameraController.UpdateProperties(properties)
    local ctype = properties.CameraType
    local cframe = properties.CFrame
    local csubject = properties.CameraSubject

    local _prop_promise = Promise.new(function(resolve, reject)
        Camera.CameraType = ctype
        Camera.CFrame = cframe or Camera.CFrame
        Camera.CameraSubject = csubject
        resolve()
    end)

    _prop_promise:catch(warn)
end

function CameraController:ConnectServiceSignal(signal_name: string, wrapper: any)
    local CameraService = Knit.GetService("CameraService")
    local Signal = CameraService[signal_name]; assert(Signal)

    self._janitor:Add(Signal:Connect(wrapper))
end

function CameraController:KnitStart()
    self._janitor = Janitor.new()

    task.defer(function()
        self:ConnectServiceSignal("UpdateProperties", self.UpdateProperties)
    end)
    warn(self.Name .. " started at " .. os.clock())
end
return CameraController
