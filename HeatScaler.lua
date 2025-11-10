--[[ModUtil.Mod.Register("HeatScaler")

local config = {
  Multiplier = {
    Damage =  TraitData.
    Life = function(heatLevel) return 1 + (heatLevel * 0.03) end,
  }
}    

HeatScaler.Config = config



if TraitData.DepthDamageMultiplier == nil then
    TraitData.DepthDamageMultiplier = 0.0
    return TraitData.DepthDamageMultiplier
end

if TraitData.DepthDamageMultiplicer > 0.0 then
    return depth
function GetHeatLevel ( heatLevel )
    if heatLevel == nil then
        heatLevel = GetTotalSpentShrinePoints() or 0
    end
    return heatLevel
end


function CalculateBonus ( heatLevel , divisor )
    if divisor == 0 then
        return 0
    end

    if type(divisor) ~= "number" then
        return 0
    elseif type(divisor) == "number" and heatLevel < divisor then 
        return 0
    end
    return math.floor( heatLevel / divisor )
end



ModUtil.WrapBaseFunction("BaseDmgInc",
    function(baseFunc, Current
)
]]--