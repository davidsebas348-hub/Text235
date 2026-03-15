--------------------------------------------------
-- TOGGLE
--------------------------------------------------
if getgenv().AUTO_LOOK then
	getgenv().AUTO_LOOK = false

	if getgenv().AUTO_LOOK_CONN then
		getgenv().AUTO_LOOK_CONN:Disconnect()
	end

	getgenv().AUTO_LOOK_CONN = nil
	return
end

getgenv().AUTO_LOOK = true
--------------------------------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local live = workspace:WaitForChild("Live")

-- Función para obtener el modelo más cercano vivo
local function getClosestAlive()

	local myChar = live:FindFirstChild(lp.Name)
	if not myChar then return end

	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local closest
	local dist = math.huge

	for _, model in pairs(live:GetChildren()) do
		if model:IsA("Model") and model.Name ~= lp.Name then

			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local root = model:FindFirstChild("HumanoidRootPart")

			if humanoid and root and humanoid.Health > 0 then

				local d = (myRoot.Position - root.Position).Magnitude

				if d < dist then
					dist = d
					closest = root
				end

			end
		end
	end

	return closest
end

-- Loop para mirar al más cercano
getgenv().AUTO_LOOK_CONN = RunService.RenderStepped:Connect(function()

	if not getgenv().AUTO_LOOK then return end

	local myChar = live:FindFirstChild(lp.Name)
	if not myChar then return end

	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local target = getClosestAlive()

	if target then
		myRoot.CFrame = CFrame.new(myRoot.Position, target.Position)
	end

end)
