local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("StrategyRemotes")
local actionRemote = remotes:WaitForChild("Action")
local stateRemote = remotes:WaitForChild("State")
local selected
local latestState

local gui = Instance.new("ScreenGui")
gui.Name = "StrategyInterface"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(300, 330)
panel.Position = UDim2.fromOffset(18, 18)
panel.BackgroundColor3 = Color3.fromRGB(20, 24, 32)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

local function makeLabel(text, y, height)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, height or 28)
    label.Position = UDim2.fromOffset(10, y)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(235, 240, 245)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = panel
    return label
end

local title = makeLabel("GRAND FRONTIER", 10, 30)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
local status = makeLabel("Connecting...", 48, 72)
status.TextWrapped = true
local selection = makeLabel("Select a province", 125, 34)

local function button(text, x, y, width)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(width or 130, 38)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(55, 70, 92)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.Text = text
    b.Parent = panel
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local recruit = button("Recruit", 10, 170, 135)
local research = button("Research", 155, 170, 135)
local attack = button("Attack selected", 10, 216, 280)
local endTurn = button("End Turn", 10, 262, 280)

local function send(action)
    if action == "Recruit" then actionRemote:FireServer(action, selected)
    elseif action == "Attack" then actionRemote:FireServer(action, selected, selected and latestState.AttackTarget)
    else actionRemote:FireServer(action) end
end

recruit.MouseButton1Click:Connect(function() send("Recruit") end)
research.MouseButton1Click:Connect(function() send("Research") end)
endTurn.MouseButton1Click:Connect(function() send("EndTurn") end)
attack.MouseButton1Click:Connect(function()
    if selected and latestState and latestState.AttackTarget then send("Attack") end
end)

local function selectProvince(id)
    selected = id
    local province = latestState and latestState.Provinces[id]
    if not province then return end
    latestState.AttackTarget = nil
    for _, info in ipairs(workspace.StrategyMap:GetChildren()) do
        if info:IsA("BasePart") then info.Transparency = info.Name == id and 0.15 or 0 end
    end
    selection.Text = id .. " | " .. province.Owner .. " | Units: " .. province.Units
    for _, neighbor in ipairs({"north", "west", "center", "east", "south"}) do
        local candidate = latestState.Provinces[neighbor]
        if candidate and candidate.Owner ~= player:GetAttribute("Faction") and neighbor ~= id then
            latestState.AttackTarget = neighbor
            break
        end
    end
end

for _, part in ipairs(workspace:WaitForChild("StrategyMap"):GetChildren()) do
    if part:IsA("BasePart") then
        local detector = Instance.new("ClickDetector")
        detector.MaxActivationDistance = 1000
        detector.Parent = part
        detector.MouseClick:Connect(function(clickedPlayer)
            if clickedPlayer == player then selectProvince(part.Name) end
        end)
    end
end

stateRemote.OnClientEvent:Connect(function(newState, message)
    latestState = newState
    local faction = player:GetAttribute("Faction") or "Blue"
    local resources = newState.Factions[faction]
    status.Text = (message and (message .. "\n") or "") .. "Faction: " .. faction .. "\nTurn: " .. newState.Turn .. " | Industry: " .. resources.Industry .. "\nManpower: " .. resources.Manpower .. " | Research: " .. resources.Research .. "\nTechnology: " .. resources.Technology
    if selected and newState.Provinces[selected] then selectProvince(selected) end
end)
