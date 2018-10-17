local t = Def.ActorFrame{}

local enabledCustomWindows = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomEvaluationWindowTimings

local customWindows = timingWindowConfig:get_data().customWindows

local scoreType = themeConfig:get_data().global.DefaultScoreType



t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:xy(SCREEN_CENTER_X,capWideScale(145,160)):zoom(0):maxwidth(180/0.4)
	end,
	BeginCommand=function(self)
		self:queuecommand("Set")
	end,
	SetCommand=function(self) 
		if GAMESTATE:IsCourseMode() then
			self:settext(GAMESTATE:GetCurrentCourse():GetScripter())
		else
			self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
		end
	end
}

local function GraphDisplay( pn )
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

	local t = Def.ActorFrame {
		Def.GraphDisplay {
			InitCommand=function(self)
				self:Load("GraphDisplay")
			end,
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set( ss, ss:GetPlayerStageStats(pn) )
				self:diffusealpha(0.7)
				self:GetChild("Line"):diffusealpha(1)
				self:zoomto(317,58)
				self:xy(209,352)
			end
		}
	}
	return t
end

local function ComboGraph( pn )
	local t = Def.ActorFrame {
		Def.ComboGraph {
			InitCommand=function(self)
				self:Load("ComboGraph"..ToEnumShortString(pn))
			end,
			BeginCommand=function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set( ss, ss:GetPlayerStageStats(pn) )
				self:zoom(0)
				self:xy(155,3)
			end
		}
	}
	return t
end

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}

local pssP1 = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)

local frameX = 50
local frameY = 140
local frameWidth = SCREEN_CENTER_X-120

function scoreBoard(pn,position)
	
	local customWindow
	local judge = enabledCustomWindows and 0 or GetTimingDifficulty()
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local score = SCOREMAN:GetMostRecentScore()
	local dvt = pss:GetOffsetVector()
	local totalTaps = pss:GetTotalTaps()
	
	local t = Def.ActorFrame{
		BeginCommand=function(self)
			if position == 1 then
				self:x(SCREEN_WIDTH-(frameX*2)-frameWidth)
			end
		end,
		UpdateNetEvalStatsMessageCommand = function(self)
			local s = SCREENMAN:GetTopScreen():GetHighScore()
			if s then
				score = s
			end
			dvt = score:GetOffsetVector()
			MESSAGEMAN:Broadcast("ScoreChanged")
		end,
	}
		t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:xy(161,125):zoomto(318,17):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	};
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:xy(160,140):zoomto(frameWidth+119,80):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	};
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:xy(160,225):zoomto(frameWidth+119,175):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	};
	t[#t+1] = LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(281,381):zoom(0.7):halign(0):valign(0):maxwidth(200)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self)
			local meter = GAMESTATE:GetCurrentSteps(PLAYER_1):GetMSD(getCurRateValue(), 1)
			self:settextf("MSD: %5.2f", meter)
			self:diffuse(byMSD(meter))
		end,
	};
	t[#t+1] = LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(450,381):zoom(0.7):halign(1):valign(0):maxwidth(200)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		ScoreChangedMessageCommand = function(self) self:queuecommand("Set"); end,
		SetCommand=function(self)
			local meter = score:GetSkillsetSSR("Overall")
			self:settextf("SSR: %5.2f", meter)
			self:diffuse(byMSD(meter))
		end,
	};
	-- Wife percent
	t[#t+1] = LoadFont("THENUMBERSMASON")..{
		InitCommand=function(self)
			self:xy(368,170):zoom(1):halign(0.5):valign(0):maxwidth(capWideScale(320,360))
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self) 
			self:settextf("%05.2f%%",notShit.floor(score:GetWifeScore()*10000)/100)
		end,
		ScoreChangedMessageCommand = function(self) self:queuecommand("Set"); end,
		CodeMessageCommand=function(self,params)
			local totalHolds = pss:GetRadarPossible():GetValue("RadarCategory_Holds") + pss:GetRadarPossible():GetValue("RadarCategory_Rolls")
			local holdsHit = score:GetRadarValues():GetValue("RadarCategory_Holds") + score:GetRadarValues():GetValue("RadarCategory_Rolls")
			local minesHit = pss:GetRadarPossible():GetValue("RadarCategory_Mines") -  score:GetRadarValues():GetValue("RadarCategory_Mines")
			if enabledCustomWindows then
				if params.Name == "PrevJudge" then
					judge = judge < 2 and #customWindows or judge - 1
					customWindow = timingWindowConfig:get_data()[customWindows[judge]]
					self:settextf("%05.2f%% (%s)", getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps), customWindow.name)
				elseif params.Name == "NextJudge" then
					judge = judge == #customWindows and 1 or judge + 1
					customWindow = timingWindowConfig:get_data()[customWindows[judge]]
					self:settextf("%05.2f%% (%s)", getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps), customWindow.name)
				end
			elseif params.Name == "PrevJudge" and judge > 1 then
				judge = judge - 1
				self:settextf("%05.2f%% (%s)", getRescoredWifeJudge(dvt, judge, totalHolds - holdsHit, minesHit, totalTaps), "J"..judge)
			elseif params.Name == "NextJudge" and judge < 9 then
				judge = judge + 1
				if judge == 9 then
					self:settextf("%05.2f%% (%s)", getRescoredWifeJudge(dvt, judge, (totalHolds - holdsHit), minesHit, totalTaps), "J9")
				else
					self:settextf("%05.2f%% (%s)", getRescoredWifeJudge(dvt, judge, (totalHolds - holdsHit), minesHit, totalTaps), "J"..judge)
				end
			end
			if params.Name == "ResetJudge" then
				judge = enabledCustomWindows and 0 or GetTimingDifficulty()
				self:playcommand("Set")
			end
		end,
	};
	
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(320,131):zoom(0.40):halign(0.5):maxwidth(frameWidth/0.26)
		end,
		BeginCommand=function(self)
			self:queuecommand("Set")
		end,
		SetCommand=function(self) 
			self:settext(GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString('ModsLevel_Current'))
		end
	}

	for k,v in ipairs(judges) do
		t[#t+1] = Def.Quad{
			InitCommand=function(self)
				self:xy(frameX,frameY+80+((k-1)*22)):zoomto(frameWidth,18):halign(0):diffuse(byJudgment(v)):diffusealpha(0)
			end;
		};
		t[#t+1] = Def.Quad{
			InitCommand=function(self)
				self:xy(frameX,frameY+80+((k-1)*22)):zoomto(0,18):halign(0):diffuse(byJudgment(v)):diffusealpha(0)
			end,
			BeginCommand=function(self)
				self:glowshift():effectcolor1(color("1,1,1,"..tostring(pss:GetPercentageOfTaps(v)*0.4))):effectcolor2(color("1,1,1,0")):sleep(0.5):decelerate(2):zoomx(frameWidth*pss:GetPercentageOfTaps(v))
			end,
			CodeMessageCommand=function(self,params)
				if params.Name == "PrevJudge" or params.Name == "NextJudge" then
					if enabledCustomWindows then
						self:finishtweening():decelerate(2):zoomx(frameWidth*getRescoredCustomJudge(dvt, customWindow.judgeWindows, k)/totalTaps)
					else
						local rescoreJudges = getRescoredJudge(dvt, judge, k)
						self:finishtweening():decelerate(2):zoomx(frameWidth*rescoreJudges/totalTaps)
					end
				end
				if params.Name == "ResetJudge" then
					self:finishtweening():decelerate(2):zoomx(frameWidth*pss:GetPercentageOfTaps(v))
				end
			end,
		};
		t[#t+1] = LoadFont("Common Formal")..{
			InitCommand=function(self)
				self:xy(283,236+((k-1)*25.5)):zoom(0.5):halign(0)
			end,
			BeginCommand=function(self)
				self:queuecommand("Set")
			end,
			SetCommand=function(self) 
				self:settext(getJudgeStrings(v))
			end,
			CodeMessageCommand=function(self,params)
				if enabledCustomWindows and (params.Name == "PrevJudge" or params.Name == "NextJudge") then
					self:settext(getCustomJudgeString(customWindow.judgeNames, k))
				end
				if params.Name == "ResetJudge" then
					self:playcommand("Set")
				end
			end,
		};
		t[#t+1] = LoadFont("THENUMBERSMASON")..{
			InitCommand=function(self)
				self:xy(314+frameWidth-40,frameY+97+((k-1)*25.5)):zoom(0.75):halign(1)
			end,
			BeginCommand=function(self)
				self:queuecommand("Set")
			end,
			SetCommand=function(self) 
				self:settext(score:GetTapNoteScore(v))
			end,
			ScoreChangedMessageCommand = function(self) self:queuecommand("Set"); end,
			CodeMessageCommand=function(self,params)
				if params.Name == "PrevJudge" or params.Name == "NextJudge" then
					if enabledCustomWindows then
						self:settext(getRescoredCustomJudge(dvt, customWindow.judgeWindows, k))
					else
						self:settext(getRescoredJudge(dvt, judge, k))
					end
				end
				if params.Name == "ResetJudge" then
					self:playcommand("Set")
				end
			end,
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:xy(frameX+frameWidth-38,frameY+80+((k-1)*22)):zoom(0):halign(0)
			end,
			BeginCommand=function(self)
				self:queuecommand("Set")
			end,
			SetCommand=function(self) 
				self:settextf("(%03.2f%%)",pss:GetPercentageOfTaps(v)*100)
			end,
			CodeMessageCommand=function(self,params)
				if params.Name == "PrevJudge" or params.Name == "NextJudge" then
					local rescoredJudge
					if enabledCustomWindows then
						rescoredJudge = getRescoredCustomJudge(dvt, customWindow.judgeWindows, k)
					else
						rescoredJudge = getRescoredJudge(dvt, judge, k)
					end
					self:settextf("(%03.2f%%)", rescoredJudge/totalTaps * 100)
				end
				if params.Name == "ResetJudge" then
					self:playcommand("Set")
				end
			end,
		};
	end
	
	t[#t+1] = LoadFont("Common Large")..{
			InitCommand=function(self)
				self:xy(frameX+40,frameY*2.49):zoom(0.25):halign(0)
			end,
			BeginCommand=function(self)
				self:queuecommand("Set")
			end,
			ScoreChangedMessageCommand = function(self) self:queuecommand("Set"); end,
			SetCommand=function(self) 
				if score:GetChordCohesion() == true then
					self:settext("")
				else
					self:settext("")
				end
			end
	};

	local fart = {"Holds", "Mines", "Rolls", "Lifts", "Fakes"}
	for i=1,#fart do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:xy(164,frameY+79+17*i):zoom(0.50):halign(0):settext(fart[i])
			end,
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:xy(273,frameY+79+17*i):zoom(0.50):halign(1)
			end,
			BeginCommand=function(self)
				self:queuecommand("Set")
			end,
			SetCommand=function(self) 
				self:settextf("%03d/%03d",score:GetRadarValues():GetValue("RadarCategory_"..fart[i]),pss:GetRadarPossible():GetValue("RadarCategory_"..fart[i]))
			end,
			ScoreChangedMessageCommand = function(self) self:queuecommand("Set"); end,
		};
	end
	
	-- stats stuff
	local tracks = pss:GetTrackVector()
	local devianceTable = pss:GetOffsetVector()
	local cbl = 0
	local cbr = 0
	
	-- basic per-hand stats to be expanded on later
	local tst = ms.JudgeScalers
	local tso = tst[judge]
	if enabledCustomWindows then
		tso = 1
	end
	
	for i=1,#devianceTable do
		if math.abs(devianceTable[i]) > tso * 90 then
			if tracks[i] == 0 or tracks[i] == 1 then
				cbl = cbl + 1
			else
				cbr = cbr + 1
			end
		end
	end
	

	local smallest,largest = wifeRange(devianceTable)
	local doot = {"Mean", "Mean(Abs)", "Sd", "Left cbs", "Right cbs"}
	local mcscoot = {
		wifeMean(devianceTable), 
		wifeAbsMean(devianceTable),
		wifeSd(devianceTable),
		cbl, 
		cbr
	}

	for i=1,#doot do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=function(self)
				self:xy(66+capWideScale(get43size(130),160),frameY+170+15.5*i):zoom(0.50):halign(0):settext(doot[i])
			end,
		};
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand=function(self)
				if i < 4 then
					self:xy(273,frameY+170+15.5*i):zoom(0.50):halign(1):settextf("%5.2fms",mcscoot[i])
				else
					self:xy(270,frameY+170+15.5*i):zoom(0.50):halign(1):settext(mcscoot[i])
				end
			end,
		};
	end	
	
	return t
end;


if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	t[#t+1] = scoreBoard(PLAYER_1,0)
	if ShowStandardDecoration("GraphDisplay") then
		t[#t+1] = StandardDecorationFromTable( "GraphDisplay" .. ToEnumShortString(PLAYER_1), GraphDisplay(PLAYER_1) )
	end
	if ShowStandardDecoration("ComboGraph") then
		t[#t+1] = StandardDecorationFromTable( "ComboGraph" .. ToEnumShortString(PLAYER_1),ComboGraph(PLAYER_1) )
	end
end

--t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,0):halign(0):valign(0):diffusealpha(0.1) end }
t[#t+1] = LoadActor("../offsetplot")

-- Discord thingies
local largeImageTooltip = GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName() .. ": " .. string.format("%5.2f", GetPlayerOrMachineProfile(PLAYER_1):GetPlayerRating())
local detail = GAMESTATE:GetCurrentSong():GetDisplayMainTitle() .. " " .. string.gsub(getCurRateDisplayString(), "Music", "") .. " [" .. GAMESTATE:GetCurrentSong():GetGroupName() .. "]"
-- truncated to 128 characters(discord hard limit)
detail = #detail < 128 and detail or string.sub(detail, 1, 124) .. "..."
local state = "MSD: " .. string.format("%05.2f", GAMESTATE:GetCurrentSteps(PLAYER_1):GetMSD(getCurRateValue(),1)) .. 
	" - " .. string.format("%05.2f%%",notShit.floor(pssP1:GetWifeScore()*10000)/100) .. 
	" " .. THEME:GetString("Grade",ToEnumShortString(SCOREMAN:GetMostRecentScore():GetWifeGrade()))
GAMESTATE:UpdateDiscordPresence(largeImageTooltip, detail, state, 0)

return t