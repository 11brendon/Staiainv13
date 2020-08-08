-- updated to handle both immediate evaluation when pulling data from pss (doesnt require invoking calls to loadreplay data) and scoretab plot construction (does) -mina

local judges = { "marv", "perf", "great", "good", "boo", "miss" }
local tst = ms.JudgeScalers
local judge = GetTimingDifficulty()
local tso = tst[judge]

-- we removed j1-3 so uhhh this stops things lazily
local function clampJudge()
	if judge < 4 then judge = 4 end
	if judge > 9 then judge = 9 end
end
clampJudge()

local plotWidth, plotHeight = 316,54
local plotX, plotY = 320, 432
local dotDims, plotMargin = 2, 4
local maxOffset = math.max(180, 180*tso)
local baralpha = 0.2
local bgalpha = 0.8
local textzoom = 0.35

-- initialize tables we need for replay data here, we don't know where we'll be loading from yet
local dvt = {}
local nrt = {}
local ctt = {}
local ntt = {}
local wuab = {}
local finalSecond = GAMESTATE:GetCurrentSong(PLAYER_1):GetLastSecond()
local td = GAMESTATE:GetCurrentSteps(PLAYER_1):GetTimingData()

local handspecific = false
local left = false

local function fitX(x)	-- Scale time values to fit within plot width.
	return x/finalSecond*plotWidth - plotWidth/2
end

local function fitY(y)	-- Scale offset values to fit within plot height
	return -1*y/maxOffset*plotHeight/2
end

local o = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(plotX,plotY)
		
		-- being explicit about the logic since atm these are the only 2 cases we handle
		if SCREENMAN:GetTopScreen():GetName() == "ScreenEvaluationNormal" then		-- default case, all data is in pss and no disk load is required
			local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
			dvt = pss:GetOffsetVector()
			nrt = pss:GetNoteRowVector()
			ctt = pss:GetTrackVector()					-- column information for each offset
			ntt = pss:GetTapNoteTypeVector()			-- notetype information (we use this to handle mine hits differently- currently that means not displaying them)
			pss:UnloadReplayData()						-- force unload replaydata in memory after loading it (not sure if i should allow this but i don't trust deconstructors) -mina
		end
		
		if SCREENMAN:GetTopScreen():GetName() == "ScreenScoreTabOffsetPlot" then	-- loaded from scoretab not eval so we need to read from disk and adjust plot display
			plotWidth, plotHeight = SCREEN_WIDTH,SCREEN_WIDTH*0.3
			self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			textzoom = 0.5
			bgalpha = 1
			
			-- the internals here are really inefficient this should be handled better (internally) -mina
			local score = getScoreForPlot()
			dvt = score:GetOffsetVector()
			nrt = score:GetNoteRowVector()
			ctt = score:GetTrackVector()
			ntt = score:GetTapNoteTypeVector()
		end
		
		-- Convert noterows to timestamps and plot dots (this is important it determines plot x values!!!)
		for i=1,#nrt do
			wuab[i] = td:GetElapsedTimeFromNoteRow(nrt[i])
		end
		MESSAGEMAN:Broadcast("JudgeDisplayChanged")		-- prim really handled all this much more elegantly		
	end,
	CodeMessageCommand=function(self,params)
		if params.Name == "PrevJudge" and judge > 1 then
			judge = judge - 1
			clampJudge()
			tso = tst[judge]
		elseif params.Name == "NextJudge" and judge < 9 then
			judge = judge + 1
			clampJudge()
			tso = tst[judge]
		elseif params.Name == "ToggleHands" and #ctt > 0 then --super ghetto toggle -mina
			if not handspecific then
				handspecific = true
				left = true
			elseif handspecific and left then
				left = false
			elseif handspecific and not left then
				handspecific = false
			end
			MESSAGEMAN:Broadcast("JudgeDisplayChanged")
		end
		if params.Name == "ResetJudge" then
			judge = GetTimingDifficulty()
			clampJudge()
			tso = tst[GetTimingDifficulty()]
		end
		maxOffset = math.max(180, 180*tso)
		MESSAGEMAN:Broadcast("JudgeDisplayChanged")
	end,
	UpdateNetEvalStatsMessageCommand = function(self)		-- i haven't updated or tested neteval during last round of work -mina
		local s = SCREENMAN:GetTopScreen():GetHighScore()
		if s then
			score = s
			dvt = score:GetOffsetVector()
			nrt = score:GetNoteRowVector()
			for i=1,#nrt do
				wuab[i] = td:GetElapsedTimeFromNoteRow(nrt[i])
			end
		end
		MESSAGEMAN:Broadcast("JudgeDisplayChanged")
	end,
}
-- Background
o[#o+1] = Def.Quad{JudgeDisplayChangedMessageCommand=function(self)
	self:zoomto(plotWidth+plotMargin,plotHeight+plotMargin):diffuse(color("0.05,0.05,0.05,0.05")):diffusealpha(bgalpha)
end}
-- Center Bar
o[#o+1] = Def.Quad{
	JudgeDisplayChangedMessageCommand=function(self)
		self:zoomto(plotWidth+plotMargin,1):diffuse(byJudgment("TapNoteScore_W1")):diffusealpha(baralpha)
	end
}
local fantabars = {22.5, 45, 90, 135}
local bantafars = {"TapNoteScore_W2", "TapNoteScore_W3", "TapNoteScore_W4", "TapNoteScore_W5"}
for i=1, #fantabars do 
	o[#o+1] = Def.Quad{
		JudgeDisplayChangedMessageCommand=function(self)
			self:zoomto(plotWidth+plotMargin,1):diffuse(byJudgment(bantafars[i])):diffusealpha(baralpha)
			local fit = tso*fantabars[i]
			self:y( fitY(fit))
		end
	}
	o[#o+1] = Def.Quad{
		JudgeDisplayChangedMessageCommand=function(self)
			self:zoomto(plotWidth+plotMargin,1):diffuse(byJudgment(bantafars[i])):diffusealpha(baralpha)
			local fit = tso*fantabars[i]
			self:y( fitY(-fit))
		end
	}
end

local dotWidth = dotDims / 2
local function setOffsetVerts(vt, x, y, c)
	vt[#vt+1] = {{x-dotWidth,y+dotWidth,0}, c}
	vt[#vt+1] = {{x+dotWidth,y+dotWidth,0}, c}
	vt[#vt+1] = {{x+dotWidth,y-dotWidth,0}, c}
	vt[#vt+1] = {{x-dotWidth,y-dotWidth,0}, c}
end
o[#o+1] = Def.ActorMultiVertex{
	JudgeDisplayChangedMessageCommand=function(self)
		local verts = {}
		for i=1,#dvt do
			local x = fitX(wuab[i])
			local y = fitY(dvt[i])
			local fit = math.max(183, 183*tso)
			local cullur = offsetToJudgeColor(dvt[i], tst[judge])
			if math.abs(y) > plotHeight/2 then
				y = fitY(fit)
			end

			-- remember that time i removed redundancy in this code 2 days ago and then did this -mina
			if ntt[i] ~= "TapNoteType_Mine" then						
				if handspecific and left then
					if ctt[i] == 0 or ctt[i] == 1 then
						setOffsetVerts(verts, x, y, cullur)
					else
						setOffsetVerts(verts, x, y, offsetToJudgeColorAlpha(dvt[i], tst[judge]))		-- highlight left
					end
				elseif handspecific then
					if ctt[i] == 2 or ctt[i] == 3 then
						setOffsetVerts(verts, x, y, cullur)
					else
						setOffsetVerts(verts, x, y, offsetToJudgeColorAlpha(dvt[i], tst[judge]))		-- highlight right
					end
				else
					setOffsetVerts(verts, x, y, cullur)
				end
			end
		end
		self:SetVertices(verts)
		self:SetDrawState{Mode="DrawMode_Quads", First = 1, Num=#verts}
	end
}

-- filter 
o[#o+1] = LoadFont("Common Normal")..{
	JudgeDisplayChangedMessageCommand=function(self)
		self:xy(0,plotHeight/2-2):zoom(textzoom):halign(0.5):valign(1)
		if #ntt > 0 then		
			if handspecific then
				if left then
					self:settext("Highlighting left hand taps")
				else
					self:settext("Highlighting right hand taps")
				end
			else
				self:settext("")
			end
		else
			self:settext("")
		end
	end
}

-- Early/Late markers
o[#o+1] = LoadFont("Common Normal")..{
	JudgeDisplayChangedMessageCommand=function(self)
		self:xy(-plotWidth/2,-plotHeight/2+2):zoom(textzoom):halign(0):valign(0):settextf("", maxOffset)
	end
}
o[#o+1] = LoadFont("Common Normal")..{
	JudgeDisplayChangedMessageCommand=function(self)
		self:xy(-plotWidth/2,plotHeight/2-2):zoom(textzoom):halign(0):valign(1):settextf("", maxOffset)
	end
}

return o