zUI:RegisterComponent("zEqcompare", function ()
  local loc = zUI.cache["locale"]
  for key, value in pairs(L["itemtypes"]) do setglobal(key, value) end
  INVTYPE_WEAPON_OTHER = INVTYPE_WEAPON.."_other";
  INVTYPE_FINGER_OTHER = INVTYPE_FINGER.."_other";
  INVTYPE_TRINKET_OTHER = INVTYPE_TRINKET.."_other";

  local slotTable = {
    [INVTYPE_2HWEAPON] = "MainHandSlot",
    [INVTYPE_BODY] = "ShirtSlot",
    [INVTYPE_CHEST] = "ChestSlot",
    [INVTYPE_CLOAK] = "BackSlot",
    [INVTYPE_FEET] = "FeetSlot",
    [INVTYPE_FINGER] = "Finger0Slot",
    [INVTYPE_FINGER_OTHER] = "Finger1Slot",
    [INVTYPE_HAND] = "HandsSlot",
    [INVTYPE_HEAD] = "HeadSlot",
    [INVTYPE_HOLDABLE] = "SecondaryHandSlot",
    [INVTYPE_LEGS] = "LegsSlot",
    [INVTYPE_NECK] = "NeckSlot",
    [INVTYPE_RANGED] = "RangedSlot",
    [INVTYPE_RELIC] = "RangedSlot",
    [INVTYPE_ROBE] = "ChestSlot",
    [INVTYPE_SHIELD] = "SecondaryHandSlot",
    [INVTYPE_SHOULDER] = "ShoulderSlot",
    [INVTYPE_TABARD] = "TabardSlot",
    [INVTYPE_TRINKET] = "Trinket0Slot",
    [INVTYPE_TRINKET_OTHER] = "Trinket1Slot",
    [INVTYPE_WAIST] = "WaistSlot",
    [INVTYPE_WEAPON] = "MainHandSlot",
    [INVTYPE_WEAPON_OTHER] = "SecondaryHandSlot",
    [INVTYPE_WEAPONMAINHAND] = "MainHandSlot",
    [INVTYPE_WEAPONOFFHAND] = "SecondaryHandSlot",
    [INVTYPE_WRIST] = "WristSlot",

    [INVTYPE_WAND] = "RangedSlot",
    [INVTYPE_GUN] = "RangedSlot",
    [INVTYPE_PROJECTILE] = "AmmoSlot",
    [INVTYPE_CROSSBOW] = "RangedSlot",
    [INVTYPE_THROWN] = "RangedSlot",
  }

  local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
  end

  local function ExtractAttributes(tooltip)
    local name = tooltip:GetName()

    -- get the name/header of the last set comparison tooltip
    local comparetooltip = zUI.eqcompare.tooltip:GetName()
    local iname = _G[comparetooltip .. "TextLeft1"] and _G[comparetooltip .. "TextLeft1"]:GetText()

    -- only run once per item
    if tooltip.zCompLastName == iname then return end

    tooltip.zCompData = {}
    tooltip.zCompLastName = iname

    for i=1,30 do
      local widget = _G[name.."TextLeft"..i]
      if widget and widget:GetObjectType() == "FontString" then
        local text = widget:GetText()
        if text and not string.find(text, "-", 1, true) then
          local start = 1
          if startsWith(text, "\+") or startsWith(text, "\(") then start = 2 end

          local space = string.find(text, " ", 1, true)
          if space then
            local value = tonumber(string.sub(text, start, space-1))
            if value and text then
              -- we've found an attr
              local attr = string.sub(text, space, string.len(text))
              tooltip.zCompData[attr] = { value = tonumber(value), widget = widget }
            end
          end
        end
      end
    end
  end

  local function CompareAttributes(data, targetData)
    if not data then return end

    for attr,v in pairs(data) do
      if targetData then
        local target = targetData[attr]
        if target then
          if v.value ~= target.value and v.widget:GetText() then
            if v.value > target.value then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")
				--v.widget:SetWidth(2000); --added
				--zUI.eqcompare.tooltip:SetWidth(v:GetWidth() + 120);
				--v:SetWidth(2000);
              end
            elseif not v.widget.compSet then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(target.value - v.value, 1) .. ")")
				--v.widget:SetWidth(2000); --added
				--v:SetWidth(2000);
				--zUI.eqcompare.tooltip:SetWidth(v:GetWidth() + 120);
              end
            end
            target.processed = true
          else
            target.processed = true
          end
        else
          -- this attribute doesnt exist in target
		  if v.widget and v.widget:GetText() then
			if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
				v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. v.value .. ")")
			end
		  end
        end
      end
    end

    for _,target in pairs(targetData) do
      if target and not target.processed then
        -- we are an extra value
        if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
          target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. target.value .. ")")
		  --zUI.eqcompare.tooltip:SetWidth(500);

		  --zUI.eqcompare.tooltip:SetWidth(zUI.eqcompare.tooltip:GetWidth() + target.widget:GetWidth() + 20);

		  --this:SetWidth(SmallTextTooltipText:GetWidth() + 20);
        end
      end
    end
  end

  zUI.eqcompare = {}
  zUI.eqcompare.GameTooltipShow = function()
    -- use this tooltip for the next comparison
    zUI.eqcompare.tooltip = this

    if not IsShiftKeyDown() and C.tooltip.compare.showalways ~= "1" then return end
    --local border = tonumber(C.appearance.border.default)

    for i=1,this:NumLines() do
      local tmpText = _G[this:GetName() .. "TextLeft"..i]
      for slotType, slotName in pairs(slotTable) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(slotTable[slotType])

          -- determine screen part
          local ltrigger = GetScreenWidth() / 2
          local x = GetCursorPosition()
          x = x / UIParent:GetEffectiveScale()
          if x > ltrigger then ltrigger = nil end

          -- first tooltip
          ShoppingTooltip1:SetOwner(this, "ANCHOR_NONE");
          ShoppingTooltip1:ClearAllPoints();

          if ltrigger then
            ShoppingTooltip1:SetPoint("BOTTOMLEFT", this, "BOTTOMRIGHT", 0, 0);
          else
            --ShoppingTooltip1:SetPoint("BOTTOMRIGHT", this, "BOTTOMLEFT", -border*2-1, 0);
			ShoppingTooltip1:SetPoint("BOTTOMRIGHT", this, "BOTTOMLEFT", 0, 0);
          end

          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show();

          -- second tooltip
          if slotTable[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(slotTable[slotType .. "_other"])

            ShoppingTooltip2:SetOwner(this, "ANCHOR_NONE");
            ShoppingTooltip2:ClearAllPoints();

            if ltrigger then
              ShoppingTooltip2:SetPoint("BOTTOMLEFT", ShoppingTooltip1, "BOTTOMRIGHT", 0, 0);
            else
              --ShoppingTooltip2:SetPoint("BOTTOMRIGHT", ShoppingTooltip1, "BOTTOMLEFT", -border*2-1, 0);
			  ShoppingTooltip2:SetPoint("BOTTOMRIGHT", ShoppingTooltip1, "BOTTOMLEFT", 0, 0);
            end

            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show();
          end
          return true
        end
      end
    end
  end

  zUI.eqcompare.ShoppingTooltipShow = function()
    -- abort if no comparison tooltip has been set
    if not zUI.eqcompare.tooltip then return end

    ExtractAttributes(this)
    ExtractAttributes(zUI.eqcompare.tooltip)
    CompareAttributes(zUI.eqcompare.tooltip.zCompData, this.zCompData)
  end

  -- Add Gametooltip Hooks
  HookScript(GameTooltip, "OnShow", zUI.eqcompare.GameTooltipShow)
  if C.tooltip.compare.basestats == "1" then
    HookScript(ShoppingTooltip1, "OnShow", zUI.eqcompare.ShoppingTooltipShow)
    HookScript(ShoppingTooltip2, "OnShow", zUI.eqcompare.ShoppingTooltipShow)
  end
end)
