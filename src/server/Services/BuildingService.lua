local Knit = require(game.ReplicatedStorage.Packages.knit)
local Promise = require(game.ReplicatedStorage.Packages.promise)

local BuildingService = Knit.CreateService {
    Name = "BuildingService",
    Client = {
        SwitchBuilding = Knit.CreateSignal()
    },
}

function BuildingService.Client:PlacePiece(player: Player, piece_name: string, piece_cframe: CFrame)
    -- some security stuff for sure :D
    local Piece = game:GetService("ServerStorage"):FindFirstChild(piece_name); assert(Piece)
    
    -- TODO parent piece to player creation
    Piece = Piece:Clone()
    Piece.Parent = workspace
    Piece.Name = player.Name .. " " .. Piece.Name
    Piece:MakeJoints()
end

function BuildingService:SwitchBuilding(player: Player)
    return Promise.new(function(resolve, reject)
        resolve(self.Client.SwitchBuilding:Fire(player))
    end)
end

function BuildingService:KnitStart()
    warn(self.Name .. " started at " .. os.clock())    
end

return BuildingService
