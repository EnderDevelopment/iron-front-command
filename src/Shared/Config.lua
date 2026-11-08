local Config = {}

Config.TurnLength = 30
Config.StartingIndustry = 12
Config.StartingManpower = 120
Config.StartingResearch = 0
Config.RecruitCost = 2
Config.RecruitManpower = 10
Config.AttackCost = 3
Config.ResearchCost = 8

Config.Provinces = {
    {Id = "north", Name = "Northland", X = 0, Z = -70, Owner = "Blue", Neighbors = {"west", "east", "center"}},
    {Id = "west", Name = "Westmark", X = -70, Z = 0, Owner = "Red", Neighbors = {"north", "center", "south"}},
    {Id = "center", Name = "Heartland", X = 0, Z = 0, Owner = "Blue", Neighbors = {"north", "west", "east", "south"}},
    {Id = "east", Name = "Eastreach", X = 70, Z = 0, Owner = "Red", Neighbors = {"north", "center", "south"}},
    {Id = "south", Name = "Southcape", X = 0, Z = 70, Owner = "Blue", Neighbors = {"west", "east", "center"}},
}

Config.Factions = {
    Blue = {Name = "Azure Union", Color = Color3.fromRGB(45, 120, 220)},
    Red = {Name = "Crimson Pact", Color = Color3.fromRGB(210, 60, 55)},
}

return Config
