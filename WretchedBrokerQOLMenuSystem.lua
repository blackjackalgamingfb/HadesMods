-- Wretched Broker QOL Custom Menu System (Corrected Full Version)
-- Complete standalone menu system patterned after Zyruvia's CreateMenu
-- Includes: Controller support, navigation, Bulk/Resell pages, icons, and safe cleanup

WretchedBrokerQOL = WretchedBrokerQOL or {}
WretchedBrokerQOL.Menu = WretchedBrokerQOL.Menu or {}

local Menu = WretchedBrokerQOL.Menu
local UI = WretchedBrokerQOL.UIUtils
local Trades = WretchedBrokerQOL.TradeUtils

---------------------------------------------------------
-- CreateMenu: master constructor
---------------------------------------------------------
function Menu.CreateMenu(id, definition)
    local screen = { Components = {}, Name = id or "WretchedBrokerQOLMenu" }

    OnScreenOpened({ Flag = screen.Name, PersistCombatUI = true })
    FreezePlayerUnit()
    EnableShopGamepadCursor()

    -- Background panel (same as Broker UI)
    screen.Components.Background = CreateScreenComponent({ Name = "ShopBackground", Group = "Combat_Menu" })

    -----------------------------------------------------
    -- Build Persistent Components (Title, Close Button)
    -----------------------------------------------------
    for _, comp in ipairs(definition.Components or {}) do
        if comp.Type == "Text" and comp.SubType == "Title" then
            UI.CreateText(screen, comp.FieldName, 960, 120, comp.Args.Text, { FontSize = 34 })

        elseif comp.Type == "Button" and comp.SubType == "Close" then
            local closeBtn = UI.CreateButton(screen, "CloseButton", 1720, 150, "X", "WretchedBrokerQOL.Menu.CloseMenu")
            screen.Components["CloseButton"] = closeBtn
        end
    end

    -----------------------------------------------------
    -- Build Pages (pre-built in Menu.Definition)
    -----------------------------------------------------
    screen.Pages = {}
    for pageIndex, pageBlocks in pairs(definition.Pages or {}) do
        screen.Pages[pageIndex] = Menu.BuildPage(screen, pageIndex, pageBlocks)
    end

    screen.CurrentPage = 1
    Menu.ShowPage(screen, 1)

    -----------------------------------------------------
    -- Navigation buttons
    -----------------------------------------------------
    Menu.CreateNavigation(screen)

    return screen
end

---------------------------------------------------------
-- Build a single page
---------------------------------------------------------
function Menu.BuildPage(screen, index, blocks)
    local page = {}
    local y = 260

    for _, block in ipairs(blocks) do
        if block.Type == "Text" and block.SubType == "Subtitle" then
            page[block.FieldName] = UI.CreateText(screen, block.FieldName, 960, y, block.Args.Text, { FontSize = 26 })
            y = y + 80

        elseif block.Type == "Text" and block.SubType == "Paragraph" then
            page[block.FieldName] = UI.CreateText(screen, block.FieldName, 960, y, block.Args.Text, { FontSize = 20 })
            y = y + 240

        elseif block.Type == "TradeRow" then
            page[block.FieldName] = Menu.BuildTradeRow(screen, block.Args, y)
            y = y + 120
        end
    end

    -- Hide initially
    for _, comp in pairs(page) do
        if comp and comp.Id then
            SetAlpha({ Id = comp.Id, Fraction = 0 })
        end
    end

    return page
end

---------------------------------------------------------
-- Build Trade Row (with icons)
---------------------------------------------------------
function Menu.BuildTradeRow(screen, trade, y)
    local row = CreateScreenComponent({ Name = "MarketSlot", Group = "Combat_Menu", X = 960, Y = y })

    -----------------------------------------------------
    -- Icons
    -----------------------------------------------------
    local IconAnim = {
        Gems            = "BountySymbolGems",
        LockKeys        = "BountySymbolLockKeys",
        GiftPoints      = "BountySymbolGiftPoints",
        SuperGems       = "BountySymbolSuperGems",
        SuperGiftPoints = "BountySymbolSuperGiftPoints",
        SuperLockKeys   = "BountySymbolSuperLockKeys",
    }

    local costAnim = IconAnim[trade.CostItem]
    local rewardAnim = IconAnim[trade.RewardItem]

    if costAnim then
        local costIcon = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu", X = 580, Y = y })
        SetAnimation({ DestinationId = costIcon.Id, Name = costAnim })
        Attach({ Id = costIcon.Id, DestinationId = row.Id })
    end

    if rewardAnim then
        local rewardIcon = CreateScreenComponent({ Name = "BlankObstacle", Group = "Combat_Menu", X = 1340, Y = y })
        SetAnimation({ DestinationId = rewardIcon.Id, Name = rewardAnim })
        Attach({ Id = rewardIcon.Id, DestinationId = row.Id })
    end

    -----------------------------------------------------
    -- Text
    -----------------------------------------------------
    local costText, rewardText = Trades.FormatTradeForDisplay(trade)

    CreateTextBox({
        Id = row.Id,
        Text = costText,
        Font = "SpectralSCLight22",
        OffsetX = -220,
        OffsetY = 0,
        Color = {255,255,255,255},
        Justification = "Left",
    })

    CreateTextBox({
        Id = row.Id,
        Text = rewardText,
        Font = "SpectralSCLight22",
        OffsetX = 220,
        OffsetY = 0,
        Color = {255,255,255,255},
        Justification = "Right",
    })

    -----------------------------------------------------
    -- Buy/Execute Button
    -----------------------------------------------------
    local buyBtn = CreateScreenComponent({ Name = "ButtonInput", Group = "Combat_Menu", X = 960, Y = y + 40 })
    buyBtn.OnPressedFunctionName = "WretchedBrokerQOL.Menu.ExecuteTrade"
    buyBtn.tradeData = trade

    return row
end

---------------------------------------------------------
-- Show Page
---------------------------------------------------------
function Menu.ShowPage(screen, index)
    -- Hide all pages
    for _, page in pairs(screen.Pages) do
        for _, comp in pairs(page) do
            if comp and comp.Id then
                SetAlpha({ Id = comp.Id, Fraction = 0 })
            end
        end
    end

    -- Show the requested page if it exists
    if screen.Pages[index] then
        for _, comp in pairs(screen.Pages[index]) do
            if comp and comp.Id then
                SetAlpha({ Id = comp.Id, Fraction = 1, Duration = 0.2 })
            end
        end
        screen.CurrentPage = index
    end
end

---------------------------------------------------------
-- Navigation Buttons
---------------------------------------------------------
function Menu.CreateNavigation(screen)
    screen.Components.PrevPage = UI.CreateButton(screen, "PrevPageButton", 300, 980, "<", "WretchedBrokerQOL.Menu.PrevPage")
    screen.Components.NextPage = UI.CreateButton(screen, "NextPageButton", 1620, 980, ">", "WretchedBrokerQOL.Menu.NextPage")
end

function Menu.PrevPage(button)
    local screen = button.Screen or CurrentRun.CurrentScreen
    local newPage = math.max(1, screen.CurrentPage - 1)
    Menu.ShowPage(screen, newPage)
end

function Menu.NextPage(button)
    local screen = button.Screen or CurrentRun.CurrentScreen
    local newPage = math.min(#screen.Pages, screen.CurrentPage + 1)
    Menu.ShowPage(screen, newPage)
end

---------------------------------------------------------
-- Execute Trade
---------------------------------------------------------
function Menu.ExecuteTrade(button)
    local trade = button.tradeData
    if not trade then return end

    -- Safety check for CurrentRun and CurrentRoom
    if not CurrentRun or not CurrentRun.CurrentRoom or not CurrentRun.CurrentRoom.Resources then
        ModUtil.Hades.PrintConsole("Error: Cannot access game resources")
        return
    end

    local currentAmount = CurrentRun.CurrentRoom.Resources[trade.CostItem] or 0
    if currentAmount < trade.CostAmount then
        ModUtil.Hades.PrintConsole("Not enough " .. trade.CostItem)
        return
    end

    CurrentRun.CurrentRoom.Resources[trade.CostItem] = currentAmount - trade.CostAmount
    CurrentRun.CurrentRoom.Resources[trade.RewardItem] = (CurrentRun.CurrentRoom.Resources[trade.RewardItem] or 0) + trade.RewardAmount

    local c, r = Trades.FormatTradeForDisplay(trade)
    ModUtil.Hades.PrintConsole("Traded " .. c .. " → " .. r)
end

---------------------------------------------------------
-- Close Menu (safe cleanup)
---------------------------------------------------------
function Menu.CloseMenu(button)
    local screen = button.Screen or CurrentRun.CurrentScreen
    
    DisableShopGamepadCursor()
    UnfreezePlayerUnit()

    local comps = GetAllComponents() or {}
    for _, comp in pairs(comps) do
        if comp and comp.Id then
            Destroy({ Id = comp.Id })
        end
    end

    OnScreenClosed({ Flag = screen.Name })
    CloseScreen(comps, ScreenCloseFlags.Immediate)
end
