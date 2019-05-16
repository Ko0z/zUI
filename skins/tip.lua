zUI:RegisterSkin("Tooltips", function () --modui inspired
	local cr,cg,cb,ca = strsplit(",", zUI_config.skin.dark)
    local f = { 
        -- tips
        GameTooltip,
        ItemRefTooltip,
        ItemRefShoppingTooltip1, --doesnt seem to exist
        ItemRefShoppingTooltip2,
        ItemRefShoppingTooltip3,
        ShoppingTooltip1,
        ShoppingTooltip2,
        ShoppingTooltip3,
        WorldMapTooltip,
        WorldMapCompareTooltip1,
        WorldMapCompareTooltip2,
        WorldMapCompareTooltip3,
        FriendsTooltip,
        -- dropdowns
        DropDownList1MenuBackdrop,
        DropDownList2MenuBackdrop,
        DropDownList3MenuBackdrop,
        ChatMenu,
        EmoteMenu,
        LanguageMenu,
        TutorialFrame
    }

    --if not skin.enable then return end
    for i, v in pairs (f) do
        zSkin(v, 4)
        zSkinColor(v, cr, cg, cb)
		--zSkinColor(v, 0, 0, 0)
		--f:SetVertexColor(0.1,0.1,0.1,1);
		if (C.global.darkmode == "1") then
			v:SetBackdropColor(0,0,0,1);
		end
    end
    
end)