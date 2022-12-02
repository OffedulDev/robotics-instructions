local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

Knit.AddServices(script.Parent.Services)
Knit:Start():andThen(function()
    warn("Knit started at " .. os.clock())
end):catch(function(e)
    warn(e)
end)