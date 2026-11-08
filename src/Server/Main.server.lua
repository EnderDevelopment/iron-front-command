local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local remotes = ReplicatedStorage:FindFirstChild("StrategyRemotes") or Instance.new("Folder")
remotes.Name = "StrategyRemotes"
remotes.Parent = ReplicatedStorage

local actionRemote = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
actionRemote.Name = "Action"
actionRemote.Parent = remotes
local stateRemote = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
stateRemote.Name = "State"
stateRemote.Parent = remotes

local state = {Turn = 1, Provinces = {}, Factions = {}}
local provinceParts = {}

for factionName, faction in pairs(Config.Factions) do
    state.Factions[factionName] = {
        Industry = Config.StartingIndustry,
        Manpower = Config.StartingManpower,
        Research = Config.StartingResearch,
        Technology = 0,
    }
end

local function provinceById(id)
    for _, province in ipairs(Config.Provinces) do
        if province.Id == id then return province end
    end
end

for _, province in ipairs(Config.Provinces) do
    state.Provinces[province.Id] = {
        Owner = province.Owner,
        Units = province.Owner == "Blue" and 10 or 8,
        Level = 1,
    }
end

local map = Instance.new("Folder")
map.Name = "StrategyMap"
map.Parent = workspace
local baseY = 2
for _, province in ipairs(Config.Provinces) do
    local part = Instance.new("Part")
    part.Name = province.Id
    part.Size = Vector3.new(58, 2, 58)
    part.Position = Vector3.new(province.X, baseY, province.Z)
    part.Anchored = true
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Config.Factions[province.Owner].Color
    part:SetAttribute("ProvinceId", province.Id)
    part.Parent = map
    provinceParts[province.Id] = part

    local label = Instance.new("SurfaceGui")
    label.Face = Enum.NormalId.Top
    label.AlwaysOnTop = true
    label.Parent = part
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeTransparency = 0.3
    text.Text = province.Name
    text.Parent = label
end

local function publicState()
    return {Turn = state.Turn, Provinces = state.Provinces, Factions = state.Factions}
end

local function broadcast()
    for _, player in ipairs(Players:GetPlayers()) do
        stateRemote:FireClient(player, publicState())
    end
end

local function playerFaction(player)
    return player:GetAttribute("Faction") or "Blue"
end

local function reject(player, message)
    stateRemote:FireClient(player, publicState(), message)
end

local function validTarget(originId, targetId, faction)
    local origin = provinceById(originId)
    local target = provinceById(targetId)
    if not origin or not target or state.Provinces[originId].Owner ~= faction then return false end
    for _, neighbor in ipairs(origin.Neighbors) do
        if neighbor == targetId and state.Provinces[targetId].Owner ~= faction then return true end
    end
    return false
end

actionRemote.OnServerEvent:Connect(function(player, action, first, second)
    local faction = playerFaction(player)
    local resources = state.Factions[faction]
    if not resources then return end

    if action == "Recruit" then
        local province = state.Provinces[first]
        if not province or province.Owner ~= faction then return reject(player, "You do not control that province.") end
        if resources.Industry < Config.RecruitCost or resources.Manpower < Config.RecruitManpower then return reject(player, "Insufficient industry or manpower.") end
        resources.Industry -= Config.RecruitCost
        resources.Manpower -= Config.RecruitManpower
        province.Units += 5
    elseif action == "Research" then
        if resources.Research < Config.ResearchCost then return reject(player, "You need more research points.") end
        resources.Research -= Config.ResearchCost
        resources.Technology += 1
    elseif action == "Attack" then
        if resources.Industry < Config.AttackCost then return reject(player, "Insufficient industry.") end
        if not validTarget(first, second, faction) then return reject(player, "That target is not an adjacent enemy province.") end
        local attacker = state.Provinces[first]
        local defender = state.Provinces[second]
        resources.Industry -= Config.AttackCost
        local attackPower = attacker.Units + resources.Technology * 2
        if attackPower > defender.Units then
            defender.Owner = faction
            defender.Units = math.max(1, math.floor(attackPower / 2))
            attacker.Units = math.max(1, math.floor(attacker.Units / 2))
        else
            attacker.Units = math.max(1, math.floor(attacker.Units / 2))
            defender.Units = math.max(1, math.floor(defender.Units / 2))
        end
        provinceParts[second].Color = Config.Factions[defender.Owner].Color
    elseif action == "EndTurn" then
        state.Turn += 1
        for factionName, factionState in pairs(state.Factions) do
            local owned = 0
            for _, provinceState in pairs(state.Provinces) do
                if provinceState.Owner == factionName then owned += 1 end
            end
            factionState.Industry += owned * 2
            factionState.Manpower += owned * 8
            factionState.Research += owned
        end
    end
    broadcast()
end)

Players.PlayerAdded:Connect(function(player)
    local blueCount = 0
    for _, other in ipairs(Players:GetPlayers()) do
        if other:GetAttribute("Faction") == "Blue" then blueCount += 1 end
    end
    player:SetAttribute("Faction", blueCount <= #Players:GetPlayers() / 2 and "Blue" or "Red")
    stateRemote:FireClient(player, publicState())
end)
