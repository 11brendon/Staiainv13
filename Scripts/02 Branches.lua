--[[
Lines with a single string (e.g. TitleMenu = "ScreenTitleMenu") are referenced
in the metrics as Branch.keyname.
If the line is a function, you'll have to use Branch.keyname() instead.
--]]

Branch = {
	Init = function() return Branch.TitleMenu() end,
	AfterInit = function()
		return Branch.TitleMenu()
	end,
	TitleMenu = function()
		return "ScreenTitleMenu"
	end,
	AfterTitleMenu = function()
		return Branch.StartGame()
	end,
	StartGame = function()
		multiplayer = false
		if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 and #DLMAN:GetDownloads() == 0 then
			return "ScreenCoreBundleSelect"
		end
		if PROFILEMAN:GetNumLocalProfiles() >= 2 then
			return "ScreenSelectProfile"
		else
			return "ScreenProfileLoad"
		end
	end,
	OptionsEdit = function()
		-- Similar to above, don't let anyone in here with 0 songs.
		if SONGMAN:GetNumSongs() == 0 and SONGMAN:GetNumAdditionalSongs() == 0 then
			return "ScreenCoreBundleSelect"
		end
		return "ScreenOptionsEdit"
	end,
	AfterSelectProfile = function()
		return "ScreenSelectMusic"
	end,
	AfterProfileLoad = function()
		return "ScreenSelectMusic"
	end,
	AfterSelectMusic = function()
		if SCREENMAN:GetTopScreen():GetGoToOptions() then
			return SelectFirstOptionsScreen()
		else
			return "ScreenStageInformation"
		end
	end,
	MultiScreen = function()
		if IsNetSMOnline() then
			if not IsSMOnlineLoggedIn(PLAYER_1) then
				return "ScreenNetSelectProfile"
			else
				return "ScreenNetRoom"
			end
		else
			return "ScreenNetworkOptions"
		end
	end
}
