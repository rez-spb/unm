--[[ IMPERATIVES for UNM coding:
	CHECK = needs checking, probably unused var or something's just fishy here (he-he, get it?)
	FIX = fix needed
	TODO = some rework (redesign) is needed here
--]]

if not _G.NoobJoin then
	_G.NoobJoin = _G.NoobJoin or {}		-- CHECK: a bit of a mistery here: if NOT exists _G.NoobJoin, then _G.NoobJoin = _G.NoobJoin? It should always be {}, right?
	NoobJoin._path = ModPath		-- BLT-specific, points to mod's root directory
	NoobJoin._data_path = SavePath .. "unm_savefile.txt"	-- saving data to file
	NoobJoin._loc_path = NoobJoin._path .. "loc/"	-- path for localization
	--[[ [UNM-18] Pretty print for JSON (setting prepare)
	NoobJoin._pretty = {			-- pretty encode for JSON4Lua pretty_print branch (currently in pull requests)
		sort_keys=true,			-- sort keys alphanum
		pretty=true,			-- insert spaces after ':' and breaks after ','
		indent=4,			-- indent size in, spaces
		}
	]]--
	NoobJoin.settings = {			-- defaults (in case we don't have a file to read from)
		friend_whitelist_val = true,	-- whitelist friends by default
		kickhidden_val = false,		-- don't kick hidden players
		Toggle = 1,			-- enable kicking, FIX: register
		localised_message = false,	-- TODO: localization should become the only way
		broadcastinfo_val = true,	-- broadcast to everyone if server
		perkdeck0_val = false,		-- FIX: variable does not have underscore, others do
		perkdeck_1_val = false,		-- TODO: maybe we can optimize this?
		perkdeck_2_val = false,
		perkdeck_3_val = false,
		perkdeck_4_val = false,
		perkdeck_5_val = false,
		perkdeck_6_val = false,
		perkdeck_7_val = false,
		perkdeck_8_val = false,
		perkdeck_9_val = false,
		perkdeck_10_val = false,
		perkdeck_11_val = false,
		perkdeck_12_val = false,
		perkdeck_13_val = false,
		perkdeck_14_val = false,
		perkdeck_15_val = false,
		show_perks_info_val = true,	-- print (? CHECK) info about perks in chat
		hiddeninfamycheck = true,	-- check infamy on hidden profiles
		hiddeninfamy = 2,		-- minimum infamy not to be kicked
		hiddeninfamymax = 26,		-- maximum infamy not to be kicked
		noequipment = false,
		singleturret = false,
		bodybags = false,
		armorkit = false,
		singleecm = false,
		fourfaks = false,
		armor1 = false,
		armor2 = false,
		armor3 = false,
		armor4 = false,
		armor5 = false,
		armor6 = false,
		armor7 = false,
		incompletedeck = false,		-- kick incomplete perk deck
		hiddenxxv = false,		-- hidden XXV-100 kick (FIX: variable name is awful)
		hiddenv = false,		-- hidden V-100 kick (FIX: variable name is awful)
		usepd2statsanticheat = true,	-- use PD2 stats
		tag_not_enough_heists_completed = false,	-- CHECK
		deathwish_count_enable = false,
		deathwish_count = 1,
		total_count_enable = false,
		total_count = 1,
		Noob_language = 1,		-- language selector? FIX: variable name
		Stats_Print = true,		-- print stats. FIX: variable name
		ingame_anticheat = true,	-- R54 new, CHECK
		}
		
	NoobJoin.Name = "UNM"			-- name for prefix only? CHECK.
	NoobJoin.Prefix = "[" .. NoobJoin.Name .. "]"	-- prefix for chat

	-- colors
	NoobJoin.Colors = {"E3001A", "00D000", "007DD9"}	-- colors: BAN, INFO, WHITELIST. TODO: named arrays
	NoobJoin.Colors["kick"] = "E3001A"	-- color for kicking
	NoobJoin.Colors["info"] = "00D000"	-- color for information
	NoobJoin.Colors["whitelist"] = "007DD9"	-- color for whitelisting

	-- blacklist and whitelist
	NoobJoin.blacklist = {}
	NoobJoin.blacklist_file = ModPath .. "blacklist.ini"
	NoobJoin.whitelist = {}			-- whitelist table
	NoobJoin.whitelist_file = ModPath .. "whitelist.ini"
	
	NoobJoin.synced = {}			-- no idea. CHECK
	NoobJoin.Players = {}			-- FIX: case
	-- check for big lobby mod. CHECK: will we have a number here (like 1 and 10 = 10?)
	local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
	for i=1,num_player_slots do		-- peer info
		NoobJoin.Players[i] = {}
		for j=1,4 do			-- Skill printed, cheater, skills for overlay, join time
			NoobJoin.Players[i][j] = 0
		end
	end
	
	-- read blacklist file
	local bl, _ = io.open(NoobJoin.blacklist_file, "r")
	if bl then	-- read it to NoobJoin.blacklist table
		for line in bl:lines() do
			if string.sub(line, 1,1) ~= ";" then
				table.insert(NoobJoin.blacklist, line)
			end
		end
	else		-- if not, create it
		log(NoobJoin.Prefix .. " Creating " .. NoobJoin.blacklist_file)
		bl = io.open(NoobJoin.blacklist_file, "w")
	end
	bl:close()	-- close file

	-- read whitelist file
	local wl, _ = io.open(NoobJoin.whitelist_file, "r")
	if wl then	-- read it to NoobJoin.whitelist table
		for line in wl:lines() do
			if string.sub(line, 1,1) ~= ";" then
				table.insert(NoobJoin.whitelist, line)
			end
		end
	else		-- if not, create it
		log(NoobJoin.Prefix .. " Creating " .. NoobJoin.whitelist_file)
		wl = io.open(NoobJoin.whitelist_file, "w")
	end
	wl:close()	-- close file
	
	-- TODO: maybe uncomment this later
	-- kicklist mod? FIX: hardcoded, no path, can be absent
	--local file1, err = io.open("kicklist.ini", "r")
	--if file1 then
	--	for line in file1:lines() do
	--		table.insert(NoobJoin.blacklist, line)
	--	end
	--	file1:close()
	--end
end


function NoobJoin:Load()
	--[[	Function from Options.lua in R41
		Loads file '_data_path'
	]]
	local file = io.open(NoobJoin._data_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			NoobJoin.settings[k] = v
		end
		file:close()
	end
end


function NoobJoin:Save()
	--[[	Function from Options.lua in R41
		Saves file '_data_path'
	]]
	local file = io.open(NoobJoin._data_path, "w+")
	if file then
		file:write(json.encode(NoobJoin.settings))
		file:close()
	end
end


-- load languages to options.txt in game
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoobJoinInitial", function(loc)
	loc:load_localization_file(NoobJoin._loc_path .. "initial.txt")
end)

-- select language based on settings
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoobJoin", function(loc)
	NoobJoin:Load()
	local lang="english"
	if NoobJoin.settings.Noob_language == 1 then
		lang="english"
--[[	elseif NoobJoin.settings.Noob_language == 2 then
		lang="french"
	elseif NoobJoin.settings.Noob_language == 3 then
		lang="russian"
	elseif NoobJoin.settings.Noob_language == 4 then
		lang="german"
	elseif NoobJoin.settings.Noob_language == 5 then
		lang="italian"
	elseif NoobJoin.settings.Noob_language == 6 then
		lang="dutch"
	elseif NoobJoin.settings.Noob_language == 7 then
		lang="spanish"
	elseif NoobJoin.settings.Noob_language == 8 then
		lang="turkish"
	elseif NoobJoin.settings.Noob_language == 9 then
		lang="chinese"
	elseif NoobJoin.settings.Noob_language == 10 then
		lang="czech"
]]
	end
	loc:load_localization_file(NoobJoin._loc_path .. lang .. ".txt")
end)


Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_NoobJoin", function(menu_manager)
	NoobJoin.Toggle = function(self)
		if Network:is_server() and NoobJoin:inChat() == false and Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill" then
			if NoobJoin.settings.Toggle == 1 then
				NoobJoin.settings.Toggle = 0
				NoobJoin:Save()
				NoobJoin:Debug_Message(managers.localization:text("kick_option_off"), NoobJoin.Colors[1])
			else
				local Kick = ""
				local message = ""
				local number = 0
				local sum = 0
				local peer = managers.network:session():peer(1)
				dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. Steam:userid()  .. "&force=1",
				function(page)
					local reason = ""
					local IsNoobJoinastring = ""
					local cheater = false	-- not enough heists from pd2stats
					local cheater1 = false
					message = ""
					for param, val in string.gmatch(page, "([%w_]+)=([%w_]+)") do
						if string.len(val) > 17 then
							reason = string.gsub(val, "_", " ")
							IsNoobJoinastring = string.find(reason, "Not enough heists completed") and true or false
							if IsNoobJoinastring == false then
								message = reason
								cheater = true
								NoobJoin:Debug_Message(message, NoobJoin.Colors[1])
							end
						end
					end
					local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
					if #skills_perk_deck_info == 2 then
						local skills = string.split(skills_perk_deck_info[1], "_")
						cheater1 = NoobJoin:Skill_cheater(skills, peer)
					end
					if cheater == true or cheater1 == true then
						if cheater1 == true then
							message = "Cheated, too many skill points"
						end
						NoobJoin.settings.Toggle = 0
						NoobJoin:Save()
						-- FIX: if cheater == true, but cheater1 ~= true, we have empty message!
						NoobJoin:Debug_Message(message, NoobJoin.Colors[1])
					else
						NoobJoin.settings.Toggle = 1
						NoobJoin:Save()
						if NoobJoin.settings.kickhidden_val == true then
							Kick = " " .. managers.localization:text("kick_option_on_5")
						else
							Kick = " " .. managers.localization:text("kick_option_on_4")
						end
						message = managers.localization:text("kick_option_on_1") .. NoobJoin:Return_Minimum_Hours(Global.game_settings.difficulty, Global.game_settings.job_plan) .. " " .. managers.localization:text("kick_option_on_2")
						NoobJoin:Debug_Message(message, NoobJoin.Colors[3], managers.localization:text("kick_option_on_3") .. Kick)
					end
				end)
			end
		end
	end
	
	NoobJoin.SkillInfo = function(self)
		if managers.network:session() then
		-- why two calls?
			-- first call is local call, does not display your info without it
			NoobJoin:Information_To_HUD(managers.network:session():peer(_G.LuaNetworking:LocalPeerID()))
			-- there is no local peer in here
			for _, peer in pairs(managers.network:session():peers()) do
				NoobJoin:Information_To_HUD(peer)
			end
			-- from R41 - CHECK old style!
			--managers.mission._fading_debug_output:script().log(NoobJoin.Name, Color(NoobJoin.Colors[2]))
			NoobJoin:Debug_Message()
		end
	end
	
	NoobJoin.ManualBan = function(self)
		if managers.network._session and #managers.network:session():peers() > 0 then
			local menu_options = {}
			for _, peer in pairs(managers.network:session():peers()) do
				if peer:rank() and peer:level() then
					menu_options[#menu_options+1] = {text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Manual_Add_To_Blacklist}
				else
					menu_options[#menu_options+1] = {text = peer:name(), data = peer:id(), callback = Manual_Add_To_Blacklist}
				end
			end
			menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
			local menu = QuickMenu:new(NoobJoin.Name, managers.localization:text("Manual_ban_select"), menu_options)
			menu:Show()
		end
	end
	
	NoobJoin.PlayerInspect = function(self)
		if managers.network._session then
			local menu_options = {}
			local peer = managers.network._session:peer(_G.LuaNetworking:LocalPeerID())
			menu_options[1] ={text = peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
			for _, peer in pairs(managers.network:session():peers()) do
				if peer:rank() and peer:level() then
					menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
				else
					menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
				end
			end
			menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
			local menu = QuickMenu:new(NoobJoin.Name, managers.localization:text("player_inspection"), menu_options)
			menu:Show()
		end
	end
	
	-- Create buttons
	-- UNM whitelist
	MenuCallbackHandler.friend_whitelist_cb = function(this, item)
		NoobJoin.settings.friend_whitelist_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.ngbto_language_cb = function(this, item)
		NoobJoin.settings.Noob_language = item:value()
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_loud_dw = function(this, item)
		NoobJoin.settings.min_hours_loud_dw_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_stealth_dw = function(this, item)
		NoobJoin.settings.min_hours_stealth_dw_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_loud_ovk = function(this, item)
		NoobJoin.settings.min_hours_loud_ovk_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_stealth_ovk = function(this, item)
		NoobJoin.settings.min_hours_stealth_ovk_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_loud_vh = function(this, item)
		NoobJoin.settings.min_hours_loud_vh_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.min_hours_stealth_vh = function(this, item)
		NoobJoin.settings.min_hours_stealth_vh_val = math.floor(item:value())
		NoobJoin:Save()
	end
	MenuCallbackHandler.kickhidden_dw = function(this, item)
		NoobJoin.settings.kickhidden_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.hiddenkickinfamy = function(this, item)
		NoobJoin.settings.hiddeninfamycheck = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.hiddeninfamylevel = function(this, item)
		NoobJoin.settings.hiddeninfamy = item:value()
		NoobJoin:Save()
	end
	MenuCallbackHandler.hiddeninfamymaxlevel = function(this, item)
		NoobJoin.settings.hiddeninfamymax = item:value()
		NoobJoin:Save()
	end
	MenuCallbackHandler.broadcastinfo_dw = function(this, item)
		NoobJoin.settings.broadcastinfo_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.stats_print_info = function(this, item)
		NoobJoin.settings.Stats_Print = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck0 = function(this, item)
		NoobJoin.settings.perkdeck0_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.show_perks_info = function(this, item)
		NoobJoin.settings.show_perks_info_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.localised_message_cb = function(this, item)
		NoobJoin.settings.localised_message = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	--perk decks
	MenuCallbackHandler.perkdeck1_kick = function(this, item)
		NoobJoin.settings.perkdeck_1_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck2_kick = function(this, item)
		NoobJoin.settings.perkdeck_2_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck3_kick = function(this, item)
		NoobJoin.settings.perkdeck_3_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck4_kick = function(this, item)
		NoobJoin.settings.perkdeck_4_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck5_kick = function(this, item)
		NoobJoin.settings.perkdeck_5_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck6_kick = function(this, item)
		NoobJoin.settings.perkdeck_6_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck7_kick = function(this, item)
		NoobJoin.settings.perkdeck_7_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck8_kick = function(this, item)
		NoobJoin.settings.perkdeck_8_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck9_kick = function(this, item)
		NoobJoin.settings.perkdeck_9_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck10_kick = function(this, item)
		NoobJoin.settings.perkdeck_10_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck11_kick = function(this, item)
		NoobJoin.settings.perkdeck_11_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck12_kick = function(this, item)
		NoobJoin.settings.perkdeck_12_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck13_kick = function(this, item)
		NoobJoin.settings.perkdeck_13_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck14_kick = function(this, item)
		NoobJoin.settings.perkdeck_14_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.perkdeck15_kick = function(this, item)
		NoobJoin.settings.perkdeck_15_val = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	--end of perk decks
	MenuCallbackHandler.noequipmentcb = function(this, item)
		NoobJoin.settings.noequipment = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.singleturretcb = function(this, item)
		NoobJoin.settings.singleturret = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.bodybagscb = function(this, item)
		NoobJoin.settings.bodybags = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorkitcb = function(this, item)
		NoobJoin.settings.armorkit = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.singleecmcb = function(this, item)
		NoobJoin.settings.singleecm = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.fourfakscb = function(this, item)
		NoobJoin.settings.fourfaks = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	--end of equipment
	MenuCallbackHandler.NoobJoinSave = function(this, item)
		NoobJoin:Save()
	end
	MenuCallbackHandler.usepd2statsanticheatcb = function(this, item)
		NoobJoin.settings.usepd2statsanticheat = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.usepd2statsanticheatheistscb = function(this, item)
		NoobJoin.settings.tag_not_enough_heists_completed = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.incompletecb = function(this, item)
		NoobJoin.settings.incompletedeck = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.hiddenxxvcb = function(this, item)
		NoobJoin.settings.hiddenxxv = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.hiddenvcb = function(this, item)
		NoobJoin.settings.hiddenv = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	--armor
	MenuCallbackHandler.armorlvl1cb = function(this, item)
		NoobJoin.settings.armor1 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl2cb = function(this, item)
		NoobJoin.settings.armor2 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl3cb = function(this, item)
		NoobJoin.settings.armor3 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl4cb = function(this, item)
		NoobJoin.settings.armor4 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl5cb = function(this, item)
		NoobJoin.settings.armor5 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl6cb = function(this, item)
		NoobJoin.settings.armor6 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.armorlvl7cb = function(this, item)
		NoobJoin.settings.armor7 = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	--end of armor
	MenuCallbackHandler.total_count_kick_cb = function(this, item)
		NoobJoin.settings.total_count_enable = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.deathwish_count_cb = function(this, item)
		NoobJoin.settings.deathwish_count_enable = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.ingame_anticheat_cb = function(this, item)
		NoobJoin.settings.ingame_anticheat = (item:value() == "on" and true or false)
		NoobJoin:Save()
	end
	MenuCallbackHandler.total_count_enable_number_cb = function(this, item)
		NoobJoin.settings.total_count = item:value()
		NoobJoin:Save()
	end
	MenuCallbackHandler.deathwish_count_kick_cb = function(this, item)
		NoobJoin.settings.deathwish_count = item:value()
		NoobJoin:Save()
	end
	NoobJoin:Load()
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/options.txt", NoobJoin, NoobJoin.settings)
end)

-- Information about mod settings
Hooks:PostHook(MenuCallbackHandler, "start_job", "NoobJoin:ContractBuy", function(self, job_data)
	--[[	Hook from MenuManager.lua in R41
	]]
	if not Global.game_settings.job_plan then
		Global.game_settings.job_plan = -1
	end
	DelayedCalls:Add("NoobJoin:Delayed_Contract_Buy", 2, function()
		if Network:is_server() then
			dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. Steam:userid() .. "&force=1",
			function(page)
				local IsNoobJoinastring = ""
				local Ischeater = false
				local message = ""
				local hidden = ""
				local number = 0
				local sum = 0
				local skillcheat = false
				local peer = managers.network:session():peer(1)
				for param, val in string.gmatch(page, "([%w_]+)=([%w_]+)") do
					if string.len(val) > 17 then
						message = string.gsub(val, "_", " ")
						IsNoobJoinastring = string.find(message, "Not enough heists completed") and true or false
						if IsNoobJoinastring == false then
							Ischeater = true
						end
					end
				end
				local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
				if #skills_perk_deck_info == 2 then
					local skills = string.split(skills_perk_deck_info[1], "_")
					skillcheat = NoobJoin:Skill_cheater(skills)
				end
				
				if Ischeater == true or skillcheat == true then
					if skillcheat == true then
						message = "Cheated, too many skill points"
					end
					NoobJoin.settings.Toggle = 0
					NoobJoin:Debug_Message(message, NoobJoin.Colors[1])
					NoobJoin:Save()
				end
				if NoobJoin.settings.Toggle == 1 then
					local hours = NoobJoin:Return_Minimum_Hours()
					if hours == 0 then
						message = managers.localization:text("lobby_not_supported") .. ". "
						if NoobJoin.settings.kickhidden_val == true then
							message = message .. managers.localization:text("hidden_kick_on") .. "."
							NoobJoin:Debug_Message(message, NoobJoin.Colors[3])
						end
					elseif hours ~= -1 then
						if NoobJoin.settings.kickhidden_val == true then
							hidden = managers.localization:text("lobby_create_message_2") .. " "
						end
						message = managers.localization:text("lobby_create_message_1") .. " " .. hidden .. managers.localization:text("lobby_create_message_3")
						message = message .. " " .. hours .. " " .. managers.localization:text("lobby_create_message_4")
						NoobJoin:Debug_Message(message, NoobJoin.Colors[3])
					else
						NoobJoin:Debug_Message(managers.localization:text("lobby_not_supported"), NoobJoin.Colors[3])
					end
					
				else
					NoobJoin:Debug_Message(managers.localization:text("NGBTO_Off"), NoobJoin.Colors[1])
				end
			end)
		end
	end)
end)

------------------------------| Copied from UNM
function NoobJoin:Is_Friend(user_id)
-- Checks whether user_id is a friend on Steam
------------------------------------------------------------------------
-- user_id:	steam64 user ID
	local is_friend = false
	if Steam:logged_on() then
		for _, friend in ipairs(Steam:friends() or {}) do
			if friend:id() == user_id then
				is_friend = true
				break
			end
		end
	end
	return is_friend
end
------------------------------| New in R55, merged with UNM
function NoobJoin:Player_Announce(peer, bool)
-- Sends message and initiates pd2stats api check if not whitelisted and
-- not banned
------------------------------------------------------------------------
-- peer:	peer object
-- bool:	passed to PD2Stats_API_Check() as true or false
	if NoobJoin:is_from_whitelist(peer:user_id()) == true then
		message = peer:name() .. " " .. managers.localization:text("player_whitelist")
		NoobJoin:Message_Receive(message, "whitelist")
	elseif NoobJoin:Is_From_Blacklist(peer:user_id()) == true then
		message = peer:name() .. " " .. managers.localization:text("player_blacklist")
		NoobJoin:Message_Receive(message, "kick")
	elseif NoobJoin:Is_Friend(peer:user_id()) == true then
		message = peer:name() .. " " .. managers.localization:text("player_friendlist")
		NoobJoin:Message_Receive(message, "whitelist")
		if NoobJoin.settings.friend_whitelist_val == false then
			NoobJoin:PD2Stats_API_Check(peer:user_id(), peer:id(), bool)
		end
	else
		NoobJoin:PD2Stats_API_Check(peer:user_id(), peer:id(), bool)
	end
end
------------------------------| CHECK: new in R54
function Manual_Add_To_Blacklist(id)
-- Bans user manually, adds to blacklist, kicks from lobby
------------------------------------------------------------------------
-- id:	peer ID
	local peer = managers.network._session:peer(id)
	if peer then
		NoobJoin:Message_Receive(peer:name() .. " " .. managers.localization:text("manually_added_to_blacklist"), "kick")
		NoobJoin:Add_Cheater(peer:user_id(), peer:name(), "Manual ban")
		NoobJoin:Kick_Selected_Peer(id)
	end
end
------------------------------| CHECK: new in R54
-- Performs some inspect?
------------------------------------------------------------------------
-- id:	peer ID
function NGBTO_player_inspect(id)
	local peer = managers.network._session:peer(id)
	if peer then
		local hours = ""
		local Ischeater = false
		local achievements = ""
		local vac = managers.localization:text("clean")
		local outfit = ""
		local skill = ""
		local perk_deck_completion = ""
		local p = ""
		dohttpreq("http://steamcommunity.com/profiles/".. peer:user_id() .. "/?l=english",
		function(page)
			local _, hours_start = string.find(page, '<div class="game_info_details">')
			if hours_start then
				local hours_ends = string.find(page, '<div class="game_name"><a', hours_start)
				if hours_ends then
					hours = (string.sub(page, hours_start, hours_ends))
					hours = string.gsub(hours, "	", "")
					hours = string.gsub(hours, "hrs on record<br>", "")
					hours = string.gsub(hours, "<", "")
					hours = string.gsub(hours, ">", "")
					hours = string.split(hours, "\n")
					hours = hours[2]
					hours = string.gsub(hours, ",", "")
					hours = (math.floor((hours + 1/2)/1) * 1)
					hours = tonumber(hours)
					if hours ~= nil then
						hours = (math.floor((hours + 1/2)/1) * 1)
					end
				end
			end
			local _, start = string.find(page, '<div class="profile_ban_status">')
			if start then
				vac = "banned"
			end
			local _, ach_start = string.find(page, '<h2>Recent Activity</h2>')
			if ach_start then
				local ach_ends = string.find(page, '<span>View mobile website</span>', ach_start)
				if ach_ends then
					local page1 = (string.sub(page, ach_start, ach_ends))
					if page1 then
						local _, ach1_start = string.find(page1, '<span class="ellipsis">')
						if ach1_start then
							local ach1_ends = string.find(page1, '<div class="achievement_progress_bar_ctn">', ach1_start)
							if ach1_ends then
								achievements = (string.sub(page1, ach1_start, ach1_ends))
								achievements = string.split(achievements, " of")
								local achievements2 = string.sub(achievements[2], 2, 4)
								achievements = achievements[1]
								achievements = string.gsub(achievements, ">", "")
								achievements = achievements .. " / " .. achievements2
							end
						end
					end
				end
			end
			dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. peer:user_id() .. "&force=1",
			function(page)
				local IsNoobJoinastring = false
				local reason = ""
				for param, val in string.gmatch(page, "([%w_]+)=([%w_]+)") do
					if string.len(val) > 17 then
						-- CHECK: reason is not used anywhere else, bug?
						reason = string.gsub(val, "_", " ")
						IsNoobJoinastring = string.find(reason, "Not enough heists completed") and true or false
						if NoobJoin.settings.tag_not_enough_heists_completed == true then
							IsNoobJoinastring = false
						end
						if IsNoobJoinastring == false then
							Ischeater = true
							break
						end
					end
				end
				if peer:skills() then
					if peer:skills() ~= nil then
						local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
						local skills = string.split(skills_perk_deck_info[1], "_")
						local perk_deck = string.split(skills_perk_deck_info[2], "_")
						p = managers.localization:text("menu_st_spec_" .. perk_deck[1])
						local sk = {}
						local number = 0
						local sum = 0
						for i=1,#skills do
							number = tonumber(skills[i])
							sum = sum + number
							if number < 10 then
								number = "0" .. tostring(skills[i])
							end
							table.insert(sk, number)
						end
						local message = ""
						if sum ~= 0 then
							-- CHECK: old format?
							skill = "M(" .. sk[1] .. ":" .. sk[2] .. ":" .. sk[3] .. ") E(" .. sk[4] .. ":" .. sk[5] .. ":" .. sk[6] .. ") T(" .. sk[7] .. ":" .. sk[8] .. ":" .. sk[9] .. ") G(" .. sk[10] .. ":" .. sk[11] .. ":" .. sk[12]  .. ") F(" .. sk[13] .. ":" .. sk[14] .. ":" .. sk[15] .. ")"
						end
						perk_deck_completion = " " .. perk_deck[2] .. "/" .. "9"
						outfit = string.split(peer:profile().outfit_string, " ") or {}
						outfit[7] = string.gsub(outfit[7], "wpn_fps_", "")
						outfit[9] = string.gsub(outfit[9], "wpn_fps_", "")
						outfit[15] = string.gsub(outfit[15], "wpn_prj_", "")
						for i=1,#outfit do
							outfit[i] = string.gsub(outfit[i], "_", " ")
						end
						if outfit[12] == "1" then
							outfit[12] = ""
						else
							outfit[12] = " x" .. outfit[12]
						end
						outfit = "\n" .. managers.localization:text("bm_menu_primaries") ..  ": " .. outfit[7] .. "\n" .. managers.localization:text("bm_menu_secondaries") .. ": " .. outfit[9] .. "\n" .. managers.localization:text("bm_menu_deployables") .. ": " .. outfit[11] .. outfit[12] .. "\n" .. managers.localization:text("bm_menu_grenades") .. ": " .. outfit[15]
					end
				end
				NoobJoin:NGBTO_player_data(id, hours, vac, achievements, Ischeater, skill, p, perk_deck_completion, outfit)
			end)
		end)
	end
end
------------------------------| CHECK: new in R54
-- Performs some inspect?
------------------------------------------------------------------------
-- data:	???
function NGBTO_player_http(data)
	local peer = managers.network._session:peer(data[2])
	if peer then
		if data[1] == "steam" then
			Steam:overlay_activate("url", "http://steamcommunity.com/profiles/" .. peer:user_id())
		elseif data[1] == "pd2stats" then
			Steam:overlay_activate("url", "http://pd2stats.com/profiles/" .. peer:user_id())
		elseif data[1] == "pd2statsanticheat" then
			Steam:overlay_activate("url", "http://api.pd2stats.com/cheater/v3/?type=saf&id=" .. peer:user_id() .. "&force=1")
		elseif data[1] == "steamrep" then
			Steam:overlay_activate("url", "http://steamrep.com/profiles/" .. peer:user_id())
		elseif data[1] == "steamdb" then
			Steam:overlay_activate("url", "https://steamdb.info/calculator/" .. peer:user_id())	
		end
		NoobJoin:NGBTO_player_inspection(data[2], data[3])
	end
end
------------------------------| CHECK: new in R54
-- Performs some inspect?
------------------------------------------------------------------------
-- id:		peer ID
-- hours:	???
-- vac:		vac string
-- achievements:	???
-- pd2cheat:	???
-- skill:	???
-- p:		???
-- perk_deck_completion:	???
-- outfit:	???
function NoobJoin:NGBTO_player_data(id, hours, vac, achievements, pd2cheat, skill, p, perk_deck_completion, outfit)
	local peer = managers.network._session:peer(id)
	if peer then
		if pd2cheat == true then
			pd2cheat = managers.localization:text("warning")
		else
			pd2cheat = managers.localization:text("clean")
		end
		local rank = ""
		if peer:rank() and peer:level() then
			rank = "\n" .. managers.localization:text("menu_infamytree") .. ": " .. peer:rank() .. "\n" .. managers.localization:text("Level") .. ": " .. peer:level()
		end
		local skills = ""
		if skill ~= "" and p ~= "" and perk_deck_completion ~= "" then
			skills = "\n" .. managers.localization:text("menu_st_skilltree") .. ": " .. skill .. "\n" .. managers.localization:text("menu_specialization") .. ": " .. p .. perk_deck_completion
		end
		if hours == "" then
			hours = "\n" .. managers.localization:text("Playtime") .. ": " .. managers.localization:text("hidden")
		else
			hours = "\n" .. managers.localization:text("Playtime") .. ": " .. tostring(hours) ..  " " .. managers.localization:text("hours_joined_2")
		end
		if achievements == "" then
			achievements = ""
		else
			achievements = "\n" .. managers.localization:text("Achievements") .. ": " .. achievements
		end
		local message = managers.localization:text("Player") .. ": " .. peer:name() .. rank .. hours .. skills .. achievements ..  " \n" .. managers.localization:text("VAC_status") .. ": " .. vac .. "\n" .. managers.localization:text("Pd2Stats_check") .. ": " .. pd2cheat .. outfit
		NoobJoin:NGBTO_player_inspection(id, message)
	end
end
------------------------------| CHECK: new in R54
-- Sends message?
------------------------------------------------------------------------
-- id:		peer ID
-- message:	???
function NoobJoin:NGBTO_player_inspection(id, message)
	local peer = managers.network._session:peer(id)
	if peer then
		local menu_options = {}
		menu_options[#menu_options+1] ={text = managers.localization:text("refresh"), data = id, callback = NGBTO_player_inspect}
		if peer:user_id() ~= Steam:userid() then
			if NoobJoin:Is_Friend(peer:user_id()) == false then
				menu_options[#menu_options+1] ={text = managers.localization:text("Manual_ban_button"), data = peer:id(), callback = Manual_Add_To_Blacklist}
			end
		end
		menu_options[#menu_options+1] ={text = "Steam profile", data = {"steam", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Pd2Stats", data = {"pd2stats", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Steamrep", data = {"steamrep", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Steamdb", data = {"steamdb", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = managers.localization:text("Back"), data = "", callback = NoobJoin.PlayerInspect}
		menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
		local menu = QuickMenu:new(NoobJoin.Name, message, menu_options)
		menu:Show()
	end
end
------------------------------| Copied from UNM-R41
function NoobJoin:inChat()
-- Checks whether focus is in chat
-- TODO: join the statements, get rid of local var
	local value = false
	if managers.hud and managers.hud._chat_focus == true then
		value = true
	end
	if managers.menu_component and managers.menu_component._game_chat_gui and managers.menu_component._game_chat_gui:input_focus() == true then
		value = true
	end
	return value
end
------------------------------| Copied from UNM-R41
function NoobJoin:Delayed_Message(message)
-- Posts message in chat if lobby host. CHECK why delayed.
------------------------------------------------------------------------
-- message:	text to send
	if Network:is_server() and NoobJoin.settings.broadcastinfo_val == true then
		for i=2,4 do
			local player = managers.network:session() and managers.network:session():peer(i)
			if player then
				player:send("send_chat_message", ChatManager.GAME, NoobJoin.Prefix .. ": " .. message)
			end
		end
	end
end
------------------------------| Copied from UNM-R41
function NoobJoin:Deployables_Lookup(peer_id)
-- Checks equipped deployables and kicks based on settings
------------------------------------------------------------------------
-- peer_id:	??? peer's ID in lobby? Like 2, 3 or 4?
	if Utils:IsInHeist() and NoobJoin.settings.Toggle == 1 then
		if managers.network:session():peer(peer_id) then
			-- shortcut variable
			local peer = managers.network:session():peer(peer_id)
			if peer:waiting_for_player_ready() == true then
				NoobJoin:Join_Message(peer_id)
				local split = string.split(peer:profile().outfit_string, " ") or {}
				local prefix = peer:name() .. " " .. managers.localization:text("perk_deck_kick_1") .. " "
				local deploy = nil
				local armor = nil
				local message = nil
				
				split[12] = tonumber(split[12]) -- convert to # of deployables
				-- 0 deployables
				if split[12] == 0 and NoobJoin.settings.noequipment == true then
					deploy = managers.localization:text("no_deployable_kick")
				-- 1 sentry gun
				elseif split[11] == "sentry_gun" and split[12] == 1 and NoobJoin.settings.singleturret == true then
					deploy = managers.localization:text("kick_only_count") .. " 1 " .. managers.localization:text("debug_sentry_gun")
				-- bodybags
				elseif split[11] == "bodybags_bag" and NoobJoin.settings.bodybags == true then
					deploy = managers.localization:text("debug_equipment_bodybags_bag")
				-- armorkit
				elseif split[11] == "armor_kit" and NoobJoin.settings.armorkit == true then
					deploy = managers.localization:text("debug_equipment_armor_kit")
				-- 1 ecm
				elseif split[11] == "ecm_jammer" and split[12] == 1 and NoobJoin.settings.singleecm == true then
					deploy = managers.localization:text("kick_only_count") .. " 1 " .. managers.localization:text("debug_equipment_ecm_jammer")
				-- 4 first aid kits
				elseif split[11] == "first_aid_kit" and split[12] == 4 and NoobJoin.settings.fourfaks == true then
					deploy = managers.localization:text("kick_only_count") .. " 4 " .. managers.localization:text("debug_equipment_first_aid_kit")
				end
				
				if split[5] then
					split[5] = string.sub(split[5], 1, 7)
					if split[5] == "level_1" and NoobJoin.settings.armor1 == true then
						armor = managers.localization:text("bm_armor_level_1")
					elseif split[5] == "level_2" and NoobJoin.settings.armor2 == true then
						armor = managers.localization:text("bm_armor_level_2")
					elseif split[5] == "level_3" and NoobJoin.settings.armor3 == true then
						armor = managers.localization:text("bm_armor_level_3")
					elseif split[5] == "level_4" and NoobJoin.settings.armor4 == true then
						armor = managers.localization:text("bm_armor_level_4")
					elseif split[5] == "level_5" and NoobJoin.settings.armor5 == true then
						armor = managers.localization:text("bm_armor_level_5")
					elseif split[5] == "level_6" and NoobJoin.settings.armor6 == true then
						armor = managers.localization:text("bm_armor_level_6")
					elseif split[5] == "level_7" and NoobJoin.settings.armor7 == true then
						armor = managers.localization:text("bm_armor_level_7")
					end
				end
				
				if deploy then -- we kick by deploy first
					message = deploy
					if armor then -- and we have armor kick in place
						message = message .. " and for using " .. armor
					end
				elseif armor then -- no deploy, armor kick
					message = armor
				end
				
				if message then
					message = prefix .. message
					NoobJoin:Message_Receive(message, "kick")
					NoobJoin:Kick_Selected_Peer(peer_id)
				end
			end
		end
	end
end
------------------------------| Copied from UNM-R41
function NoobJoin:Message_Receive(message, color)
-- Host receives message with given color, other peers receive simple message
------------------------------------------------------------------------
-- message:	text to send
-- color:	color ID/key in NoobJoin.Colors table
	managers.chat:_receive_message(1, NoobJoin.Prefix, message, Color(NoobJoin.Colors[color]))
	NoobJoin:Delayed_Message(message)
end
------------------------------| New in UNM-R41
function NoobJoin:is_from_whitelist(user_id)
-- Check ider_id versus whitelist table
------------------------------------------------------------------------
-- user_id:	steam64 user ID
	local is_wl = false
	for _,line in pairs(NoobJoin.whitelist) do
		if line == user_id then
			is_wl = true
			break
		end
	end
	return is_wl
end
------------------------------| Copied from UNM-R41
function NoobJoin:Lookup_Player_Is_Friend(peer_id, user_id)
-- Ckeck player hours
-- Skip checks if player is a friend and whitelist is enabled for friends
------------------------------------------------------------------------
-- peer_id:	???
-- user_id:	steam64 user ID
	local peer = managers.network:session():peer(peer_id)
	if NoobJoin:is_from_whitelist(user_id) == false then
		-- general user logic
		if NoobJoin:Is_Friend(user_id) == true then
			local message = peer:name() .. " " .. managers.localization:text("player_friendlist")
			NoobJoin:Message_Receive(message, "whitelist")
			-- check versus whitelisting of friends
			if NoobJoin.settings.friend_whitelist_val == true then
				-- skip checks
				local message = peer:name() .. " (temporary) " .. managers.localization:text("player_whitelist")
				NoobJoin:Message_Receive(message, "whitelist")
				NoobJoin:Wait_For_Skills_Lookup(peer_id, false, false)
			else
				NoobJoin:Return_Playtime(peer_id, user_id)
			end
		else
			NoobJoin:Return_Playtime(peer_id, user_id)
		end
	else
		-- whitelisted explicitly
		local message = peer:name() .. " " .. managers.localization:text("player_whitelist")
		NoobJoin:Message_Receive(message, "whitelist")
		NoobJoin:Wait_For_Skills_Lookup(peer_id, false, false)
	end
end

------------------------------| Copied from UNM-R41
function NoobJoin:Hours_Compare(current, peer_id, user_id)
-- Get hours from steam and compare with settings
-- TODO: cleanup
------------------------------------------------------------------------
-- current:	hours in profile
-- peer_id:	???
-- user_id:	steam64 user ID
	local hours = NoobJoin:Return_Minimum_Hours()
	local block = NoobJoin:Is_From_Blacklist(user_id)
	local peer = managers.network:session():peer(peer_id)
	local message = peer:name()
	local kick = false
	local iskicked = false
	local infamy = false
	local hiddenprofile = false

	if current == nil then
		hiddenprofile = true
	end
	
	if block == true then
		message = peer:name() .. " " .. managers.localization:text("player_blacklist")
		NoobJoin:Kick_Selected_Peer(peer_id)
		kick = true
		iskicked = true
	else
		message = peer:name() .. " " .. managers.localization:text("hours_joined_1") .. " " .. tostring(current) .. " " .. managers.localization:text("hours_joined_2")
		if hours ~= -1 then
			if current == nil then
				message = peer:name() .. " " .. managers.localization:text("player_is_hidden")
				if NoobJoin.settings.kickhidden_val == true then
					if NoobJoin.settings.Toggle == 1 then
						if NoobJoin.settings.hiddeninfamycheck == false then
							message = peer:name() .. " " .. managers.localization:text("player_was_hidden")
							NoobJoin:Kick_Selected_Peer(peer_id)
							kick = true
							iskicked = true
						else
							infamy = true
						end
					else
						kick = true
					end
				end
			elseif current < hours then
				if NoobJoin.settings.Toggle == 1 then
					message = peer:name() .. " " .. managers.localization:text("hours_kicked_1") .. " " .. current .. "/" .. hours .. " " .. managers.localization:text("hours_kicked_2") .. " "
					NoobJoin:Kick_Selected_Peer(peer_id)
					kick = true
					iskicked = true
				else
					--message = message .. " " .. managers.localization:text("hours_joined_1") .. " " .. current .. " " .. managers.localization:text("hours_joined_2") .. " "
					kick = true
				end
			--elseif current >= hours then
			--	message = message .. " " .. managers.localization:text("hours_joined_1") .. " " .. current .. " " .. managers.localization:text("hours_joined_2") .. " "
			end
		else
			if current == nil then
				message = peer:name() .. " " .. managers.localization:text("player_is_hidden")
			--else
			--	message = message .. " " .. managers.localization:text("hours_joined_1") .. " " .. current .. " " .. managers.localization:text("hours_joined_2") .. " "
			end
		end
	end
	
	if iskicked == false then
		if kick == true then
			-- not toggled kicking, just the message and lookup
			NoobJoin:Message_Receive(message, "kick")
			NoobJoin:Wait_For_Skills_Lookup(peer_id, block, infamy, hiddenprofile)
		else
			-- he's ok, info and lookup
			NoobJoin:Message_Receive(message, "info")
			if hours ~= -1 then
				-- CHECK: probably bad logic, using both DW counter and total counts
				if NoobJoin.settings.deathwish_count_enable == true and Global.game_settings.difficulty == "overkill_290" or NoobJoin.settings.total_count_enable == true then
					-- async inside + check for toggle
					-- also does not deal with hidden profiles, just bypasses it as if everything is ok
					NoobJoin:Heists_Completed(user_id, peer_id)
				end
				NoobJoin:Wait_For_Skills_Lookup(peer_id, block, infamy, hiddenprofile)
			else
				NoobJoin:Wait_For_Skills_Lookup(peer_id, block, false, false)
			end
		end
	else	-- was kicked already
		NoobJoin:Message_Receive(message, "kick")
	end
end
------------------------------| Copied from UNM-R41 with bugfix
function NoobJoin:Join_Message(peer_id)
-- Displays message for joined peers
------------------------------------------------------------------------
-- peer_id:	??? peer's ID in lobby? Like 2, 3 or 4?
	local hours = NoobJoin:Return_Minimum_Hours()
	local peer = managers.network:session():peer(peer_id)
	if NoobJoin.settings.broadcastinfo_val == true and NoobJoin.settings.Toggle == 1 then
		DelayedCalls:Add("send_message_to_" .. tostring(peer_id), 2, function()
			local prefix = NoobJoin.Prefix .. ": "
			local hidden = ""
			local message = ""
			local intro = prefix .. managers.localization:text("unm_join_description")
			if NoobJoin.settings.localised_message == true then
				if hours == 0 then
					message = prefix .. managers.localization:text("lobby_not_supported")
					if NoobJoin.settings.kickhidden_val == true then
						message = prefix .. managers.localization:text("hidden_kick_on")
					end
				elseif hours ~= -1 then
					if NoobJoin.settings.kickhidden_val == true then
						hidden = managers.localization:text("lobby_create_message_2") .. " "
					end
					message = prefix .. managers.localization:text("lobby_create_message_1") .. " " .. hidden .. managers.localization:text("lobby_create_message_3") .. " " .. hours .. " " .. managers.localization:text("lobby_create_message_4")
				else
					message = prefix .. managers.localization:text("lobby_not_supported")
				end
			else
				if hours == 0 then
					message = prefix .. "This lobby will print information about joining people and ban cheaters automatically."
					if NoobJoin.settings.kickhidden_val == true then
						message = prefix .. "Hidden profiles will be kicked."
					end
				elseif hours ~= -1 then
					if NoobJoin.settings.kickhidden_val == true then
						hidden = "hidden profiles and "
					end
					message = prefix .. "This lobby will auto kick " .. hidden .. "players with under " .. hours .. " hours total playtime from the game."
				else
					message = prefix .. "This lobby will print information about joining people and ban cheaters automatically."
				end
			end
			
			local peer2 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer2 then
				peer2:send("send_chat_message", ChatManager.GAME, intro)
				peer2:send("send_chat_message", ChatManager.GAME, message)
			end
		end)
	end
end
------------------------------| Merged with UNM-R41, new Skill_cheater function
function NoobJoin:Wait_For_Skills_Lookup(peer_id, block, infamy, hiddenprofile)
-- 
------------------------------------------------------------------------
-- peer_id:	??? peer's ID in lobby? Like 2, 3 or 4?
-- block:	is from blacklist (true/false)
-- infamy:	infamy check should be performed (true/false)
-- hiddenprofile:	passed to Skills_And_Perk_Deck()
	DelayedCalls:Add("DelayedInspect" .. tostring(peer_id), 1 , function()
		if managers.network:session() and managers.network:session():peers() then
			local peer = managers.network:session():peer(peer_id) or {}
			local is_present = false
			
			for id, _ in pairs(_G.LuaNetworking:GetPeers()) do
				if id == peer_id then
					is_present = true
					break
				end
			end
			
			if peer and is_present == true then
				if peer:skills() then
					if peer:skills() ~= nil then
						local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
						local skills = string.split(skills_perk_deck_info[1], "_")
						local perk_deck = string.split(skills_perk_deck_info[2], "_")
						local cheater = NoobJoin:Skill_cheater(skills, peer)
						if cheater == true and block == false then
							-- adding but not kicking?
							NoobJoin:Add_Cheater(peer:user_id(), peer:name(), "Using too many skill points")
							--message = peer:name() .. " " .. managers.localization:text("cheater_ban") .. " "
							--kick!
						end
						
						NoobJoin:Skills_And_Perk_Deck(cheater, perk_deck[1], perk_deck[2], skills, peer_id, infamy, true, hiddenprofile)
					else	-- call again until skills are present
						NoobJoin:Wait_For_Skills_Lookup(peer_id, block, infamy, hiddenprofile)
					end
				else	-- call again until skills are present (but why the second time?)
					NoobJoin:Wait_For_Skills_Lookup(peer_id, block, infamy, hiddenprofile)
				end
			end
		end
	end)
end
------------------------------| Changed in R54
function NoobJoin:Information_To_HUD(peer)
-- Actually NOT printing any information to hud. Composing message and adding 
-- to NoobJoin.Players table. Then it will go to HUD (CHECK where)
------------------------------------------------------------------------
-- peer:	??? not ID, but peer class?
	if peer then
		if peer:is_outfit_loaded() then
			local message = NoobJoin:Compose_Skill_String(peer)
			NoobJoin.Players[peer:id()][3] = message
		end
	end
end
------------------------------| Function for message
function NoobJoin:Compose_Skill_String(peer)
	--[[
	peer:skills() format: 0_0_28_1_24_1_0_7_6_0_3_0_28_0_1-13_9
	sometimes is absent (all nulls): 0_0_0_0_0_0_0_0_0_0_0_0_0_0_0-11_9
	--]]
	local message = nil -- in case there is no message below
	local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
	if #skills_perk_deck_info == 2 then
		local skills = string.split(skills_perk_deck_info[1], "_")
		local perk_deck = string.split(skills_perk_deck_info[2], "_")
		local p = managers.localization:text("menu_st_spec_" .. perk_deck[1])
		local sk = {}
		local number = 0
		local sum = 0
		message = peer:name() .. ": "
		local perk_suffix = p .. " " .. perk_deck[2] .. "/9"
		for i=1,#skills do
			number = tonumber(skills[i])
			sum = sum + number
			if number < 10 then
				number = "0" .. tostring(skills[i])
			end
			table.insert(sk, number)
		end
		if sum ~= 0 then
			message = message .. "|" .. sk[1] .. ":" .. sk[2] .. ":" .. sk[3] .. "-"
			message = message .. "" .. sk[4] .. ":" .. sk[5] .. ":" .. sk[6] .. "-"
			message = message .. "" .. sk[7] .. ":" .. sk[8] .. ":" .. sk[9] .. "-"
			message = message .. "" .. sk[10] .. ":" .. sk[11] .. ":" .. sk[12] .. "-"
			message = message .. "" .. sk[13] .. ":" .. sk[14] .. ":" .. sk[15] .. "| "
			message = message .. perk_suffix
		else
			-- couldn't get skills due to PD2 bug
			message = message .. perk_suffix -- .. " (no skills?)"
		end
	end
	return message
end

------------------------------| Changed in R54
-- TODO: s var is not used
-- CHECK: hiddenprofile - not used?
function NoobJoin:Skills_And_Perk_Deck(cheater, perkdeck, completion, s, peer_id, infamy, joined, hiddenprofile)
	local peer = managers.network:session():peer(peer_id)
	local message = NoobJoin:Compose_Skill_String(peer)
	if cheater == true then
		message = peer:name() .. " " .. managers.localization:text("cheater_ban") .. " "
	else
		if Network:is_server() and (NoobJoin:Is_Friend(peer:user_id()) == false or NoobJoin.settings.friend_whitelist_val == false) and _G.LuaNetworking:LocalPeerID() ~= peer:id() and NoobJoin.settings.Toggle == 1 then
			if Global.game_settings.difficulty == "overkill" or Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" then
				perkdeck = tonumber(perkdeck)
				if NoobJoin.settings.perkdeck_1_val == true and perkdeck == 1 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_2_val == true and perkdeck == 2 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_3_val == true and perkdeck == 3 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_4_val == true and perkdeck == 4 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_5_val == true and perkdeck == 5 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_6_val == true and perkdeck == 6 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_7_val == true and perkdeck == 7 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_8_val == true and perkdeck == 8 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_9_val == true and perkdeck == 9 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_10_val == true and perkdeck == 10 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_11_val == true and perkdeck == 11 then   
					kicked = true
				elseif NoobJoin.settings.perkdeck_12_val == true and perkdeck == 12 then  
					kicked = true 
				elseif NoobJoin.settings.perkdeck_13_val == true and perkdeck == 13 then 
					kicked = true
				elseif NoobJoin.settings.perkdeck_14_val == true and perkdeck == 14 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_15_val == true and perkdeck == 15 then
					kicked = true
				end
				
				local infamy_lvl = tonumber(peer:rank())
				local infamy_min = NoobJoin.settings.hiddeninfamy-1
				local infamy_max = NoobJoin.settings.hiddeninfamymax-1
					
				if kicked == true then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_1") .. " " .. p .. " " .. managers.localization:text("perk_deck_kick_2") .. " "
				elseif NoobJoin.settings.perkdeck0_val == true and tonumber(completion) == 0 then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_3") .. " "
					kicked = true
				elseif NoobJoin.settings.incompletedeck == true and tonumber(completion) ~= 9 then
					message = peer:name() .. " " .. managers.localization:text("incomplete_perk_deck_kick") .. " "
					kicked = true
				elseif infamy == true and infamy_lvl < infamy_min then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_4") .. ": " .. infamy_lvl .. "/" .. infamy_min
					kicked = true
				elseif infamy == true and infamy_lvl > infamy_max then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_5") .. ": " .. infamy_lvl .. "/" .. infamy_max
					kicked = true
				elseif infamy == true and NoobJoin.settings.hiddenxxv == true and tonumber(peer:rank()) == 25 and tonumber(peer:level()) == 100 then
					message = peer:name() .. " " .. managers.localization:text("infamyxxv_kick") .. " "
					kicked = true
				elseif infamy == true and NoobJoin.settings.hiddenv == true and tonumber(peer:rank()) == 5 and tonumber(peer:level()) == 100 then
					message = peer:name() .. " " .. managers.localization:text("infamyv_kick") .. " "
					kicked = true
				end
			end
		end
	end
	
	if cheater == true or kicked == true then
		NoobJoin:Kick_Selected_Peer(peer:id())
		if NoobJoin.Players[peer_id][1] ~= true then
			NoobJoin:Message_Receive(message, 1)
			NoobJoin.Players[peer_id][1] = true
		end
	else
		if NoobJoin.settings.show_perks_info_val == true then
			if (Network:is_server() and joined == true) or (Network:is_client() and Utils:IsInGameState()) then
				if NoobJoin.Players[peer_id][1] ~= true then	-- no idea what that is...
					NoobJoin:Message_Receive(message, "info")
					NoobJoin.Players[peer_id][1] = true
				end
				
				if Network:is_server() then
					if NoobJoin:is_from_whitelist(peer:user_id()) == false then
						if NoobJoin:Is_Friend(peer:user_id()) == true then
							if NoobJoin.settings.friend_whitelist_val == false then
								NoobJoin:PD2Stats_API_Check(peer:user_id(), peer_id, false)
							end
						else
							NoobJoin:PD2Stats_API_Check(peer:user_id(), peer_id, false)
						end
					end
				end
			end
		end
	end
end

function NoobJoin:Is_From_Blacklist(user_id)
	local isblocked = false
	for _,line in pairs(NoobJoin.blacklist) do
		if line == user_id then
			isblocked = true
			break
		end
	end
	return isblocked
end

function NoobJoin:Add_Cheater(user_id, username, reason)
	if NoobJoin:Is_From_Blacklist(user_id) == false and (NoobJoin:Is_Friend(user_id) == false or NoobJoin.friend_whitelist_val == false) then
		table.insert(NoobJoin.blacklist, user_id)
		local time = os.date("*t")
		local timestamp = {time.year, time.month, time.day, time.hour, time.min, time.sec}
		for i=1,#timestamp do
			if timestamp[i] < 10 then
				timestamp[i] =  "0" .. tostring(timestamp[i])
			end
		end
		timestamp = timestamp[1] .. "-" .. timestamp[2] .. "-" .. timestamp[3] .. " " .. timestamp[4] .. ":" .. timestamp[5] .. ":" .. timestamp[6]
		file = io.open(NoobJoin.blacklist_file, "a")
		file:write("\n" .. user_id .. "\n" .. ";" .. username .. " reason: " .. reason .. ". Date: " .. timestamp)
		file:close()
	end
end

function NoobJoin:Return_Playtime(peer_id, user_id)
	local hours = nil
	dohttpreq("http://steamcommunity.com/profiles/".. user_id .. "/?l=english",
	function(page)
		local _, hours_start = string.find(page, '<div class="game_info_details">')
		if hours_start then
			local hours_ends = string.find(page, '<div class="game_name"><a', hours_start)
			if hours_ends then
				hours = (string.sub(page, hours_start, hours_ends))
				hours = string.gsub(hours, "	", "")
				hours = string.gsub(hours, "hrs on record<br>", "")
				hours = string.gsub(hours, "<", "")
				hours = string.gsub(hours, ">", "")
				hours = string.split(hours, "\n")
				hours = hours[2]
				hours = string.gsub(hours, ",", "")
				hours = (math.floor((hours + 1/2)/1) * 1)
				hours = tonumber(hours)
				if hours ~= nil then
					hours = (math.floor((hours + 1/2)/1) * 1)
				end
			end
		end
		NoobJoin:Hours_Compare(hours, peer_id, user_id)
	end)
end

function NoobJoin:Heists_Completed(user_id, peer_id)
	if NoobJoin.settings.Toggle == 1 then
		local sum = 0
		local number = {} -- Normal, Hard, Very hard, Overkill, Deathwish
		dohttpreq("http://pd2stats.com/profiles/".. user_id .. "/?l=en",
		function(page)
			local _, start = string.find(page, '<table class="maxtable">')
			if start then
				local ends = string.find(page, "Accounting for ", start)
				if ends then
					current = (string.sub(page, start, ends))
					for i in string.gmatch(current, "%S+") do
						if string.sub(i, 1, 13) == 'class="diff">' then
							i = string.gsub(i, 'class="diff">', "")
							sum = sum + tonumber(i)
							table.insert(number, tonumber(i))
						end
					end
				end
			else
				sum = nil
			end
			if sum ~= nil then
				local peer = managers.network:session():peer(peer_id)
				local message = peer:name() .. " "
				if NoobJoin.settings.deathwish_count_enable == true and ((NoobJoin.settings.deathwish_count*20)-20) > number[5] then
					message = message ..  managers.localization:text("deathwish_count_kick") .. " " .. tostring(number[5]) .. "/" .. tostring(((NoobJoin.settings.deathwish_count*20)-20)) .. " "
					NoobJoin:Kick_Selected_Peer(peer_id)
					NoobJoin:Message_Receive(message, 1)
				elseif NoobJoin.settings.total_count_enable == true and ((NoobJoin.settings.total_count*20)-20) > sum then
					message = message ..  managers.localization:text("total_count_kick") .. " " .. tostring(sum) .. "/" .. tostring(((NoobJoin.settings.total_count*20)-20)) .. " "
					NoobJoin:Kick_Selected_Peer(peer_id)
					NoobJoin:Message_Receive(message, 1)
				end
			end
		end)
	end
end

function NoobJoin:PD2Stats_API_Check(user_id, peer_id, joined)
	if Global.game_settings.single_player == false then
		if NoobJoin.settings.usepd2statsanticheat == true then
			dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. user_id .. "&force=1",
			function(page)
				local peer = managers.network:session():peer(peer_id)
				local Ischeater = false
				local IsNoobJoinastring = false
				local reason = ""
				if NoobJoin.settings.usepd2statsanticheat == true then
					local message = peer:name() .. ": "
					for param, val in string.gmatch(page, "([%w_]+)=([%w_]+)") do
						if string.len(val) > 17 then
							reason = string.gsub(val, "_", " ")
							IsNoobJoinastring = string.find(reason, "Not enough heists completed") and true or false
							if NoobJoin.settings.tag_not_enough_heists_completed == true then
								IsNoobJoinastring = false
							end
							if IsNoobJoinastring == false then
								message = message .. reason
								Ischeater = true
								break
							end
						end
					end
					if Ischeater == true then
						NoobJoin:Add_Cheater(user_id, peer:name(), reason)
						NoobJoin:Kick_Selected_Peer(peer_id)
						if NoobJoin.Players[peer_id][2] ~= true then
							NoobJoin:Message_Receive(message, 1)
							NoobJoin.Players[peer_id][2] = true
						end
					end
				end
			end)
		end
		if Network:is_client() and joined == true then
			NoobJoin:Wait_For_Skills_Lookup(peer_id, false, false)
		end
	end
end
------------------------------| Copied from UNM-R41
function NoobJoin:Return_Minimum_Hours()
	local hours = -1
	if Global.game_settings.difficulty == "overkill_290" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			hours = NoobJoin.settings.min_hours_loud_dw_val
		else
			hours = NoobJoin.settings.min_hours_stealth_dw_val
		end
	elseif Global.game_settings.difficulty == "overkill_145" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			hours = NoobJoin.settings.min_hours_loud_ovk_val
		else
			hours = NoobJoin.settings.min_hours_stealth_ovk_val
		end
	elseif Global.game_settings.difficulty == "overkill" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			hours = NoobJoin.settings.min_hours_loud_vh_val
		else
			hours = NoobJoin.settings.min_hours_stealth_vh_val
		end
	end
	return hours
end

function NoobJoin:Kick_Selected_Peer(id)
	if Network:is_server() then
		local session = managers.network._session
		local peer = session:peer(id)
		if peer then
			session:on_peer_kicked(peer, id, 0)
			session:send_to_peers("kick_peer", id, 2)
		end
	end
end

function NoobJoin:Lookup_Skills_and_Perk_Deck(joined)
	if Global.game_settings.single_player == false then
		DelayedCalls:Add("DelayedInspectI", 5 , function()
			if managers.network:session() and managers.network:session():peers() then
				for _, peer in pairs(managers.network:session():peers()) do
					if peer:skills() then
						if peer:skills() ~= nil then
							NoobJoin:Just_The_Lookup(joined, peer)
						end
					end
				end
				peer = managers.network:session():peer(_G.LuaNetworking:LocalPeerID())
				NoobJoin:Just_The_Lookup(joined, peer)
			end
		end)
	end
end

function NoobJoin:Just_The_Lookup(joined, peer)
	if peer ~= nil and peer:skills() then
		local cheater = false
		local number = 0
		local sum = 0
		local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
		if #skills_perk_deck_info == 2 then
			local skills = string.split(skills_perk_deck_info[1], "_")
			cheater = NoobJoin:Skill_cheater(skills, peer)
			local perk_deck = string.split(skills_perk_deck_info[2], "_")
			if cheater == true and block == false then
				NoobJoin:Add_Cheater(peer:user_id(), peer:name(), "too many skill points")
			end
			NoobJoin:Skills_And_Perk_Deck(cheater, perk_deck[1], perk_deck[2], skills, peer:id(), infamy, joined, false)
		end
	end
end

function NoobJoin:Debug_Message(message, color, message2)
	local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
	if not NoobJoin.overlay then
		NoobJoin.overlay = Overlay:newgui():create_screen_workspace() or {}
		NoobJoin.fonttype = tweak_data.menu.pd2_small_font
		NoobJoin.fontsize = tweak_data.menu.pd2_small_font_size
		if RenderSettings.resolution.x >= 600 and RenderSettings.resolution.x < 800 then
			NoobJoin.fontsize = 8
		elseif RenderSettings.resolution.x >= 800 and RenderSettings.resolution.x < 1024 then
			NoobJoin.fontsize = 12
		elseif RenderSettings.resolution.x >= 1024 and RenderSettings.resolution.x < 1280 then 
			NoobJoin.fontsize = 16
		else
			NoobJoin.fontsize = 22
		end
		NoobJoin.stats = {}
		NoobJoin.mod = NoobJoin.overlay:panel():text{name = "mod", x = - (RenderSettings.resolution.x/2.1) + 0.5 * RenderSettings.resolution.x, y = - (RenderSettings.resolution.y/4) + 4.7/9 * RenderSettings.resolution.y, text = NoobJoin.Name, font = NoobJoin.fonttype, font_size = NoobJoin.fontsize, color = Color(NoobJoin.Colors[2]), layer = 1}
		local pos = 5
		for i=1, num_player_slots do
			NoobJoin.stats[i] = NoobJoin.overlay:panel():text{name = "name" .. i, x = - (RenderSettings.resolution.x/2.1) + 0.5 * RenderSettings.resolution.x, y = - (RenderSettings.resolution.y/4) + pos/9 * RenderSettings.resolution.y, text = "", font = NoobJoin.fonttype, font_size = NoobJoin.fontsize, color = tweak_data.chat_colors[i], layer = 1}
			pos = pos + 0.3
		end
	end
	NoobJoin.mod:show()
	if not message then
		for i=1,num_player_slots do
			if NoobJoin.Players[i][3] ~= 0 then
				NoobJoin.stats[i]:set_text((NoobJoin.Players[i][3]))
				NoobJoin.stats[i]:show()
			end
		end
	else
		NoobJoin.stats[1]:set_text(message)
		NoobJoin.stats[1]:show()
		if message2 then
			NoobJoin.stats[2]:set_text(message2)
			NoobJoin.stats[2]:show()
		end
	end
	
	DelayedCalls:Add("NoobJoin:Timed_Remove", 5, function()
		if NoobJoin.overlay then
			NoobJoin.mod:hide()
			for i=1,num_player_slots do
				NoobJoin.stats[i]:hide()
			end
		end
	end)
end

function NoobJoin:Skill_cheater(skills, peer)
	local cheater = false
	local number = 0
	local sum = 0
	for i=1,#skills do
		number = tonumber(skills[i])
		if number > 117 then
			cheater = true
		end
		sum = sum + number
	end
	if sum > 120 then
		cheater = true
	end
	if peer and peer:level() ~= nil then
		if sum > (tonumber(peer:level()) + 2 * math.floor(tonumber(peer:level()) / 10)) then
			cheater = true
		end
	end
	return cheater
end