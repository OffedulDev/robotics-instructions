local Players = game:GetService("Players")
local Knit = require(game.ReplicatedStorage.Packages.knit)

local UserInputService = Knit.CreateService {
    Name = "UserInputService",
    Client = {
        InputBegan = Knit.CreateSignal();
        InputChanged = Knit.CreateSignal();
        InputEnded = Knit.CreateSignal();
    },
}

function UserInputService:KnitStart()
    task.defer(function()
        self.Client.InputBegan:Connect(function(player: Player, input: table)
            if (input.UserInputType == "Keyboard" and input.Keycode == "G") then
                warn("Firing Building Mode")
                local BuildingService = Knit.GetService("BuildingService")
                BuildingService:SwitchBuilding(player)
            end
        end)
    end)
    warn(self.Name .. " started at " .. os.clock())
end

return UserInputService
