--Local vars
local update = false
local steps
local song
local frameX = 10
local frameY = 45
local frameWidth = capWideScale(320,400)
local frameHeight = 350
local fontScale = 0.4
local distY = 15
local offsetX = 10
local offsetY = 20
local pn = GAMESTATE:GetEnabledPlayers()[1]
local greatest = 0
local steps
local meter = {}
meter[1] = 0.00

--Actor Frame
local t = Def.ActorFrame{
	BeginCommand=function(self)
		self:queuecommand("Set"):visible(false)
	end,
	OffCommand=function(self)
		self:bouncebegin(0.2):xy(-500,0):diffusealpha(0)
	end,
	OnCommand=function(self)
		self:bouncebegin(0.2):xy(0,0):diffusealpha(1)
	end,
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:queuecommand("On")
			self:visible(true)
			song = GAMESTATE:GetCurrentSong()
			steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			
			--Find max MSD value, store MSD values in meter[]
			-- I plan to have c++ store the highest msd value as a separate variable to aid in the filter process so this won't be needed afterwards - mina
			greatest=0
			if song and steps then
				for i=1,#ms.SkillSets do 
					meter[i+1] = steps:GetMSD(getCurRateValue(), i)
					if meter[i+1] > meter[greatest+1] then
						greatest = i
					end
				end
			end
			
			MESSAGEMAN:Broadcast("UpdateMSDInfo")
			update = true
		else 
			self:queuecommand("Off")
			update = false
		end
	end,
	CurrentRateChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	RefreshChartInfoMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	TabChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end,
}

t[#t+1] = LoadActor("1.png") .. { InitCommand=function(self) self:xy(0,85):halign(0):valign(0):diffusealpha(1) end }

--Skillset label function
local function littlebits(i)
	local t = Def.ActorFrame{
		LoadFont("Common Large") .. {
		InitCommand=function(self)
			self:xy(frameX+0,frameY+120 + 22*i):halign(0):valign(0):zoom(0.5):maxwidth(110/0.6)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			--skillset name
			if song and steps then
				self:settext(ms.SkillSets[i]..":")
			else
				self:settext("")
			end
			--highlight
			if greatest == i then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(color("#FFFFFF"))
			end
			--If negative BPM empty label
			if steps and steps:GetTimingData():HasWarps() then
				self:settext("");
			end
		end,
		UpdateMSDInfoCommand=function(self)
			self:queuecommand("Set")
		end,
		},
		LoadFont("Common Large") .. {
		InitCommand=function(self)
			self:xy(frameX+135,frameY+120 + 22*i):halign(1):valign(0):zoom(0.5):maxwidth(110/0.6)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			if song and steps then
				self:settextf("%05.2f",meter[i+1])
				self:diffuse(byMSD(meter[i+1]))
			else
				self:settext("")
			end
			--If negative BPM empty label
			if steps and steps:GetTimingData():HasWarps() then
				self:settext("");
			end
		end,
		CurrentRateChangedMessageCommand=function(self)
			self:queuecommand("Set")
		end,
		UpdateMSDInfoCommand=function(self)
			self:queuecommand("Set")
		end,
		}
	}
	return t
end

--Song Title
t[#t+1] = LoadFont("Common Normal")..{InitCommand=function(self)
	self:xy(frameX+69,frameY+offsetY+44):zoom(0.6):halign(0.5):diffuse(getMainColor('positive')):settext("MSD Breakdown")
end}
t[#t+1] = LoadFont("Common Large")..{
	InitCommand=function(self)
		self:xy(frameX+69,frameY+123):zoom(0.6):halign(0.5):diffuse(getMainColor('positive')):maxwidth(230)
	end,
	SetCommand=function(self)
		if song then
			self:settext(song:GetDisplayMainTitle())
		else
			self:settext("")
		end
	end,
	UpdateMSDInfoCommand=function(self)
		self:queuecommand("Set")
	end,
}


-- Music Rate Display
t[#t+1] = LoadFont("Common Large") .. {
	InitCommand=function(self)
		self:xy(frameX+frameWidth-287,frameY+offsetY+87):visible(true):halign(0.5):zoom(0.4):maxwidth(capWideScale(get43size(360),360)/capWideScale(get43size(0.45),0.45))
	end,
	SetCommand=function(self)
		self:settext(getCurRateDisplayString())
	end,
	CurrentRateChangedCommand=function(self)
		self:queuecommand("set")
	end	
}

--Difficulty
t[#t+1] = LoadFont("Common Normal")..{
	Name="StepsAndMeter",
	InitCommand=function(self)
		self:xy(79,137):zoom(0.5):halign(0.5):maxwidth(282)
	end,
	SetCommand=function(self)
		steps = GAMESTATE:GetCurrentSteps(pn)
		if steps ~= nil then
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			if update then
				self:settext(stype.." "..diff.." "..meter)
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
			end
		end
	end,
	ScoreUpdateMessageCommand=function(self)
		self:queuecommand("Set")
	end	
}


--NPS
t[#t+1] = LoadFont("Common Normal")..{
	Name="NPS";
	InitCommand=function(self)
		self:xy(frameX+frameWidth-215,frameY+offsetY+87):zoom(0.4):halign(0.5):maxwidth(160)
	end;
	SetCommand=function(self)
		steps = GAMESTATE:GetCurrentSteps(pn)
		--local song = GAMESTATE:GetCurrentSong()
		local notecount = 0
		local length = 1
		if steps ~= nil and song ~= nil and update then
			length = song:GetStepsSeconds()
			notecount = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			self:settext(string.format("%0.2f Average NPS",notecount/length * getCurRateValue()))
			self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())),0.3))
		else
			self:settext("0.00 Average NPS")
		end
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
	CurrentStepsP1ChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
	CurrentStepsP2ChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
};

--Negative BPMs label
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(frameX+45,frameY+135):zoom(0.8):halign(0):diffuse(getMainColor('negative')):settext("Negative Bpms")
	end,
	SetCommand=function(self)
		if steps and steps:GetTimingData():HasWarps() then
			self:settext("Negative Bpms");
		else
			self:settext("");
		end
	end,
	UpdateMSDInfoCommand=function(self)
		self:queuecommand("Set")
	end,
}

--Skillset labels
for i=1,#ms.SkillSets do 
	t[#t+1] = littlebits(i)
end


return t
