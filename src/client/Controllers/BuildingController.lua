local ProximityPromptService = game:GetService("ProximityPromptService")
local Knit = require(game.ReplicatedStorage.Packages.knit)
local Janitor = require(game.ReplicatedStorage.Packages.janitor)
local Promise = require(game.ReplicatedStorage.Packages.promise)

local BuildingController = Knit.CreateController { Name = "BuildingController"; IsBuilding = false }

function BuildingController:ActivateBuilding()
    return Promise.new(function(resolve, reject)
        local HEIGHT = 0
        local GRID_SIZE = 2
        local CREATION = workspace:FindFirstChild("Creation") -- to change to CreationController:GetCreation() maybe?
        local CameraController = Knit.GetController("CameraController")

        CameraController.UpdateProperties({
            CameraType = Enum.CameraType.Watch;
            CameraSubject = CREATION.PrimaryPart;
        })
    end)
end

function BuildingController:DeactivateBuilding()
    return Promise.new(function(resolve, reject)
        local CameraController = Knit.GetController("CameraController")
        local Player = game:GetService("Players").LocalPlayer

        CameraController.UpdateProperties({
            CameraType = Enum.CameraType.Custom;
            CameraSubject = Player.Character.Humanoid;
        })
    end)
end

function BuildingController:Reload()
    print(self.IsBuilding)
    if (self.IsBuilding == false) then
        self:DeactivateBuilding()
    else
        self:ActivateBuilding()
    end
end

function BuildingController.SwitchBuilding()
    print("Building Mode was Changed")
    BuildingController.IsBuilding = not BuildingController.IsBuilding
    BuildingController:Reload()
end

function BuildingController:ConnectServiceSignal(signal_name: string, wrapper: any)
    local BuildingService = Knit.GetService("BuildingService")
    local Signal = BuildingService[signal_name]; assert(Signal)

    self._janitor:Add(Signal:Connect(wrapper))
end

function BuildingController:KnitStart()
    self._janitor = Janitor.new()

    task.defer(function()
        self:ConnectServiceSignal("SwitchBuilding", self.SwitchBuilding)
    end)
    warn(self.Name .. " started at " .. os.clock())
end
return BuildingController
