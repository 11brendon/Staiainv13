-- refactored a bit but still needs work -mina
local collapsed = false
local rtTable
local rates
local rateIndex = 1
local scoreIndex = 1
local score
local pn = GAMESTATE:GetEnabledPlayers()[1]
local nestedTab = 1
local nestedTabs = {"Local", "Online"}

local frameX = 141.5
local frameY = -6
local frameWidth = SCREEN_WIDTH * 0.2
local frameHeight = 350
local fontScale = 0.4
local offsetX = 10
local offsetY = 30
local netScoresPerPage = 8
local netScoresCurrentPage = 1
local nestedTabButtonWidth = 153
local nestedTabButtonHeight = 20
local netPageButtonWidth = 50
local netPageButtonHeight = 50
local headeroffY = 26/1.5

local selectedrateonly

local judges = {
	"TapNoteScore_W1",
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
	"TapNoteScore_Miss",
	"HoldNoteScore_Held",
	"HoldNoteScore_LetGo"
}

local defaultRateText = ""
if themeConfig:get_data().global.RateSort then
	defaultRateText = "1.0x"
else
	defaultRateText = "All"
end

local function isOver(element)
	if element:GetParent():GetParent():GetVisible() == false then
		return false 
		end
	if element:GetParent():GetVisible() == false then
		return false 
	end
	if element:GetVisible() == false then
		return false 
	end
	local x = getTrueX(element)
	local y = getTrueY(element)
	local hAlign = element:GetHAlign()
	local vAlign = element:GetVAlign()
	local w = element:GetZoomedWidth()
	local h = element:GetZoomedHeight()

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	local withinX = (mouseX >= (x-(hAlign*w))) and (mouseX <= ((x+w)-(hAlign*w)))
	local withinY = (mouseY >= (y-(vAlign*h))) and (mouseY <= ((y+h)-(vAlign*h)))

	return (withinX and withinY)
end

-- should maybe make some of these generic
local function highlight(self)
	self:queuecommand("Highlight")
end

-- note: will use the local isover functionality
local function highlightIfOver(self)
	if isOver(self) then
		self:diffusealpha(0.6)
	else
		self:diffusealpha(1)
	end
end
local moped
-- Only works if ... it should work
-- You know, if we can see the place where the scores should be.
local function updateLeaderBoardForCurrentChart()
	local top = SCREENMAN:GetTopScreen()
	if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
		if top:GetMusicWheel():IsSettled() and ((getTabIndex() == 2 and nestedTab == 2) or collapsed) then
			local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
			if steps then
				local leaderboardAttempt = DLMAN:GetChartLeaderboard(steps:GetChartKey())
				if #leaderboardAttempt > 0 then
					moped:playcommand("SetFromLeaderboard", leaderboardAttempt)
				else
					DLMAN:RequestChartLeaderBoardFromOnline(
						steps:GetChartKey(),
						function(leaderboard)
							moped:queuecommand("SetFromLeaderboard", leaderboard)
						end
					)
				end
			else
				moped:playcommand("SetFromLeaderboard", {})
			end
		end
	end
end

local ret =
	Def.ActorFrame{
	BeginCommand=function(self)
		moped = self:GetChild("ScoreDisplay")
		self:queuecommand("Set"):visible(false)
		self:GetChild("LocalScores"):visible(false)
		self:GetChild("ScoreDisplay"):xy(frameX,frameY):visible(false)
		
		if FILTERMAN:oopsimlazylol() then	-- set saved position and auto collapse
			nestedTab = 2
			self:GetChild("LocalScores"):visible(false)
			self:GetChild("ScoreDisplay"):xy(FILTERMAN:grabposx("Doot"),FILTERMAN:grabposy("Doot")):visible(true)
			self:playcommand("Collapse")
		end
	end,
	OffCommand=function(self)
		self:bouncebegin(0.2):xy(-500,0):diffusealpha(0) -- visible(false)
	end,
	OnCommand=function(self)
		self:bouncebegin(0.2):xy(0,0):diffusealpha(1)
		if nestedTab == 1 then
			self:GetChild("LocalScores"):visible(true)
		end
	end,
	SetCommand=function(self)
		self:finishtweening(1)
		if getTabIndex() == 2 then						-- switching to this tab
			if collapsed then							-- expand if collaped
				self:queuecommand("Expand")
			else
				self:queuecommand("On")
				self:visible(true)
			end
		elseif collapsed and getTabIndex() == 0 then	-- display on general tab if collapsed
			self:queuecommand("On")
			self:visible(true)							-- not sure about whether this works or is needed
		elseif collapsed and getTabIndex() ~= 0 then	-- but not others
			self:queuecommand("Off")
		elseif not collapsed then						-- if not collapsed, never display outside of this tab
			self:queuecommand("Off")
		end
	end,
	TabChangedMessageCommand=function(self)
		self:queuecommand("Set")
		updateLeaderBoardForCurrentChart()
	end,
	NestedTabChangedMessageCommand = function(self)
		self:queuecommand("Set")
		updateLeaderBoardForCurrentChart()
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:queuecommand("Set")
		updateLeaderBoardForCurrentChart()
	end,
	UpdateChartMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	CollapseCommand=function(self)
		collapsed = true
		resetTabIndex()
		MESSAGEMAN:Broadcast("TabChanged")
	end,
	ExpandCommand=function(self)
		collapsed = false
		if getTabIndex() ~= 2 then
			setTabIndex(2)
		end
		self:GetChild("ScoreDisplay"):xy(frameX,frameY)
		MESSAGEMAN:Broadcast("TabChanged")
	end,
	DelayedChartUpdateMessageCommand = function(self)
		local leaderboardEnabled =
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).leaderboardEnabled and DLMAN:IsLoggedIn()
		if GAMESTATE:GetCurrentSteps(PLAYER_1) then
			local chartkey = GAMESTATE:GetCurrentSteps(PLAYER_1):GetChartKey()
			if leaderboardEnabled then
			DLMAN:RequestChartLeaderBoardFromOnline(
				chartkey,
				function(leaderboard)
					moped:playcommand("SetFromLeaderboard", leaderboard)
				end
			)	-- this is also intentionally super bad so we actually do something about it -mina
			elseif (SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic" or SCREENMAN:GetTopScreen():GetName() == "ScreenNetSelectMusic") and ((getTabIndex() == 2 and nestedTab == 2) or collapsed) then
				DLMAN:RequestChartLeaderBoardFromOnline(
				chartkey,
				function(leaderboard)
					moped:playcommand("SetFromLeaderboard", leaderboard)
				end
			)
			end
		end
	end,
	CodeMessageCommand = function(self, params) -- this is intentionally bad to remind me to fix other things that are bad -mina
		if ((getTabIndex() == 2 and nestedTab == 2) and not collapsed) and DLMAN:GetCurrentRateFilter() then
			local rate = getCurRateValue()
			if params.Name == "PrevScore" and rate < 2.95 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate + 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate + 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate + 0.1)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			elseif params.Name == "NextScore" and rate > 0.75 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate - 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate - 0.1)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate - 0.1)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			end
			if params.Name == "PrevRate" and rate < 3 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate + 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate + 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate + 0.05)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			elseif params.Name == "NextRate" and rate > 0.7 then
				GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred"):MusicRate(rate - 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Song"):MusicRate(rate - 0.05)
				GAMESTATE:GetSongOptionsObject("ModsLevel_Current"):MusicRate(rate - 0.05)
				MESSAGEMAN:Broadcast("CurrentRateChanged")
			end
		end
	end,
	CurrentRateChangedMessageCommand = function(self)
		if ((getTabIndex() == 2 and nestedTab == 2) or collapsed) and DLMAN:GetCurrentRateFilter() then
			moped:queuecommand("GetFilteredLeaderboard")
		end
	end
}


local cheese
-- eats only inputs that would scroll to a new score
local function input(event)
	if cheese:GetVisible() and isOver(cheese:GetChild("FrameDisplay")) then
		if event.DeviceInput.button == "DeviceButton_mousewheel up" and event.type == "InputEventType_FirstPress" then
			moving = true
			if nestedTab == 1 and rtTable and rtTable[rates[rateIndex]] ~= nil then
				cheese:queuecommand("PrevScore")
				return true
			end
		elseif event.DeviceInput.button == "DeviceButton_mousewheel down" and event.type == "InputEventType_FirstPress" then
			if nestedTab == 1 and rtTable ~= nil and rtTable[rates[rateIndex]] ~= nil then
				cheese:queuecommand("NextScore")
				return true
			end
		elseif moving == true then
			moving = false
		end
	end
	return false
end

local t =
	Def.ActorFrame {
	Name="LocalScores",
	InitCommand=function(self)
		rtTable = nil
		self:xy(frameX+offsetX,frameY+offsetY + headeroffY)
		self:SetUpdateFunction(highlight)
		cheese = self
	end,
	BeginCommand=function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
	end,
	SetCommand=function(self)
		if nestedTab == 1 and self:GetVisible() then
			if GAMESTATE:GetCurrentSong() ~= nil then
				rtTable = getRateTable()
				if rtTable ~= nil then
					rates,rateIndex = getUsedRates(rtTable)
					scoreIndex = 1
					self:queuecommand("Display")
				else
					self:queuecommand("Init")
				end
			else
				self:queuecommand("Init")
			end
		end
	end,
	NestedTabChangedMessageCommand=function(self)
		self:visible(nestedTab == 1)
		self:queuecommand("Set")
	end,
	CodeMessageCommand=function(self,params)
		if nestedTab == 1 and rtTable ~= nil and rtTable[rates[rateIndex]] ~= nil then
			if params.Name == "NextRate" then
				self:queuecommand("NextRate")
			elseif params.Name == "PrevRate" then
				self:queuecommand("PrevRate")
			elseif params.Name == "NextScore" then
				self:queuecommand("NextScore")
			elseif params.Name == "PrevScore" then
				self:queuecommand("PrevScore")
			end
		end
	end,
	NextRateCommand=function(self)
		rateIndex = ((rateIndex)%(#rates))+1
		scoreIndex = 1
		self:queuecommand("Display")
	end,
	PrevRateCommand=function(self)
		rateIndex = ((rateIndex-2)%(#rates))+1
		scoreIndex = 1
		self:queuecommand("Display")
	end,
	NextScoreCommand=function(self)
		scoreIndex = ((scoreIndex)%(#rtTable[rates[rateIndex]]))+1
		self:queuecommand("Display")
	end,
	PrevScoreCommand=function(self)
		scoreIndex = ((scoreIndex-2)%(#rtTable[rates[rateIndex]]))+1
		self:queuecommand("Display")
	end,
	DisplayCommand=function(self)
		score = rtTable[rates[rateIndex]][scoreIndex]
		setScoreForPlot(score)
	end,
	--jaioWFIOJaEGHIOHUIOgeahouegawOHGUAWHaWHAGW) H
	Def.Quad {
		Name = "FrameDisplay",
		InitCommand = function(self)
			self:xy(-135,59):zoomto(frameWidth,frameHeight+8):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
		CollapseCommand=function(self)
			self:visible(false)
		end,
		ExpandCommand=function(self)
			self:visible(true)
		end,
	}
}

t[#t+1] = 
	LoadFont("Common Large")..
	{
	Name="Grades",
	InitCommand=function(self)
		self:xy(-130,95):zoom(0.6):halign(0):maxwidth(50/0.6):settext("")
	end,
	DisplayCommand=function(self)
		self:settext(THEME:GetString("Grade",ToEnumShortString(score:GetWifeGrade())))
		self:diffuse(getGradeColor(score:GetWifeGrade()))
	end,
}

t[#t+1] = LoadActor("5.png") .. { InitCommand=function(self) self:xy(-162,-28):halign(0):valign(0):diffusealpha(1) end }

-- Wife display
t[#t+1] = LoadFont("Common Normal")..{
	Name="Wife",
	InitCommand=function(self)
		self:xy(-130,320):zoom(0.6):halign(0):settext("")
	end,
	DisplayCommand=function(self)
		if score:GetWifeScore() == 0 then 
			self:settextf("NA")
		else
			self:settextf("%05.2f%%", notShit.floor(score:GetWifeScore()*10000)/100):diffuse(byGrade(score:GetWifeGrade()))
		end
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="Score",
	InitCommand=function(self)
		self:xy(-10,320):zoom(0.6):halign(1):settext("")
	end,
	DisplayCommand=function(self)
		if score:GetWifeScore() == 0 then 
			self:settext("")
		else
			local overall = score:GetSkillsetSSR("Overall")
			self:settextf("%.2f", overall):diffuse(byMSD(overall))
		end
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="ClearType",
	InitCommand=function(self)
		self:xy(-130,115):zoom(0.5):halign(0):halign(0):settext("No Play"):diffuse(color(colorConfig:get_data().clearType["NoPlay"]))
	end,
	DisplayCommand=function(self)
		self:settext(getClearTypeFromScore(pn,score,0))
		self:diffuse(getClearTypeFromScore(pn,score,2))
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="Combo",
	InitCommand=function(self)
		self:y(58):zoom(0):halign(0):settext("Max Combo:")
	end,
	DisplayCommand=function(self)
		self:settextf("Max Combo: %d",score:GetMaxCombo())
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="MissCount",
	InitCommand=function(self)
		self:y(73):zoom(0):halign(0):settext("Miss Count:")
	end,
	DisplayCommand=function(self)
		local missCount = getScoreMissCount(score)
		if missCount ~= nil then
			self:settext("Miss Count: "..missCount)
		else
			self:settext("Miss Count: -")
		end
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="Date",
	InitCommand=function(self)
		self:xy(-70,285):zoom(0.4):halign(0.5)
	end,
	DisplayCommand=function(self)
		self:settext(""..getScoreDate(score))
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="Mods",
	InitCommand=function(self)
		self:xy(-70,300):zoom(0.4):halign(0.5):maxwidth(300)
	end,
	DisplayCommand=function(self)
		self:settext("" ..score:GetModifiers())
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="StepsAndMeter",
	InitCommand=function(self)
		self:xy(-70,68):zoom(0.5):halign(0.5):queuecommand("Display"):maxwidth(235)
	end,
	DisplayCommand=function(self)
		if GAMESTATE:GetCurrentSong() then
			local steps = GAMESTATE:GetCurrentSteps(pn)
			local diff = getDifficulty(steps:GetDifficulty())
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
			local meter = steps:GetMeter()
			self:settext(stype.." "..diff.." "..meter)
			self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
		end
	end,
}
--etiohsadetg80  8tged9y8gd0 agyd890y8dg90 y d80uy 
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(-70,408):zoom(0.4):halign(0.5):settext("No Scores Saved")
	end,
	DisplayCommand=function(self)
		self:settextf("Rate %s - Showing %d/%d",rates[rateIndex],scoreIndex,#rtTable[rates[rateIndex]])
	end,
}

t[#t+1] = Def.Quad{
	Name="ScrollBar",
	InitCommand=function(self)
		self:x(-7):zoom(0):halign(1):valign(1):diffuse(getMainColor('highlight')):diffusealpha(0.75)
	end,
	ScoreUpdateMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	DisplayCommand=function(self)
		self:finishtweening()
		self:smooth(0.2)
		self:zoomy(((frameHeight+7.5)/#rtTable[rates[rateIndex]]))
		self:y((((frameHeight)/#rtTable[rates[rateIndex]])*scoreIndex) - headeroffY - offsetY+114)
	end
}
--rates
local function makeText(index)
	return LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(-11,offsetY+46+(index*15)):zoom(fontScale+0.05):halign(1):settext("")
		end,
		DisplayCommand=function(self)
			local count = 0
			if rtTable[rates[index]] ~= nil then
				count = #rtTable[rates[index]]
			end
			if index <= #rates then
				self:settextf("%s (%d)",rates[index],count)
				if index == rateIndex then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(getMainColor('positive'))
				end
			else
				self:settext("")
			end
		end,
		HighlightCommand=function(self)
			highlightIfOver(self)
		end,
		MouseLeftClickMessageCommand=function(self)
			if nestedTab == 1 and isOver(self) then
				rateIndex = index
				scoreIndex = 1
				self:GetParent():queuecommand("Display")
			end
		end
	}
end
--controls amount of rates displayed
for i=1,3 do
	t[#t+1] =makeText(i)
end

local function makeJudge(index,judge)
	local t = Def.ActorFrame{InitCommand=function(self)
		self:y(125+((index-1)*18))
	end}

	--labels
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(-130,20):zoom(0.5):halign(0)
		end,
		BeginCommand=function(self)
			self:settext(getJudgeStrings(judge))
			self:diffuse(byJudgment(judge))
		end
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(-12,20):zoom(0.5):halign(1):settext("0")
		end,
		DisplayCommand=function(self)
			if judge ~= 'HoldNoteScore_Held' and judge ~= 'HoldNoteScore_LetGo' then
				self:settext(getScoreTapNoteScore(score,judge))
			else
				self:settext(getScoreHoldNoteScore(score,judge))
			end
		end,
	};

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:x(122):zoom(0):halign(0):settext("")
		end,
		DisplayCommand=function(self)
			if judge ~= 'HoldNoteScore_Held' and judge ~= 'HoldNoteScore_LetGo' then
				local taps = math.max(1,getMaxNotes(pn))
				local count = getScoreTapNoteScore(score,judge)
				self:settextf("(%03.2f%%)",(count/taps)*100)
			else
				local holds = math.max(1,getMaxHolds(pn))
				local count = getScoreHoldNoteScore(score,judge)
				self:settextf("(%03.2f%%)",(count/holds)*100)
			end
		end,
	};

	return t
end

for i=1,#judges do
	t[#t+1] =makeJudge(i,judges[i])
end

t[#t+1] = LoadFont("Common Normal")..{
	Name="Score",
	InitCommand=function(self)
		self:xy(-70,375):zoom(0.5):halign(0.5):settext("")
	end,
	DisplayCommand=function(self)
		if score:HasReplayData() then 
			self:settext("Show Replay Data")
		else
			self:settext("No Replay Data")
		end
	end,
	HighlightCommand=function(self)
		highlightIfOver(self)
	end,
	MouseLeftClickMessageCommand=function(self)
		if nestedTab == 1 then
			if getTabIndex() == 2 and getScoreForPlot() and getScoreForPlot():HasReplayData() and isOver(self) then
				SCREENMAN:AddNewScreenToTop("ScreenScoreTabOffsetPlot")
			end
		end
	end
}

t[#t + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "ReplayViewer",
		InitCommand = function(self)
			self:xy(-70,360):zoom(0.5):halign(0.5):settext(
				""
			)
		end,
		DisplayCommand = function(self)
			if score:HasReplayData() then
				self:settext("View Replay")
			else
				self:settext("No Replay Data")
			end
		end,
		HighlightCommand = function(self)
			highlightIfOver(self)
		end,
		MouseLeftClickMessageCommand = function(self)
			if nestedTab == 1 then
				if getTabIndex() == 2 and getScoreForPlot() and getScoreForPlot():HasReplayData() and isOver(self) then
					SCREENMAN:GetTopScreen():PlayReplay(score)
				end
			end
		end
	}
t[#t + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "EvalViewer",
		InitCommand = function(self)
			self:xy(-70,344):zoom(0.5):halign(0.5):settext("")
		end,
		DisplayCommand = function(self)
			if score:HasReplayData() then
				self:settext("View Eval Screen")
			else
				self:settext("")
			end
		end,
		HighlightCommand = function(self)
			highlightIfOver(self)
		end,
		MouseLeftClickMessageCommand = function(self)
			if nestedTab == 1 then
				if getTabIndex() == 2 and getScoreForPlot() and getScoreForPlot():HasReplayData() and isOver(self) then
					SCREENMAN:GetTopScreen():ShowEvalScreenForScore(score)
				end
			end
		end
	}

t[#t + 1] =
	LoadFont("Common Normal") ..
	{
		Name = "TheDootButton",
		InitCommand = function(self)
			self:xy(-70,391):zoom(0.5):halign(0.5):settext("")
		end,
		DisplayCommand = function(self)
			if score:HasReplayData() then
				self:settext("Upload Replay Data")
			else
				self:settext("")
			end
		end,
		HighlightCommand = function(self)
			highlightIfOver(self)
		end,
		MouseLeftClickMessageCommand = function(self)
			if nestedTab == 1 then
				if getTabIndex() == 2 and isOver(self) then
					DLMAN:SendReplayDataForOldScore(score:GetScoreKey())
					ms.ok("Uploading Replay Data...")	--should have better feedback -mina
				end
			end
		end
	}





ret[#ret+1] = t

function nestedTabButton(i) 
  return  
  Def.ActorFrame{
    InitCommand=function(self) 
      self:xy(frameX-120 + offsetX + (i-1)*(50), frameY+70 + headeroffY)
	  self:SetUpdateFunction(highlight)
    end, 
	CollapseCommand=function(self)
		self:visible(false)
	end,
	ExpandCommand=function(self)
		self:visible(true)
	end,
    LoadFont("Common normal") .. { 
      InitCommand=function(self) 
        self:diffuse(getMainColor('positive')):maxwidth(nestedTabButtonWidth):maxheight(40):zoom(0.75):settext(nestedTabs[i]):halign(0)
      end, 
	  HighlightCommand=function(self)
		if isOver(self) and nestedTab ~= i then
			self:diffusealpha(0.75)
		elseif nestedTab == i then
			self:diffusealpha(1)
		else
			self:diffusealpha(0.6)
		end
	  end,
      MouseLeftClickMessageCommand=function(self) 
        if isOver(self) then 
          nestedTab = i 
          MESSAGEMAN:Broadcast("NestedTabChanged") 
		  if nestedTab == 1 then
			self:GetParent():GetParent():GetChild("ScoreDisplay"):visible(false)
		  else
			self:GetParent():GetParent():GetChild("ScoreDisplay"):visible(true)
		  end
        end 
      end, 
      NestedTabChangedMessageCommand=function(self) 
        self:queuecommand("Set") 
      end
    }
  }
end

-- online score display
ret[#ret+1] = LoadActor("../superscoreboard")
for i=1,#nestedTabs do  
  ret[#ret+1] = nestedTabButton(i) 
end 


return ret
