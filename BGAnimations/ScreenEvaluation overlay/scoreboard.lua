function gradestring(tier) --to be moved
	return getGradeStrings(tier)
end

local lines = 3 -- number of scores to display
local framex = SCREEN_WIDTH-capWideScale(get43size(638),230)
local framey = 146
local frameWidth = capWideScale(get43size(220),220)
local spacing = 25.3


local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]

local profile
local steps
local origTable
local hsTable
local rtTable
local scoreIndex
local score

local player = GAMESTATE:GetEnabledPlayers()[1]

if GAMESTATE:IsPlayerEnabled(player) then
	profile = GetPlayerOrMachineProfile(player)
	steps = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPlayedSteps()[1]
	origTable = getScoresByKey(player)
	score = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetHighScore()
	rtTable = getRateTable(origTable)
	hsTable = rtTable[getRate(score)] or {score}
	scoreIndex = getHighScoreIndex(hsTable,score)
end

--Input event for mouse clicks
local function input(event)
	local scoreBoard = SCREENMAN:GetTopScreen():GetChildren().scoreBoard
	if event.DeviceInput.button == 'DeviceButton_left mouse button' and scoreBoard then
		if event.type == "InputEventType_Release" then
			for i=0,math.min(lines,#hsTable)-1 do
				if isOver(scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver")) then
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):GetVisible())
				end
			end
		end
	end
return false
end


local t = Def.ActorFrame{
	Name="scoreBoard",
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(input) end
}

local function scoreitem(pn,index,scoreIndex,drawindex)

	--First box always displays the 1st place score
	if drawindex == 0 then
		index = 1
	end;

	--Whether the score at index is the score that was just played.
	local equals = (index == scoreIndex)

	--
	local t = Def.ActorFrame {
		Name="scoreItem"..tostring(drawindex),

		

		--Highlight quad for the current score
		Def.Quad{
			InitCommand=function(self)
				self:xy(framex,framey+(drawindex*spacing)-4):zoomto(frameWidth,25.3):halign(0):valign(0):diffuse(color("#ffffff")):diffusealpha(0.3):diffuserightedge(color("#33333300"))
			end,
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn) and equals)
			end
		},

		--Quad that will act as the bounding box for mouse rollover/click stuff.
		Def.Quad{
			Name="mouseOver";
			InitCommand=function(self)
				self:xy(framex,framey+(drawindex*spacing)-4):zoomto(frameWidth,30):halign(0):valign(0):diffuse(getMainColor('highlight')):diffusealpha(0.05)
			end,
			BeginCommand=function(self)
				self:visible(false)
			end
		},

		--ClearType lamps
		Def.Quad{
			InitCommand=function(self)
				self:xy(framex,framey+(drawindex*spacing)-4):zoomto(6,25.3):halign(0):valign(0):diffuse(getClearTypeFromScore(pn,hsTable[index],2))
			end,
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn))
			end
		},

		--rank
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(framex+3.25,framey+8+(drawindex*spacing)):zoom(0.35)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 then
					self:settext(index)
					if equals then
						self:diffuse(color("#ffcccc"))
					else
						self:stopeffect()
					end
				end
			end
		},
		
		-- Wife grade and %score
		LoadFont("Common normal")..{
			Name="grade",
			InitCommand=function(self)
				self:xy(framex+8,framey+0+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.3)
			end,
			BeginCommand=function(self)
				if hsTable[index]:GetWifeScore() == 0 then 
					self:settextf("NA (%s)", "Wife")
				else
					self:settextf("%05.2f%% (%s)", notShit.floor(hsTable[index]:GetWifeScore()*10000)/100, "Wife")
				end
			end
		},

		--mods
		LoadFont("Common normal")..{
			Name="option",
			InitCommand=function(self)
				self:xy(framex+10,framey+11+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				self:settext(hsTable[index]:GetModifiers())
				self:visible(false)
			end
		},
	
		--grade text
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(framex+147+capWideScale(get43size(0),50),framey+2+(drawindex*spacing)):zoom(0.35):halign(0.5):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settext(gradestring(hsTable[index]:GetWifeGrade()))
					self:diffuse(getGradeColor(hsTable[index]:GetWifeGrade()))
				end
			end
		},
		
		--cleartype text
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(framex+147+capWideScale(get43size(0),50),framey+14+(drawindex*spacing)):zoom(0.35):halign(0.5):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settext(getClearTypeFromScore(pn,hsTable[index],0))
					self:diffuse(getClearTypeFromScore(pn,hsTable[index],2))
				end
			end
		},
		
		--max combo
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(framex+13+capWideScale(get43size(0),50),framey+8+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settextf("%sx",hsTable[index]:GetMaxCombo())
				end
			end
		},

		--judgment
		LoadFont("Common normal")..{
			Name="judge";
			InitCommand=function(self)
				self:xy(framex+8,framey+16+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settextf("%d / %d / %d / %d / %d / %d",
						hsTable[index]:GetTapNoteScore("TapNoteScore_W1"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W2"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W3"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W4"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W5"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_Miss"))
				end
			end
		},

		--date
		LoadFont("Common normal")..{
			Name="date";
			InitCommand=function(self)
				self:xy(framex+10,framey+20+(drawindex*spacing)):zoom(0.35):halign(0)
			end,
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settext(hsTable[index]:GetDate())
				end
				self:visible(false)
			end
		},

	}
	return t
end

--can't have more lines than the # of scores huehuehu
if lines > #hsTable then
	lines = #hsTable
end;

local drawindex = 0
local startind = 1
local finishind = lines+startind-1

-- Sets the range of indexes to display depending on your rank
if scoreIndex>math.floor(#hsTable-lines/2) then
	startind = #hsTable-lines+1
	finishind = #hsTable 
elseif scoreIndex>math.floor(lines/2) then
	finishind = scoreIndex + math.floor(lines/2)
	if lines%2 == 1 then
		startind = scoreIndex - math.floor(lines/2)
	else
		startind = scoreIndex - math.floor(lines/2)+1
	end
end

while drawindex<#hsTable and startind<=finishind do
	t[#t+1] = scoreitem(player,startind,scoreIndex,drawindex)
	startind = startind+1
	drawindex  = drawindex+1
end

--Update function for showing mouse rollovers
local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end;
	for i=0,drawindex-1 do
		if isOver(self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver")) then
			self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver"):visible(true)
		else
			self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver"):visible(false)
			self:GetChild("scoreItem"..tostring(i)):GetChild("grade"):visible(true)
			self:GetChild("scoreItem"..tostring(i)):GetChild("judge"):visible(true)
			self:GetChild("scoreItem"..tostring(i)):GetChild("date"):visible(false)
			self:GetChild("scoreItem"..tostring(i)):GetChild("option"):visible(false)
		end
	end
end
t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end	

return t