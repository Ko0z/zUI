-- Option system credits to Shagu, pfUI
function zUI:UpdateConfig(group, subgroup, entry, value)
  -- create empty config if not existing
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
end
-- C.chat.right.enable == "0"
function zUI:LoadConfig()
--					REGION		SUBGROUP		ENTRY		VALUE
zUI:UpdateConfig( "actionbars", nil, "human_style", "1")
zUI:UpdateConfig( "actionbars", nil, "bfa_style", "1")
zUI:UpdateConfig( "actionbars", nil, "darkmode", "1")
zUI:UpdateConfig( "actionbars", nil, "squarebuttons", "0")
zUI:UpdateConfig( "actionbars", nil, "endcap", "1")

zUI:UpdateConfig( "appearance", "cd", "lowcolor", "1,.1,.1,1")
zUI:UpdateConfig( "appearance", "cd", "normalcolor", "1,0.82,0,1") 
zUI:UpdateConfig( "appearance", "cd", "minutecolor", "0,0.6,0,1")
zUI:UpdateConfig( "appearance", "cd", "hourcolor", ".2,.5,1,1")
zUI:UpdateConfig( "appearance", "cd", "daycolor", "0.6,0,0.6,1")
zUI:UpdateConfig( "appearance", "border", "default", "3")
zUI:UpdateConfig( "appearance", "border", "unitframes", "-1")
zUI:UpdateConfig( "appearance", "castbar", "castbarcolor", "1.0, 0.7, 0.0, 1")
zUI:UpdateConfig( "appearance", "castbar", "channelcolor", "0, 0.56, 1, 1")  
zUI:UpdateConfig( "appearance", "cd", "threshold", "2")
zUI:UpdateConfig( "appearance", "worldmap", "mapreveal", "0")
zUI:UpdateConfig( "appearance", "worldmap", "mapreveal_color", ".4,.4,.4,1")
zUI:UpdateConfig( "appearance", "border", "color", "0.2,0.2,0.2,1")
zUI:UpdateConfig( "appearance", "border", "shadow", "1")
zUI:UpdateConfig( "appearance", "border", "shadow_intensity", ".35")
zUI:UpdateConfig( "appearance", "border", "background", "0,0,0,1")

zUI:UpdateConfig( "aura", nil, "player", "1")
zUI:UpdateConfig( "aura", nil, "above", "0")
zUI:UpdateConfig( "aura", nil, "timers", "1")

zUI:UpdateConfig( "bars", nil, "keydown", "1")
zUI:UpdateConfig( "bars", nil, "glowrange", "1")
zUI:UpdateConfig( "bars", nil, "rangecolor", "1,0.1,0.1,1")

zUI:UpdateConfig( "calculator", nil, "bindings", "1")
zUI:UpdateConfig( "calculator", nil, "decimals", "2")
zUI:UpdateConfig( "calculator", nil, "copperdecimals", "0")

zUI:UpdateConfig( "castbar", "player", "width", "-1")
zUI:UpdateConfig( "castbar", "player", "height", "-1")
zUI:UpdateConfig( "castbar", "target", "width", "-1")
zUI:UpdateConfig( "castbar", "target", "height", "-1")
zUI:UpdateConfig( "castbar", "player", "above", "0")
zUI:UpdateConfig( "castbar", "target", "above", "0")
zUI:UpdateConfig( "castbar", "player", "hide_blizz", "0")
zUI:UpdateConfig( "castbar", "player", "hide_zUI", "1")
zUI:UpdateConfig( "castbar", "target", "hide_zUI", "0")
zUI:UpdateConfig( "castbar", nil, "flat_texture", "1")

zUI:UpdateConfig( "chat", nil, "editbox", "0")
zUI:UpdateConfig( "chat", nil, "ilink", "0")
zUI:UpdateConfig( "chat", nil, "tformat", "1")
zUI:UpdateConfig( "chat", nil, "tstamps", "1")

zUI:UpdateConfig( "global", nil, "microbuttons_auto_hide", "0")
zUI:UpdateConfig( "global", nil, "darkmode", "1")
zUI:UpdateConfig( "global", nil, "font_size", "12")
zUI:UpdateConfig( "global", nil, "font_unit_size", "12")
zUI:UpdateConfig( "global", nil, "offscreen", "0")
zUI:UpdateConfig( "global", nil, "force_region", "1")
zUI:UpdateConfig( "global", nil, "font_default", "Fonts\\FRIZQT__.TTF")
zUI:UpdateConfig( "global", nil, "language", GetLocale())

zUI:UpdateConfig( "gui", nil, "reloadmarker", "0")

zUI:UpdateConfig( "hotkeys", nil, "color", "1,1,1,1")
zUI:UpdateConfig( "hotkeys", nil, "blizzard_font", "1")

zUI:UpdateConfig( "loot", nil, "autoresize", "1")
zUI:UpdateConfig( "loot", nil, "rollannounce", "0")
zUI:UpdateConfig( "loot", nil, "autopickup", "1")
zUI:UpdateConfig( "loot", nil, "mousecursor", "1")
zUI:UpdateConfig( "loot", nil, "advancedloot", "1")
zUI:UpdateConfig( "loot", nil, "rollannouncequal", "3")
zUI:UpdateConfig( "loot", nil, "raritytimer", "1")

zUI:UpdateConfig( "minimap", nil, "square", "0")
zUI:UpdateConfig( "minimap", nil, "height", "140")
zUI:UpdateConfig( "minimap", nil, "width", "140")
zUI:UpdateConfig( "minimap", nil, "scale", "1")
zUI:UpdateConfig( "minimap", nil, "button_pos", "328")
zUI:UpdateConfig( "minimap", nil, "button_hide", "0")
zUI:UpdateConfig( "minimap", nil, "hide_clock", "0")

zUI:UpdateConfig( "nameplates", nil, "castbarcolor", "1.0, 0.7, 0.0, 1")
zUI:UpdateConfig( "nameplates", nil, "flat_health_textures", "0")
zUI:UpdateConfig( "nameplates", nil, "flat_cast_textures", "1")
zUI:UpdateConfig( "nameplates", nil, "font_size", "8")
zUI:UpdateConfig( "nameplates", nil, "showdebuffs", "1")
zUI:UpdateConfig( "nameplates", nil, "showcastbar", "1")
zUI:UpdateConfig( "nameplates", nil, "spellname", "0")
zUI:UpdateConfig( "nameplates", nil, "clickthrough", "0")
zUI:UpdateConfig( "nameplates", nil, "use_unitfonts", "0")
zUI:UpdateConfig( "nameplates", nil, "legacy", "0")
zUI:UpdateConfig( "nameplates", nil, "overlap", "0")
zUI:UpdateConfig( "nameplates", nil, "rightclick", "1")
zUI:UpdateConfig( "nameplates", nil, "clickthreshold", "0.5")
zUI:UpdateConfig( "nameplates", nil, "enemyclassc", "1")
zUI:UpdateConfig( "nameplates", nil, "friendclassc", "1")
zUI:UpdateConfig( "nameplates", nil, "raidiconsize", "16")
zUI:UpdateConfig( "nameplates", nil, "players", "0")
zUI:UpdateConfig( "nameplates", nil, "critters", "0")
zUI:UpdateConfig( "nameplates", nil, "totems", "0")
zUI:UpdateConfig( "nameplates", nil, "showhp", "0")
zUI:UpdateConfig( "nameplates", nil, "vpos", "-10")
zUI:UpdateConfig( "nameplates", nil, "width", "120")
zUI:UpdateConfig( "nameplates", nil, "heighthealth", "8")
zUI:UpdateConfig( "nameplates", nil, "heightcast", "8")
zUI:UpdateConfig( "nameplates", nil, "cpdisplay", "1")
zUI:UpdateConfig( "nameplates", nil, "targethighlight", "0")
zUI:UpdateConfig( "nameplates", nil, "targetzoom", "0")

zUI:UpdateConfig( "quality", nil, "auto_dismount", "1")
zUI:UpdateConfig( "quality", nil, "auto_stance", "1")
zUI:UpdateConfig( "quality", nil, "feign_death", "1")
zUI:UpdateConfig( "quality", "swingtimer", "enable_for_all", "0")
zUI:UpdateConfig( "quality", "swingtimer", "disable", "0")

zUI:UpdateConfig( "skin", nil, "dark", ".2,.2,.2,1")

zUI:UpdateConfig( "swingtimer", nil, "color", "1.0, 1.0, 1.0, 1")

zUI:UpdateConfig( "tooltip", "compare", "showalways", "0")
zUI:UpdateConfig( "tooltip", "compare", "basestats", "1")
zUI:UpdateConfig( "tooltip", "vendor", "showalways", "0")

zUI:UpdateConfig( "unitframes", nil, "classportraits", "1")
zUI:UpdateConfig( "unitframes", nil, "darkmode", "1")
zUI:UpdateConfig( "unitframes", nil, "improvedpet", "1")
zUI:UpdateConfig( "unitframes", nil, "compactmode", "1")
zUI:UpdateConfig( "unitframes", nil, "nameoutline", "1")
zUI:UpdateConfig( "unitframes", nil, "npcclasscolor", "0")
zUI:UpdateConfig( "unitframes", nil, "playerclasscolor", "1")
zUI:UpdateConfig( "unitframes", nil, "forceshowtext", "0")
zUI:UpdateConfig( "unitframes", nil, "percentages", "0")
zUI:UpdateConfig( "unitframes", nil, "trueformat", "0")
zUI:UpdateConfig( "unitframes", nil, "hidepettext", "1")
zUI:UpdateConfig( "unitframes", nil, "healthtexture", "0")
zUI:UpdateConfig( "unitframes", nil, "statusglow", "0")
zUI:UpdateConfig( "unitframes", nil, "coloredtext", "1")
zUI:UpdateConfig( "unitframes", nil, "nametextx", "0")
zUI:UpdateConfig( "unitframes", nil, "nametexty", "5")
zUI:UpdateConfig( "unitframes", nil, "namefontsize", "11")
zUI:UpdateConfig( "unitframes", nil, "valuefontsize", "10")

zUI:UpdateConfig( "position", nil, nil, nil)
zUI:UpdateConfig( "disabled", nil, nil, nil)

end


