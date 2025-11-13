-- tradeutils.lua
-- Trade generation logic for WretchedBrokerQOL
-- Handles base, bulk, reverse (ReSell), and bulk reverse trades

WretchedBrokerQOL = WretchedBrokerQOL or {}
WretchedBrokerQOL.TradeUtils = WretchedBrokerQOL.TradeUtils or {}

local M = WretchedBrokerQOL.TradeUtils

---------------------------------------------------------
-- Resource Display Names (Script → Text)
---------------------------------------------------------

M.ResourceDisplayNames = {
    Gems            = "Gems",          -- Gemstones
    LockKeys        = "Chthonic Keys", -- Keys
    GiftPoints      = "Nectar",
    SuperGems       = "Diamond",
    SuperGiftPoints = "Ambrosia",
    SuperLockKeys   = "Titan Blood",
}

---------------------------------------------------------
-- Bulk Multipliers
-- Uses config if present, otherwise defaults
---------------------------------------------------------

local function GetBulkMultipliers()
    local cfg = WretchedBrokerQOL.Config
    if cfg
        and cfg.WretchedBrokerBulk
        and type(cfg.WretchedBrokerBulk.Multipliers) == "table"
        and #cfg.WretchedBrokerBulk.Multipliers > 0
    then
        return cfg.WretchedBrokerBulk.Multipliers
    end

    -- fallback defaults
    return { 5, 10, 25, 50, 100, 500, 1000 }
end

---------------------------------------------------------
-- Base Forward Trades (vanilla-equivalent)
---------------------------------------------------------

local BaseBrokerTrades = {
    { Id="GemsToKeys", CostItem="Gems", CostAmount=10, RewardItem="LockKeys", RewardAmount=1 },
    { Id="KeysToNectar", CostItem="LockKeys", CostAmount=5, RewardItem="GiftPoints", RewardAmount=1 },
    { Id="NectarToDiamond", CostItem="GiftPoints", CostAmount=10, RewardItem="SuperGems", RewardAmount=1 },
    { Id="DiamondToAmbrosia", CostItem="SuperGems", CostAmount=2, RewardItem="SuperGiftPoints", RewardAmount=1 },
    { Id="AmbrosiaToTitanBlood", CostItem="SuperGiftPoints", CostAmount=1, RewardItem="SuperLockKeys", RewardAmount=1 },
}

function M.GetBaseTrades()
    return BaseBrokerTrades
end

---------------------------------------------------------
-- Generate Bulk Forward Trades
---------------------------------------------------------

local BulkForwardCache = nil

function M.GenerateBulkForwardTrades()
    if BulkForwardCache ~= nil then return BulkForwardCache end

    local multipliers = GetBulkMultipliers()
    local result = {}

    for _, base in ipairs(BaseBrokerTrades) do
        for _, m in ipairs(multipliers) do
            table.insert(result, {
                BaseId       = base.Id,
                CostItem     = base.CostItem,
                CostAmount   = base.CostAmount   * m,
                RewardItem   = base.RewardItem,
                RewardAmount = base.RewardAmount * m,
                Multiplier   = m,
            })
        end
    end

    BulkForwardCache = result
    return result
end

---------------------------------------------------------
-- Base Reverse (ReSell) Trades
---------------------------------------------------------

local ReSellBaseTrades = nil

local function BuildReSellBaseTrades()
    if ReSellBaseTrades ~= nil then return ReSellBaseTrades end

    local result = {}

    for _, base in ipairs(BaseBrokerTrades) do
        table.insert(result, {
            Id           = "ReSell_" .. base.Id,
            CostItem     = base.RewardItem,
            CostAmount   = base.RewardAmount,
            RewardItem   = base.CostItem,
            RewardAmount = base.CostAmount,
        })
    end

    ReSellBaseTrades = result
    return result
end

function M.GetReSellBaseTrades()
    return BuildReSellBaseTrades()
end

---------------------------------------------------------
-- Generate Bulk Reverse Trades
---------------------------------------------------------

local BulkReSellCache = nil

function M.GenerateBulkReSellTrades()
    if BulkReSellCache ~= nil then return BulkReSellCache end

    local baseReSell = BuildReSellBaseTrades()
    local multipliers = GetBulkMultipliers()
    local result = {}

    for _, base in ipairs(baseReSell) do
        for _, m in ipairs(multipliers) do
            table.insert(result, {
                BaseId       = base.Id,
                CostItem     = base.CostItem,
                CostAmount   = base.CostAmount   * m,
                RewardItem   = base.RewardItem,
                RewardAmount = base.RewardAmount * m,
                Multiplier   = m,
            })
        end
    end

    BulkReSellCache = result
    return result
end

---------------------------------------------------------
-- Format Friendly UI Strings
---------------------------------------------------------

function M.FormatTradeForDisplay(trade)
    local costName   = M.ResourceDisplayNames[trade.CostItem]   or trade.CostItem
    local rewardName = M.ResourceDisplayNames[trade.RewardItem] or trade.RewardItem

    local costText   = tostring(trade.CostAmount)   .. " " .. costName
    local rewardText = tostring(trade.RewardAmount) .. " " .. rewardName

    return costText, rewardText
end

return M