local Knit = require(game.ReplicatedStorage.Packages.knit)
local Player = game:GetService("Players").LocalPlayer
local CubeController = Knit.CreateController { Name = "CubeController" }

function CubeController:ReciveSignal(data: any)
    local NetworkApiService = Knit.GetService("NetworkApiService")

    if (data.Index == "Activate") then
        print("Cube Activation.")

        NetworkApiService:TransferNetworkOwnership(data.Instance)
        data.Instance.BrickColor = BrickColor.Green()
    else
        print("Cube Deactivation.")

        data.Instance.BrickColor = BrickColor.Red()
    end
end

function CubeController:KnitStart()
    warn(self.Name .. " ready to listen at " .. os.clock()) 
end
return CubeController
