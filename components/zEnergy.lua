zUI:RegisterComponent("zEnergy", function ()
	-- Thanks to Obble/modui

    local _, class = UnitClass('player')
    if not (class == 'ROGUE' or class == 'DRUID') then return end

    local lastEnergyValue       = 0     -- The zEnergy value after the last regen pulse.
    local currentEnergyValue    = 0     -- The current zEnergy value at the time of the current regen pulse.
    local preLastPulseTime      = 2.0   -- Time of the second to last regen pulse.
    local lastPulseTime         = 2.0   -- Time of the last regen pulse.
    local pulseTotal            = 0     -- Total time of all regen pulse gaps > 2.0.
    local pulseCount            = 0     -- Total number of regen pulses > 2.0.
    local syncNextUpdate        = false -- True if a regen pulse just ocurred and zEnergy value will sync next frame.

	 
    --local zEnergy = CreateFrame("Statusbar", "zEnergy", PlayerFrameManaBar)
    zUI.zEnergy = CreateFrame("Statusbar", "zEnergy", PlayerFrameManaBar)
    zEnergy:SetWidth(PlayerFrameManaBar:GetWidth())
    zEnergy:SetAllPoints(PlayerFrameManaBar)
    zEnergy:Hide()

    local spark = zEnergy:CreateTexture(nil, 'OVERLAY')
    spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
    spark:SetWidth(32) spark:SetHeight(32)
    spark:SetBlendMode('ADD')
    spark:SetAlpha(.4)

    local energy_OnUpdate = function()
        if (syncNextUpdate) then
            local v = mod((GetTime() - lastPulseTime), 2.0)
            spark:SetPoint('CENTER', zEnergy, 'LEFT', (zEnergy:GetWidth() * (v / 2.0)), 0)

            local nextPulseTotalAddition = (lastPulseTime - preLastPulseTime)
            if ((nextPulseTotalAddition > 2.0) and (nextPulseTotalAddition < 2.5)) then
                pulseTotal = pulseTotal + (lastPulseTime - preLastPulseTime)
                pulseCount = (pulseCount + 1)

                -- -- TEST BLOCK ---------------------------
                -- print('Sync update just ocurred')
                -- print('time to be added to total: ' .. (lastPulseTime - preLastPulseTime))
                -- print('pulseTotal: '.. pulseTotal)
                -- print('pulseCount: ' .. pulseCount)
                -- print('pulseAverage: ' .. pulseTotal / pulseCount)
                -- -- END TESTBLOCK ------------------------
            end
            syncNextUpdate = false
        else
            if (pulseCount == 0) then
                local v = mod((GetTime() - lastPulseTime), 2.0)
                spark:SetPoint('CENTER', zEnergy, 'LEFT', (zEnergy:GetWidth() * (v / 2.0)), 0)
            else
                local v = mod((GetTime() - lastPulseTime), (pulseTotal / pulseCount))
                spark:SetPoint('CENTER', zEnergy, 'LEFT', (zEnergy:GetWidth() * (v / (pulseTotal / pulseCount))), 0)

                if ((GetTime() - lastPulseTime) > 120) then
                    zEnergy:Hide()
                end

                -- -- TEST BLOCK ---------------------------
                -- print('running average mode')
                -- print('pulseTotal: '.. pulseTotal)
                -- print('pulseCount: ' .. pulseCount)
                -- print('pulseAverage: ' .. pulseTotal / pulseCount)
                -- -- END TESTBLOCK ------------------------
            end
        end
    end

    zEnergy:SetScript('OnEvent', function()
        if event == 'PLAYER_REGEN_DISABLED' then
            spark:SetAlpha(1)
        elseif event == 'PLAYER_REGEN_ENABLED' then
            spark:SetAlpha(.4)
        elseif event == 'PLAYER_AURAS_CHANGED' then
            local power  = UnitPowerType'player'
            if power == 3 then
                zEnergy:Show()
            else
                zEnergy:Hide()
            end
        else
            if arg1 == 'player' then
                currentEnergyValue = UnitMana('player')
                if  currentEnergyValue == lastEnergyValue + 20 then
                    preLastPulseTime = lastPulseTime
                    lastPulseTime = GetTime()
                    syncNextUpdate = true
                    zEnergy:Show()
                end
                lastEnergyValue = currentEnergyValue
            end
        end
    end)

    zEnergy:SetScript('OnUpdate', energy_OnUpdate)
    zEnergy:RegisterEvent'PLAYER_AURAS_CHANGED'
    zEnergy:RegisterEvent'PLAYER_REGEN_DISABLED'
    zEnergy:RegisterEvent'PLAYER_REGEN_ENABLED'
    zEnergy:RegisterEvent'UNIT_ENERGY'
end)