local knit = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("knit"))

knit.AddControllers(script.Parent:WaitForChild("Controllers"))
knit:Start():andThen(function()
    warn("Knit client started at " .. os.clock())
end):catch(function(e)
    warn(e)
end)