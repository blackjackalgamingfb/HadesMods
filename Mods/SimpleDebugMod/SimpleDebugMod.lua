-- Register the mod with ModUtil
ModUtil.RegisterMod("SimpleDebugMod")
ModUtil.WrapBaseFunction("StartNewRun", function(basefunc, currentRun)
    print("[SimpleDebugMod] StartNewRun function triggered!")
    basefunc(currentRun)
end)