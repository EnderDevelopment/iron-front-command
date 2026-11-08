# Roblox Grand-Strategy Game Prototype

Iron Front Command is an open source Roblox grand-strategy game prototype with a server-authoritative map, provinces, factions, industry, manpower, research, recruitment, technology, and adjacent-province combat. It implements the core strategy game loops of territorial control, economic growth, unit management, research progression, and turn-based conflict.

## Install

1. Create or open a Roblox place in Roblox Studio.
2. Create a `Shared` folder inside `ReplicatedStorage`.
3. Add a ModuleScript at `ReplicatedStorage/Shared/Config`.
4. Copy the contents of `src/Shared/Config.lua` into the `Config` ModuleScript.
5. Add a server Script at `ServerScriptService/Main.server.lua`.
6. Copy the contents of `src/Server/Main.server.lua` into the server Script.
7. Add a LocalScript at `StarterPlayer/StarterPlayerScripts/Main.client.lua`.
8. Copy the contents of `src/Client/Main.client.lua` into the LocalScript.
9. Start a Play test with two or more players.

The server automatically creates the strategy map, province parts, faction state, units, remote events, and province labels. No external assets are required.

## Use

1. Start a multiplayer Play test to assign players to the Blue or Red faction.
2. Click a province on the generated map to select it.
3. Use Recruit to spend industry and manpower to add units to a province you control.
4. Use Research to spend research points and increase technology.
5. Select a controlled province and use Attack selected to attack an adjacent enemy province.
6. Use End Turn to advance the global turn and give each faction industry, manpower, and research based on the number of provinces it controls.
7. Expand your faction by capturing enemy provinces and managing resources.

All gameplay actions are sent to the server and validated there, including province ownership, adjacent attack targets, resource costs, and available manpower.

---

More open source project projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/fc3de59c-a2d1-44e9-bb1b-b621fcd9dd78?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=fc3de59c-a2d1-44e9-bb1b-b621fcd9dd78
