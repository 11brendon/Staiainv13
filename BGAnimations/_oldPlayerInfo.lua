-- Old avatar actor frame.. renamed since much more will be placed here (hopefully?)
local t =
	Def.ActorFrame {
	Name = "PlayerAvatar"
}

local profile

local profileName = "No Profile"
local playCount = 0
local playTime = 0
local noteCount = 0
local numfaves = 0
local AvatarX = 0
local AvatarY = SCREEN_HEIGHT - 50
local playerRating = 0

local setnewdisplayname = function(answer)
	profile:RenameProfile(answer)
	profileName = answer
	MESSAGEMAN:Broadcast("ProfileRenamed", {doot = answer})
end

t[#t + 1] =
	Def.Actor {
	BeginCommand = function(self)
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		profile = GetPlayerOrMachineProfile(PLAYER_1)
		profileName = profile:GetDisplayName()
		playCount = profile:GetTotalNumSongsPlayed()
		playTime = profile:GetTotalSessionSeconds()
		noteCount = profile:GetTotalTapsAndHolds()
		playerRating = profile:GetPlayerRating()
	end
}

t[#t + 1] =
	Def.ActorFrame {
	Name = "Avatar" .. PLAYER_1,
	BeginCommand = function(self)
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		if profile == nil then
			self:visible(false)
		else
			self:visible(true)
		end
	end,
	Def.Sprite {
		Name = "Image",
		InitCommand = function(self)
			self:visible(false):halign(0):valign(0):xy(AvatarX, AvatarY)
		end,
		BeginCommand = function(self)
			self:queuecommand("ModifyAvatar")
		end,
		ModifyAvatarCommand = function(self)
			self:finishtweening()
			self:Load(getAvatarPath(PLAYER_1))
			self:zoomto(50, 50)
		end
	},
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:xy(AvatarX+53,AvatarY+7):maxwidth(400):halign(0):zoom(0.6):diffuse(getMainColor('positive'))
		end,
		MouseLeftClickMessageCommand=function(self)
			if isOver(self) and not SCREENMAN:get_input_redirected(PLAYER_1) then
				easyInputStringWithFunction("Choose new profile display name:", 64, false, setnewdisplayname)
			end
		end,
		ProfileRenamedMessageCommand=function(self, params)
			self:settextf("%s: %5.2f",params.doot,playerRating)
		end,
	},
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X,AvatarY+20):halign(0.5):zoom(2.5):diffuse(getMainColor('positive'))
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			if DLMAN:IsLoggedIn() then
				self:queuecommand("Login")
			else
				self:queuecommand("LogOut")
			end
		end,
	},
	Def.Quad{
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X,AvatarY+20):halign(0.5):zoomto(100,30):diffusealpha(0)
		end,
		LoginFailedMessageCommand=function(self)
			ms.ok("Login failed!")
		end,
		LoginMessageCommand=function(self)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).UserName = DLMAN:GetUsername()
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PasswordToken = DLMAN:GetToken()
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
			playerConfig:save(pn_to_profile_slot(PLAYER_1))
			ms.ok("Succesfully logged in")
		end,
		MouseLeftClickMessageCommand=function(self)
			if isOver(self) and not SCREENMAN:get_input_redirected(PLAYER_1) then 
				if not DLMAN:IsLoggedIn() then
					username = function(answer) 
							user=answer
						end
					password = function(answer) 
							pass=answer
							DLMAN:Login(user, pass) 
						end
					easyInputStringWithFunction("Password:", 50, true, password)
					easyInputStringWithFunction("Username:",50, false, username)
				else
					playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).UserName = ""
					playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).PasswordToken = ""
					playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
					playerConfig:save(pn_to_profile_slot(PLAYER_1))
					DLMAN:Logout()
				end
			end
		end
	},
	--LoadFont("Common Normal") .. {
		--InitCommand=function(self)
			--self:xy(AvatarX+53,AvatarY+20):halign(0):zoom(0.35):diffuse(getMainColor('positive'))
		--end,
		--BeginCommand=function(self)
	--		self:queuecommand("Set")
	--	end,
	--	SetCommand=function(self)
	--		self:settext(playCount.." Plays")
	--	end,
	--},
	--LoadFont("Common Normal") .. {
--		InitCommand=function(self)
--			self:xy(AvatarX+53,AvatarY+30):halign(0):zoom(0.35):diffuse(getMainColor('positive'))
--		end,
--		BeginCommand=function(self)
--			self:queuecommand("Set")
--		end,
--		SetCommand=function(self)
--			self:settext(noteCount.." DEAD COPS")
--		end,
--	},
--	LoadFont("Common Normal") .. {
--		InitCommand=function(self)
--			self:xy(AvatarX+53,AvatarY+40):halign(0):zoom(0.35):diffuse(getMainColor('positive'))
--		end,
--		BeginCommand=function(self)
--			self:queuecommand("Set")
--		end,
--		SetCommand=function(self)
--			local time = SecondsToHHMMSS(playTime)
--			self:settextf(time.." PlayTime")
--		end,
--	},
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:xy(SCREEN_CENTER_X-125,AvatarY+41):halign(0.5):zoom(0.45):diffuse(getMainColor('positive'))
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			self:settext("Judge: "..GetTimingDifficulty())
		end,
	},
}

local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end;
	if getAvatarUpdateStatus(PLAYER_1) then
    	self:GetChild("Avatar"..PLAYER_1):GetChild("Image"):queuecommand("ModifyAvatar")
    	setAvatarUpdateStatus(PLAYER_1,false)
    end;
end
t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end	

return t
