-- Many credits to Shagu, pfUI
zUI:RegisterComponent("zEasyLife", function ()
	---------==[ auto-switch-stance ]==----------------
	if (C.quality.auto_stance == "1") then
		zUI.zEasyLife = CreateFrame("Frame")
		zUI.zEasyLife:RegisterEvent("UI_ERROR_MESSAGE")

		function zUI.IsFeignDeath()
		
		end

		zUI.zEasyLife.lastError = ""
		zUI.zEasyLife.CastSpellByName = _G["CastSpellByName"]
		zUI.zEasyLife.scanString = string.gsub(SPELL_FAILED_ONLY_SHAPESHIFT, "%%s", "(.+)")

		function zUI.zEasyLife:SwitchStance()
			for stance in string.gfind(zUI.zEasyLife.lastError, zUI.zEasyLife.scanString) do
				for _, stance in pairs({ strsplit(",", stance)}) do
					zUI.zEasyLife.CastSpellByName(string.gsub(stance,"^%s*(.-)%s*$", "%1"))
				end
			end
			zUI.zEasyLife.lastError = ""
		end

		hooksecurefunc("CastSpell", function(spellId, spellbookTabNum) -- todo: add option for Auto-Switch Stance.
			zUI.zEasyLife:SwitchStance()
		end)

		hooksecurefunc("CastSpellByName", function(spellName, onSelf)
			zUI.zEasyLife:SwitchStance()
		end)

		hooksecurefunc("UseAction", function(slot, checkCursor, onSelf)
			zUI.zEasyLife:SwitchStance()
		end)
	end

	-------------------==[ auto-dismount ]==----------------
	if (C.quality.auto_dismount == "1") then
		zUI.zEasyLife.buffs = { "spell_nature_swiftness", "_mount_", "_qirajicrystal_",
			"ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
			"ability_druid_aquaticform", "spell_shadow_shadowform", "spell_nature_spiritwolf" }

		-- an agility buff exists which has the same icon as the moonkin form
		-- therefore only add the moonkin icon to the removable buffs if
		-- moonkin is skilled and player is druid. Frame is required as talentpoints
		-- are only accessible after certain events.
		local moonkin_scan = CreateFrame("Frame")
		moonkin_scan:RegisterEvent("PLAYER_ENTERING_WORLD")
		moonkin_scan:RegisterEvent("UNIT_NAME_UPDATE")
		moonkin_scan:SetScript("OnEvent", function()
			local _, class = UnitClass("player")
			if class == "DRUID" then
				local _,_,_,_,moonkin = GetTalentInfo(1,16)
			if moonkin == 1 then
				table.insert(zUI.zEasyLife.buffs, "spell_nature_forceofnature")
				moonkin_scan:UnregisterAllEvents()
			end
			else
				moonkin_scan:UnregisterAllEvents()
			end
		end)

		zUI.zEasyLife.errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
			SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
			SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
			ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED,
			ERR_EMBLEMERROR_NOTABARDGEOSET }

		zUI.zEasyLife:SetScript("OnEvent", function()
			zUI.zEasyLife.lastError = arg1
			local lateCancel = nil

			if arg1 == SPELL_FAILED_NOT_STANDING then
				SitOrStand()
				return
			end

			for id, errorstring in pairs(zUI.zEasyLife.errors) do -- todo: add option for auto-dismount.
				if arg1 == errorstring then
					for i=0,31,1 do
						currBuffTex = GetPlayerBuffTexture(i)
						if (currBuffTex) then
							for id, bufftype in pairs(zUI.zEasyLife.buffs) do
								if string.find(string.lower(currBuffTex), bufftype, 1) then
									if string.find(string.lower(currBuffTex), "spell_shadow_shadowform", 1) then
										lateCancel = i
									else
										CancelPlayerBuff(i)
										return
									end
								end
							end
						end
					end
					if lateCancel then
						CancelPlayerBuff(lateCancel)
					end
				end
			end
		end)
	end

	-- Does not track mana atm, or party members.
	-- Track the players HP and target HP when feign death.
	----------------==[ feign death HP/MP ]==----------------
	if (C.quality.feign_death == "1") then
	
	--Thanks to Shagu/pfUI
	local cache = { }
	--local healthscan = CreateFrame("GameTooltip", "ufiHpScanner", UIParent, "GameTooltipTemplate")
	--healthscan:SetOwner(healthscan,"ANCHOR_NONE")
	local healthscan = libtipscan:GetScanner("feigndeath")
	local healthbar = healthscan:GetChildren()
	
	local cache_update = CreateFrame("Frame")
	cache_update:RegisterEvent("UNIT_HEALTH")
	cache_update:RegisterEvent("PLAYER_TARGET_CHANGED")
	cache_update:SetScript("OnEvent", function()
		if event == "PLAYER_TARGET_CHANGED" and UnitIsDead("target") then
			healthscan:SetUnit("target")
			--if (UnitIsPlayer("target")) then
				cache[UnitName("target")] = healthbar:GetValue()
			--end
		elseif event == "UNIT_HEALTH" and UnitIsDead(arg1) and UnitName(arg1) then
			healthscan:SetUnit(arg1)
			--if (UnitIsPlayer("target")) then
				cache[UnitName(arg1)] = healthbar:GetValue()
			--end
		elseif event == "UNIT_HEALTH" and UnitName(arg1) then
			--if (UnitIsPlayer("target")) then
				cache[UnitName(arg1)] = nil
			--end
		end
	end)
	
	local oldUnitHealth = UnitHealth
	function _G.UnitHealth(arg)
		if UnitIsDead(arg) and cache[UnitName(arg)] then
			return cache[UnitName(arg)]
		else
			return oldUnitHealth(arg)
		end
	end
	----------------==[ retarget ]==----------------
	local function feigning()
		local i, buff = 1, nil
		repeat
			buff = UnitBuff('target', i)
			if buff == [[Interface\Icons\Ability_Rogue_FeignDeath]] then
				--PlayerFrame_Update();
				UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player");
				return true
			end
			i = i + 1
		until not buff
		return UnitCanAttack('player', 'target')
	end
	
	local unit, lost
	local pass = function() end
	
	local retarget_scan = CreateFrame("Frame");
	retarget_scan:SetScript('OnUpdate', function()
	--CreateFrame'Frame':SetScript('OnUpdate', function()
		-- Dont need to care about NPC's? 
		--if(UnitIsPlayer('target')) then
			local target = UnitName'target'
			if target then
				--unit, dead, lost = target, oldUnitIsDead'target', false
				unit, dead, lost = target, UnitIsDead'target', false
			elseif unit then
				local _PlaySound, _UIErrorsFrame_OnEvent = PlaySound, UIErrorsFrame_OnEvent
				PlaySound, UIErrorsFrame_OnEvent = lost and PlaySound or pass, pass
				TargetByName(unit, true)
				PlaySound, UIErrorsFrame_OnEvent = _PlaySound, _UIErrorsFrame_OnEvent
				if UnitExists'target' then
					--if not (lost or (not dead and oldUnitIsDead'target' and feigning())) then
					if not (lost or (not dead and UnitIsDead'target' and feigning())) then
						ClearTarget()
						unit, lost = nil, false
					end
				else
					lost = true
					if(UnitIsPlayer('target')) then
						TargetByName(unit, true)
					end
					if not UnitExists'target' then
						unit, lost = nil, false
					end
				end
			end
		--end
	end)
	end
end)

--[[ --just for reference.
	 if not zUI_config then
		zUI_config = {}
	end

	-- check for missing config groups
	if not zUI_config[group] then
		zUI_config[group] = {}
	end

	-- update config
	if not subgroup and entry and value and not zUI_config[group][entry] then
		zUI_config[group][entry] = value
	end

	-- check for missing config subgroups
	if subgroup and not zUI_config[group][subgroup] then
		zUI_config[group][subgroup] = {}
	end
   
	-- update config in subgroup
	if subgroup and entry and value and not zUI_config[group][subgroup][entry] then
		zUI_config[group][subgroup][entry] = value
	end
]]
