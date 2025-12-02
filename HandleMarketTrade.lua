function HandleMarketPurchase( screen, button )
	local item = button.Data

	if not HasResource( item.CostName, item.CostAmount ) then
		Flash({ Id = screen.Components["PurchaseButton".. button.Index].Id, Speed = 3, MinFraction = 0.6, MaxFraction = 0.0, Color = Color.CostUnaffordable, ExpireAfterCycle = true })
		MarketPurchaseFailPresentation( item )
		return
	end

	screen.NumSales = screen.NumSales + 1
	GameState.MarketSales = (GameState.MarketSales or 0) + 1

	MarketPurchaseSuccessPresentation( item )
	if item.Priority then
		MarketPurchaseSuccessRepeatablePresentation( button )
	else
		item.SoldOut = true
		Destroy({ Ids = { screen.Components["PurchaseButtonTitle".. button.Index].Id , screen.Components["PurchaseButtonTitle".. button.Index .. "SellText"].Id, screen.Components["PurchaseButtonTitle".. button.Index .. "Icon"].Id, screen.Components["Backing".. button.Index].Id, screen.Components["Icon".. button.Index].Id }})
		screen.Components["PurchaseButtonTitle".. button.Index .. "Icon"] = nil
		screen.Components["PurchaseButtonTitle".. button.Index .. "SellText"] = nil
		screen.Components["PurchaseButtonTitle".. button.Index] = nil
		screen.Components["Backing".. button.Index] = nil
		screen.Components["Icon".. button.Index] = nil

		-- SetScale({ Id = screen.Components["PurchaseButton".. button.Index].Id, Fraction = 0.5, Duration = 0.2 })
		SetAlpha({ Id = screen.Components["PurchaseButton".. button.Index].Id, Fraction = 0, Duration = 0.2 })
		wait(0.2)
		Destroy({ Id = screen.Components["PurchaseButton".. button.Index].Id })
		screen.Components["PurchaseButton".. button.Index] = nil
	end
	local resourceArgs = { SkipOverheadText = true, ApplyMultiplier = false, }

	SpendResource( item.CostName, item.CostAmount, "Market", resourceArgs  )

	wait(0.3)

	AddResource( item.BuyName, item.BuyAmount, "Market", resourceArgs  )

	-- Check updated affordability
	for itemIndex, item in ipairs( CurrentRun.MarketItems ) do
		if not item.SoldOut then
			local costColor = Color.TradeAffordable
			if not HasResource( item.CostName, item.CostAmount ) then
				costColor = Color.TradeUnaffordable
			end
			local purchaseButtonKey = "PurchaseButton"..itemIndex
			ModifyTextBox({ Id = screen.Components["PurchaseButtonTitle"..itemIndex.."SellText"].Id, ColorTarget = costColor, ColorDuration = 0.1 })
		end
	end

	if CoinFlip() then
		thread( PlayVoiceLines, ResourceData[item.CostName].BrokerSpentVoiceLines, true )
	else
		thread( PlayVoiceLines, ResourceData[item.BuyName].BrokerPurchaseVoiceLines, true )
	end
end