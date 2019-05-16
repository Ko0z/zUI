zUI:RegisterComponent("zInstaCast", function () -- ClassicSnowFall inspired. pet support by Road-block
--[[
local print = function(msg) if msg then DEFAULT_CHAT_FRAME:AddMessage(msg) end end
local bongos = IsAddOnLoaded("Bongos_ActionBar")

SLASH_CS1 = "/csselfcast"	-- TODO rename.
SlashCmdList["CS"] = zUI.ToggleSelfCast;

hooksecurefunc("ActionButtonDown", function(id)
	local button,pagedID;
	print(onSelf);
	if bongos == nil then
		if ( BonusActionBarFrame:IsShown() ) then
			local button = getglobal("BonusActionButton"..id);
			if ( button:GetButtonState() == "NORMAL" ) then
				button:SetButtonState("PUSHED");
				UseAction(ActionButton_GetPagedID(button), 0, zUI.SelfCast());
			end
			return;
		end

		button = getglobal("ActionButton"..id)
		
		if (button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
			UseAction(ActionButton_GetPagedID(button), 0, zUI.SelfCast());
		end
	else
		button = getglobal("BActionButton"..id)
		pagedID = BActionButton.GetPagedID(id);
		if (button and button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
		end
		UseAction(pagedID, 0);
	end
end)

hooksecurefunc("ActionButtonUp", function(id, onSelf)
	local button
	if bongos == nil then
		if ( BonusActionBarFrame:IsShown() ) then
			local button = getglobal("BonusActionButton"..id);
			if ( button:GetButtonState() == "PUSHED" ) then
				button:SetButtonState("NORMAL");
				if ( MacroFrame_SaveMacro ) then
					MacroFrame_SaveMacro();
				end
				if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
					button:SetChecked(1);
				else
					button:SetChecked(0);
				end
			end
			return;
		end

		button = getglobal("ActionButton"..id)
		if ( button and button:GetButtonState() == "PUSHED" ) then	--setColors here?
			button:SetButtonState("NORMAL");
			if ( MacroFrame_SaveMacro ) then
				MacroFrame_SaveMacro();
			end
			if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
				button:SetChecked(1);
			else
				button:SetChecked(0);
			end
		end
	else
		button = getglobal("BActionButton"..id)
		if ( button and button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			if ( MacroFrame_SaveMacro ) then
				MacroFrame_SaveMacro();
			end
			button:SetChecked(IsCurrentAction(BActionButton.GetPagedID(id)));
		end
	end
end)

hooksecurefunc("MultiActionButtonDown", function(bar, id)
	local button;
	button = getglobal(bar.."Button"..id);

	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
		UseAction(ActionButton_GetPagedID(button), 0, zUI.SelfCast());
	end
end)
--if C.bars.keydown == "1" then
hooksecurefunc("MultiActionButtonUp", function(bar, id, onSelf)
	local button = getglobal(bar.."Button"..id);
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		if ( MacroFrame_SaveMacro ) then
			MacroFrame_SaveMacro();
		end
		
		if ( IsCurrentAction(ActionButton_GetPagedID(button)) ) then
			button:SetChecked(1);
		else
			button:SetChecked(0);
		end
	end
end)

hooksecurefunc("PetActionButtonDown", function(id)
	local button = getglobal("PetActionButton"..id);
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
		CastPetAction(id);
	end
end)

hooksecurefunc("PetActionButtonUp", function(id)
	local button = getglobal("PetActionButton"..id);
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
	end
end)

function zUI.SelfCast()
	if (CS_SELF_ENABLED) then
		return IsAltKeyDown();
	else
		return 0;
	end
end

function zUI.ToggleSelfCast()
	if (CS_SELF_ENABLED) then
		CS_SELF_ENABLED = false
		print("Classic Snowfall ALT SelfCast now disabled.") -- TODO: Options, integrate with zUI  
	else
		CS_SELF_ENABLED = true
		print("Classic Snowfall ALT SelfCast now enabled.")
	end
end
]]
	
	-- todo add self cast. maybe split "insta-cast" and button design in to separate..
	if C.bars.keydown == "1" then
		--hooksecurefunc("ActionButton_OnUpdate", function(elapsed)
		--	AddBorderColour(GetTime())
		--end,true)
		
		hooksecurefunc("ActionButtonDown", function(id)	-- todo get an option for this!!! and all other colors..
			ActionButtonUp(id)
			if ( BonusActionBarFrame:IsShown() ) then
				local button = getglobal("BonusActionButton"..id);
				zSkinColor(button, 255/255, 240/255, 0/255)
				button:SetChecked(1);
			end
			local button = getglobal("ActionButton"..id)
			zSkinColor(button, 255/255, 240/255, 0/255)
			button:SetChecked(1);
		end, true)

		hooksecurefunc("ActionButtonUp", function(id)
			if ( BonusActionBarFrame:IsShown() ) then
				local button = getglobal("BonusActionButton"..id);
				zSkinColor(button, .2, .2, .2); 
				button:SetChecked(0);
			end
			local button = getglobal("ActionButton"..id)
			zSkinColor(button, .2, .2, .2); 
			button:SetChecked(0);
		end, true)

		hooksecurefunc("MultiActionButtonDown", function(bar, id)
			MultiActionButtonUp(bar, id)
			local button = getglobal(bar.."Button"..id);
			zSkinColor(button, 255/255, 240/255, 0/255)
			button:SetChecked(1);
		end, true)

		hooksecurefunc("MultiActionButtonUp", function(bar, id, onSelf)
			local button = getglobal(bar.."Button"..id);
			zSkinColor(button, .2, .2, .2);
			button:SetChecked(0);
		end, true)

		--------------==[ Pet ]==---------------------------------------
		hooksecurefunc("PetActionButtonDown", function(id) -- dont need final say with these functions I think. wrong?!
			--PetActionButtonUp(id) --added
			local button = getglobal("PetActionButton"..id);
			--zSkinColor(button, 255/255, 240/255, 0/255) --added
			--button:SetChecked(1); --added
			if ( button:GetButtonState() == "NORMAL" ) then
				button:SetButtonState("PUSHED");
				CastPetAction(id);
			end
		end)

		hooksecurefunc("PetActionButtonUp", function(id)
			local button = getglobal("PetActionButton"..id);
			--zSkinColor(button, .2, .2, .2); --added
			--button:SetChecked(0); --added
			if ( button:GetButtonState() == "PUSHED" ) then
				button:SetButtonState("NORMAL");
			end
		end)
	end

end)