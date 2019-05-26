-- Credits to millanzarreta, LoseControl
zUI:RegisterComponent("zLoseControl", function ()

local CC      = "CC"
local Silence = "Silence"
local Disarm  = "Disarm"
local Root    = "Root"
local Snare   = "Snare"
local Immune  = "Immune"
local PvE     = "PvE"

local Prio = {CC,Silence,Disarm,Root,Snare}

local spellIds = {
	-- [ Druid ]
	["Hibernate"] = CC, 
	["Starfire Stun"] = CC,
	["Entangling Roots"] = Root, 
	["Bash"] = CC, 
	["Pounce Bleed"] = CC,
	["Feral Charge Effect"] = Root, 
	-- [ Hunter ]
	["Intimidation"] = CC, 
	["Scare Beast"] = CC, 
	["Scatter Shot"] = CC, 
	["Improved Concussive Shot"] = CC, 
	["Concussive Shot"] = Snare, 
	["Freezing Trap Effect"] = CC, 
	["Freezing Trap"] = CC, 
	["Frost Trap Aura"] = Root, 
	["Frost Trap"] = Root, 
	["Entrapment"] = Root, 
	["Wyvern Sting"] = CC, 
	["Counterattack"] = Root, 
	["Improved Wing Clip"] = Root, 
	["Wing Clip"] = Snare, 
	["Boar Charge"] = Root, 
	-- [ Mage ]
	["Polymorph"] = CC, 
	["Polymorph: Turtle"] = CC, 
	["Polymorph: Pig"] = CC, 
	["Polymorph: Cow"] = CC,
	["Polymorph: Chicken"] = CC, 
	["Counterspell - Silenced"] = Silence, 
	["Impact"] = CC, 
	["Blast Wave"] = Snare,
	["Frostbite"] = Root, 
	["Frost Nova"] = Root, 
	["Frostbolt"] = Snare, 
	["Cone of Cold"] = Snare,  
	["Chilled"] = Snare, 
	-- [ Paladin ]
	["Hammer of Justice"] = CC,
	["Repentance"] = CC, 
	-- [ Priest ]
	["Mind Control"] = CC, 
	["Psychic Scream"] = CC, 
	["Blackout"] = CC,  
	["Silence"] = Silence,  
	["Mind Flay"] = Snare,  
	-- [ Rogue ]
	["Blind"] = CC, 
	["Cheap Shot"] = CC, 
	["Gouge"] = CC,  
	["Kidney Shot"] = CC,  
	["Sap"] = CC, 
	["Kick - Silenced"] = Silence,  
	["Crippling Poison"] = Snare,  
	-- [ Warlock ]
	["Death Coil"] = CC, 
	["Fear"] = CC,  
	["Howl of Terror"] = CC,  
	["Curse of Exhaustion"] = Snare, 
	["Pyroclasm"] = CC,  
	["Aftermath"] = Snare, 
	["Seduction"] = CC,  
	["Spell Lock"] = Silence,  
	["Inferno Effect"] = CC,  
	["Inferno"] = CC,  
	["Cripple"] = Snare,  
	-- [ Warrior ]
	["Charge Stun"] = CC,  
	["Intercept Stun"] = CC,  
	["Intimidating Shout"] = CC,
	["Revenge Stun"] = CC, 
	["Concussion Blow"] = CC, 
	["Piercing Howl"] = Snare,
	["Shield Bash - Silenced"] = Silence,
	-- [ Shaman ] 	
	["Frostbrand Weapon"] = Snare,
	["Frost Shock"] = Snare, 
	["Earthbind"] = Snare, 
	["Earthbind Totem"] = Snare, 
	-- [ Misc ]
	["War Stomp"] = CC, 
	["Tidal Charm"] = CC, 
	["Mace Stun Effect"] = CC, 
	["Stun"] = CC,
	["Gnomish Mind Control Cap"] = CC, 
	["Reckless Charge"] = CC, 
	["Sleep"] = CC, 
	["Dazed"] = Snare,
	["Freeze"] = Root,
	["Chill"] = Snare,
	["Charge"] = CC, 
}

local wipe = function(t)
	for k,v in pairs(t) do
		t[k]=nil
	end
	return t
end

local trackedSpells = {}
local cachedTextures = {}

zUI.zLCTooltip = CreateFrame( "GameTooltip", "zLCTooltip", nil, "GameTooltipTemplate" ); -- Tooltip name cannot be nil
zUI.zLCTooltip:SetFrameStrata("TOOLTIP")
zUI.zLCTooltip:RegisterEvent("PLAYER_ENTERING_WORLD");

zUI.zLCTooltip:SetScript("OnEvent", function()
	-- OnLoad
	zUI.zLCTooltip:SetOwner(UIParent,"ANCHOR_NONE")
	--zUI.zLCTooltip:Hide();
end)

zUI.zLoseControlPlayer = CreateFrame("Frame", "zLoseControlFrame", nil, "ActionButtonTemplate")
zLoseControlFrame:SetMovable(true)
zLoseControlFrame:SetPoint("CENTER", 0, -60)
zLoseControlFrame:RegisterEvent("UNIT_AURA")
zLoseControlFrame:RegisterEvent("PLAYER_AURAS_CHANGED")
zLoseControlFrame:RegisterEvent("VARIABLES_LOADED")
zSkin(zLoseControlFrame,0);
zSkinColor(zLoseControlFrame,0.3,0.3,0.3);

zLoseControlFrame.texture = zLoseControlFrame:CreateTexture(zLoseControlFrame, "BACKGROUND")
zLoseControlFrame.texture:SetAllPoints(zLoseControlFrame)
zLoseControlFrame.cooldown = CreateFrame("Model", "zLoseControlCooldown", zLoseControlFrame, "CooldownFrameTemplate")
zLoseControlFrame.cooldown:SetAllPoints(zLoseControlFrame) 
zLoseControlFrame.cooldown.zCooldownType = "ALL"
zLoseControlFrame.cooldown.zTextSize = 22

zLoseControlFrame.maxExpirationTime = 0
zLoseControlFrame:Hide()
zLoseControlFrame:EnableMouse(false)
zLoseControlFrame:SetUserPlaced(true)
zLoseControlFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

zLoseControlFrame:SetScript("OnEvent", function()
	if event == "VARIABLES_LOADED" then
		LoseControlDB = LoseControlDB or {size=40}
		this:SetHeight(LoseControlDB.size)
		this:SetWidth(LoseControlDB.size)
		return
	end
	trackedSpells = wipe(trackedSpells)
	local spellFound
	for i=1, 16 do -- 16 is enough due to HARMFUL filter
		local texture = UnitDebuff("player", i)
		--local texture, _, dtype = UnitDebuff("player", i)
		zLCTooltip:ClearLines()
		zLCTooltip:SetUnitDebuff("player", i)
		local buffName = zLCTooltipTextLeft1:GetText()
		if spellIds[buffName] ~= nil then
			if cachedTextures[buffName] == nil then cachedTextures[buffName] = texture end
			trackedSpells[table.getn(trackedSpells)+1] = buffName
		end
	end
	if table.getn(trackedSpells) > 1 then
		table.sort(trackedSpells,function(a,b)
				if Prio[spellIds[a]]~=nil and Prio[spellIds[b]]~=nil then
				return Prio[spellIds[a]] < Prio[spellIds[b]] end
				return a > b
			end)
	end
	spellFound = trackedSpells[1] -- highest prio spell
	if (spellFound) then
		for j=0, 31 do
			local buffTexture = GetPlayerBuffTexture(j)
			if cachedTextures[spellFound] == buffTexture then
				local expirationTime = GetPlayerBuffTimeLeft(j)
				--local _, _, dtype = UnitDebuff("player", j + 1)
				local dtype = GetPlayerBuffDispelType(j)
				local colour = DebuffTypeColor[dtype] or DebuffTypeColor['none']
				zSkinColor(zLoseControlFrame, colour.r, colour.g, colour.b);
				this:Show()
				this.texture:SetTexture(buffTexture)
				--this.cooldown:SetModelScale(this:GetEffectiveScale() or 1)
				if this.maxExpirationTime <= expirationTime then
					CooldownFrame_SetTimer(this.cooldown, GetTime(), expirationTime, 1)
					this.maxExpirationTime = expirationTime
				end
				return
			end
		end	
	end
	if spellFound == nil then
		this.maxExpirationTime = 0
		this:Hide()
	end

end)

end)


