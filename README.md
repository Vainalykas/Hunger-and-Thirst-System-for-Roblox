1. Copy this script into a Script object in ServerScriptService in your Roblox game.
2. The system will automatically track hunger and thirst for all players.
3. To replenish hunger or thirst (e.g., when a player eats or drinks), call:
   ReplenishHunger(player, amount)
   ReplenishThirst(player, amount)
4. To regenerate stats (e.g., while resting), call:
   RegenerateStats(player, hungerRate, thirstRate, duration)
5. To set multipliers (e.g., for buffs/debuffs), call:
   SetStatMultiplier(player, hungerMultiplier, thirstMultiplier)
6. To get a player's current stats, use:
   GetPlayerStats(player)
7. To fully restore a player's stats, use:
   RestoreStats(player)
8. For admin controls, use AdminSetStats(adminPlayer, hunger, thirst)
