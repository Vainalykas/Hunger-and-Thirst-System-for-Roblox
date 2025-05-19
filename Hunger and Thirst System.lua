--[[
Hunger and Thirst System for Roblox
Author: Vain_ie

--- HOW TO IMPLEMENT ---
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

--- END OF TUTORIAL ---

Credits: System created by Vain_ie
]]

-- Hunger and Thirst System for Roblox
-- This script manages player hunger and thirst, including decay, replenishment, regeneration, multipliers, and admin controls.

-- Get the Players service to access all players in the game
local Players = game:GetService("Players")

-- Maximum values for hunger and thirst
local HUNGER_MAX = 100
local THIRST_MAX = 100
-- How much hunger and thirst decrease every interval
local HUNGER_DECAY = 1      -- Amount to decrease per interval
local THIRST_DECAY = 2
-- How often (in seconds) hunger and thirst decrease
local DECAY_INTERVAL = 10   -- Seconds

-- Table to store each player's hunger and thirst stats
local playerStats = {}

-- Function to initialize a player's stats when they join or respawn
local function initStats(player)
    playerStats[player.UserId] = {
        Hunger = HUNGER_MAX, -- Start with full hunger
        Thirst = THIRST_MAX  -- Start with full thirst
    }
end

-- Advanced: Regenerate stats for a player (e.g., when resting)
-- hungerRate: how much hunger to restore per second
-- thirstRate: how much thirst to restore per second
-- duration: how many seconds to regenerate for
function RegenerateStats(player, hungerRate, thirstRate, duration)
    local stats = playerStats[player.UserId]
    if not stats then return end -- Exit if player not found
    local regenTime = 0
    while regenTime < duration do
        stats.Hunger = math.min(HUNGER_MAX, stats.Hunger + hungerRate) -- Add hunger, clamp to max
        stats.Thirst = math.min(THIRST_MAX, stats.Thirst + thirstRate) -- Add thirst, clamp to max
        regenTime = regenTime + 1
        wait(1) -- Wait 1 second before next tick
    end
end

-- Advanced: Store multipliers for each player (for buffs/debuffs)
local playerMultipliers = {}
-- Set a player's hunger/thirst decay multipliers
function SetStatMultiplier(player, hungerMult, thirstMult)
    playerMultipliers[player.UserId] = {Hunger = hungerMult or 1, Thirst = thirstMult or 1}
end
-- Get a player's current multipliers (default to 1 if not set)
function GetStatMultiplier(player)
    return playerMultipliers[player.UserId] or {Hunger = 1, Thirst = 1}
end

-- Main function: decrease stats for all players over time
local function decayStats()
    while true do -- Loop forever
        for _, player in ipairs(Players:GetPlayers()) do -- For every player in the game
            local stats = playerStats[player.UserId] -- Get their stats
            local mults = GetStatMultiplier(player) -- Get their multipliers
            if stats then
                -- Decrease hunger and thirst, using multipliers, clamp to 0
                stats.Hunger = math.max(0, stats.Hunger - HUNGER_DECAY * mults.Hunger)
                stats.Thirst = math.max(0, stats.Thirst - THIRST_DECAY * mults.Thirst)
                -- If hunger is low (but not zero), notify the player
                if stats.Hunger <= 20 and stats.Hunger > 0 then
                    notifyLowStats(player, "Hunger")
                end
                -- If thirst is low (but not zero), notify the player
                if stats.Thirst <= 20 and stats.Thirst > 0 then
                    notifyLowStats(player, "Thirst")
                end
                -- If hunger or thirst is zero, damage the player
                if stats.Hunger == 0 or stats.Thirst == 0 then
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:TakeDamage(5) -- Deal 5 damage
                    end
                end
            end
        end
        wait(DECAY_INTERVAL) -- Wait before next decay
    end
end

-- When a player joins, initialize their stats and reset on respawn
Players.PlayerAdded:Connect(function(player)
    initStats(player)
    player.CharacterAdded:Connect(function()
        -- Optionally reset stats on respawn
        initStats(player)
    end)
end)

-- When a player leaves, remove their stats from the table
Players.PlayerRemoving:Connect(function(player)
    playerStats[player.UserId] = nil
end)

-- Function to increase a player's hunger (e.g., when eating food)
function ReplenishHunger(player, amount)
    local stats = playerStats[player.UserId]
    if stats then
        stats.Hunger = math.min(HUNGER_MAX, stats.Hunger + amount) -- Add, clamp to max
    end
end

-- Function to increase a player's thirst (e.g., when drinking)
function ReplenishThirst(player, amount)
    local stats = playerStats[player.UserId]
    if stats then
        stats.Thirst = math.min(THIRST_MAX, stats.Thirst + amount) -- Add, clamp to max
    end
end

-- Function to get a player's current hunger and thirst
function GetPlayerStats(player)
    local stats = playerStats[player.UserId]
    if stats then
        return {Hunger = stats.Hunger, Thirst = stats.Thirst}
    end
    return nil -- Return nil if player not found
end

-- Function to set a player's hunger and thirst directly (with clamping)
function SetPlayerStats(player, hunger, thirst)
    local stats = playerStats[player.UserId]
    if stats then
        stats.Hunger = math.clamp(hunger, 0, HUNGER_MAX) -- Clamp to valid range
        stats.Thirst = math.clamp(thirst, 0, THIRST_MAX)
    end
end

-- Function to notify a player when their stats are low
-- You can replace this with a UI notification or sound for the player
local function notifyLowStats(player, statType)
    print(player.Name .. "'s " .. statType .. " is low!") -- Print a warning to the output
end

-- Function to fully restore a player's stats (e.g., for admin or respawn)
function RestoreStats(player)
    SetPlayerStats(player, HUNGER_MAX, THIRST_MAX)
end

-- Advanced: Example admin command to set all player stats
-- Only works for a specific admin UserId (replace 123456 with your own)
function AdminSetStats(player, hunger, thirst)
    if player and player.UserId == 123456 then -- Replace with your admin UserId
        for _, p in ipairs(Players:GetPlayers()) do
            SetPlayerStats(p, hunger, thirst)
        end
    end
end

-- Start the stat decay loop in the background
spawn(decayStats)
