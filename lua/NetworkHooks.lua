if RequiredScript == "lib/network/base/networkpeer" then
	Hooks:PostHook(HostNetworkSession, "init", "NoobJoin:Stuff", function(self, ...)
		for k, v in ipairs(NoobJoin.blacklist or {}) do
			self._kicked_list[v] = true
		end
	end)
	Hooks:Add("NetworkManagerOnPeerAdded", "NoobJoin:PeerAdded", function(peer, peer_id)
		if Network:is_server() then
			NoobJoin:Lookup_Player_Is_Friend(peer_id, peer:user_id())
			if not Utils:IsInGameState() then
				NoobJoin:Join_Message(peer_id)
			end
			-- new in R55
			if Utils:IsInHeist() then
				NoobJoin.Players[peer_id][4] = managers.game_play_central and managers.game_play_central:get_heist_timer()
			end
		else
			-- new in R55
			NoobJoin:Player_Announce(peer, true)
		end
	end)

	Hooks:Add("NetworkGameOnGameJoined", "NoobJoin:GameJoined", function(local_peer, id)
		if Network:is_client() then
			DelayedCalls:Add("game_joined_check" , 2, function()
				if managers.network:session() and managers.network:session():peers() then
					for _, peer in pairs(managers.network:session():peers()) do
						NoobJoin:Player_Announce(peer, false)
					end
					NoobJoin:Lookup_Skills_and_Perk_Deck(true)
				end
			end)
		end
	end)

	Hooks:Add("BaseNetworkSessionOnLoadComplete", "NoobJoin:LoadComplete", function(peer, id)
		if Network:is_server() then
			DelayedCalls:Add("load_complete_check" , 2, function()
				if managers.network:session() and managers.network:session():peers() then
					for _, peer in pairs(managers.network:session():peers()) do
						NoobJoin:Player_Announce(peer, false)
					end
					NoobJoin:Lookup_Skills_and_Perk_Deck(true)
				end
			end)
		end
	end)

	Hooks:PostHook(LobbyOptionInitiator, "modify_node", "NoobJoin:LobbyEnter", function(ply)
		if Network:is_client() then
			DelayedCalls:Add("modify_node_check" , 2, function()
				if managers.network:session() and managers.network:session():peers() then
					for _, peer in pairs(managers.network:session():peers()) do
						NoobJoin:Player_Announce(peer, false)
					end
					NoobJoin:Lookup_Skills_and_Perk_Deck(true)
				end
			end)
		end
	end)

	Hooks:PostHook(MenuSceneManager, "set_lobby_character_out_fit", "NoobJoin:OutfitChange", function(ply)
		if Network:is_client() then
			NoobJoin:Lookup_Skills_and_Perk_Deck(true)
		else
			NoobJoin:Lookup_Skills_and_Perk_Deck(false)
		end
	end)

	Hooks:Add("BaseNetworkSessionOnPeerRemoved", "NoobJoin:PeerRemoved", function(peer, peer_id, reason)
		NoobJoin.Players[peer_id][1] = false
		NoobJoin.Players[peer_id][2] = false
		NoobJoin.Players[peer_id][3] = 0
		NoobJoin.Players[peer_id][4] = 0
	end)

	Hooks:PostHook(NetworkPeer, "mark_cheater", "NoobJoin:CheaterCaught", function(self, reason, auto_kick)
		if NoobJoin.settings.ingame_anticheat == true then
			local message = self:name() ..  ": " .. managers.localization:text("pd_anticheat_self")
			NoobJoin:Message_Receive(message, 1)
			NoobJoin:Add_Cheater(self:user_id(), self:name(), message)
		end
	end)
end

if RequiredScript == "lib/network/matchmaking/networkmatchmakingsteam" then
	local _is_server_ok_original = NetworkMatchMakingSTEAM.is_server_ok
	function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, ...)
		for _,line in pairs(NoobJoin.blacklist) do
			if line == room then
				return false
			end
		end
		return _is_server_ok_original(self, friends_only, room, ...)
	end
end

if RequiredScript == "lib/network/base/basenetworksession" then
	Printed = false
	Current_time = 0
	Hooks:PostHook(BaseNetworkSession, "on_set_member_ready", "NoobJoin:Deployables", function(self, peer_id, ready, state_changed, from_network)
		if Network:is_server() then
			if Global.game_settings.difficulty == "overkill" or Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" then
				if NoobJoin:Is_Friend(managers.network:session():peer(peer_id):user_id()) == false or NoobJoin.settings.friend_whitelist_val == false then
					NoobJoin:Deployables_Lookup(peer_id)
				end
			end
		end
	end)

	Hooks:PostHook(BaseNetworkSession, "on_statistics_recieved", "NoobJoin:Stats", function(self, peer_id, peer_kills, peer_specials_kills, peer_head_shots, accuracy, downs)
		if Printed == false then
			Printed = true
			Current_time = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0
			DelayedCalls:Add("NoobJoin:Statistics_message", 0.5, function()
				if NoobJoin.settings.Stats_Print == true then
					local message = managers.localization:text("Newbie_Statistics") .. ":" .. " " .. managers.localization:text("Newbie_Kills") .. " | " .. managers.localization:text("Newbie_Kill_Per_Minute") .. " | " .. managers.localization:text("Newbie_Spec_Kills") .. " | " .. managers.localization:text("Newbie_Headshots") .. " | " .. managers.localization:text("Newbie_Accuracy") .. " | " .. managers.localization:text("Newbie_Downs")
					NoobJoin:Message_Receive(message, 2)
				end
			end)
		end
		DelayedCalls:Add("NoobJoin:Statistics_message_peer_" .. tostring(peer_id) , 0.7, function()
			if NoobJoin.settings.Stats_Print == true then
				local peer = managers.network:session():peer(peer_id)
				local kpm = peer_kills
				if Current_time > 60 and peer_kills > 0 then
					kpm =(math.floor(((peer_kills / ((Current_time/60)-(NoobJoin.Players[peer_id][4]/60))) + 1/2)/1) * 1)
				end
				if peer:has_statistics() then
					local message = peer:name() .. " | K:" .. peer_kills .. " | KPM:" .. kpm .. " | S/K:" .. peer_specials_kills .. " | H:" .. peer_head_shots .. " | A:" .. accuracy .. " % | D:" .. downs
					NoobJoin:Message_Receive(message, 2)
				end
			end
		end)
	end)
end