local t = Def.ActorFrame{}
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_PlayerInfo")
t[#t+1] = LoadActor("currenttime")

if GAMESTATE:GetNumPlayersEnabled() == 1 and themeConfig:get_data().eval.ScoreBoardEnabled then
	t[#t+1] = LoadActor("scoreboard")
end

--Group folder name
local frameWidth = 175
local frameHeight = 10
local frameX = 1
local frameY = 1

	t[#t+1] = LoadFont("Common Large") .. {
		InitCommand=function(self)
			self:xy(177,30):zoom(0.8):halign(0.5):valign(0):maxwidth(200)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			local diff = getDifficulty(steps:GetDifficulty())
			self:settext(getShortDifficulty(diff))
			self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
		end
	};
	
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X,6):zoom(0.55):maxwidth(capWideScale(250/0.4,180/0.4))
	end,
	BeginCommand=function(self)
		self:queuecommand("Set")
	end,
	SetCommand=function(self) 
		self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
	end
}

-- Rate String
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X-0.5,113):zoom(0.7):halign(0.5)
	end,
	BeginCommand=function(self)
		if getCurRateString() == "1x" then
			self:settext("1x Rate")
		else
			self:settext(getCurRateString().." Rate")
		end
	end
}

t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=function(self)
		self:xy(frameX,frameY+5):halign(0):zoom(0.55):maxwidth((frameWidth-40)/0.35)
	end,
	BeginCommand=function(self)
		self:queuecommand("Set"):diffuse(getMainColor('positive'))
	end,
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		if song ~= nil then
			self:settext(song:GetGroupName())
		end
	end
}

t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,0):halign(0):valign(0):diffusealpha(1) end }
t[#t+1] = LoadActor("../_cursor");

return t