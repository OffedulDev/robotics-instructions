local Knit = require(game.ReplicatedStorage.Packages.knit)
local janitor = require(game.ReplicatedStorage.Packages.janitor)
local Promise = require(game.ReplicatedStorage.Packages.promise)

local Player = game:GetService("Players").LocalPlayer
local UserInputController = Knit.CreateController { 
    Name = "UserInputController" ;
    Strict = true;
}
local UserInputService = game:GetService("UserInputService")

function UserInputController:SendToServer(signal: string, input: InputObject)
    return Promise.new(function(resolve, reject)
        local InputService = Knit.GetService("UserInputService")
        local Signal = InputService[signal]; if not Signal then reject() end

        resolve(Signal:Fire({
            UserInputType = input.UserInputType.Name;
            Keycode = input.KeyCode.Name;
        }))
    end):catch(warn)
end

function UserInputController:ListenInputEvents()
    self._janitor:Add(UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
        if (self.Strict and processed) then return end
        
        self:SendToServer("InputBegan", input)
    end))

    --[[ self._janitor:Add(UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
        if (self.Strict and processed) then return end
        
        self:SendToServer("InputChanged", input)
    end)) *]]

    self._janitor:Add(UserInputService.InputEnded:Connect(function(input: InputObject, processed: boolean)
        if (self.Strict and processed) then return end
        
        self:SendToServer("InputEnded", input)
    end))
end

function UserInputController:KnitStart()
    self._janitor = janitor.new()
    self._janitor:Add(Player.Destroying:Connect(function()
        self._janitor:Cleanup()
    end))

    task.defer(function()
        self:ListenInputEvents()
    end)
    warn(self.Name .. " started at " .. os.clock())
end

return UserInputController
