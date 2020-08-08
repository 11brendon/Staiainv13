local function input(event)	-- for update button
	if event.type ~= "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("MouseLeftClick")
		elseif event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("MouseRightClick")
		end
	end
	return false
end

local t = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(input) end,
}

local frameX = THEME:GetMetric("ScreenTitleMenu","ScrollerX")-10
local frameY = THEME:GetMetric("ScreenTitleMenu","ScrollerY")


t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,-23):halign(0):valign(0):diffusealpha(1):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT) end }
t[#t+1] = LoadActor("bgscroll1.png") .. { InitCommand=function(self) self:xy(20,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,capWideScale(640,1080),capWideScale(480, 1080)) end }
t[#t+1] = LoadActor("bgscroll2.png") .. { InitCommand=function(self) self:xy(0,30):halign(0):valign(0):texcoordvelocity(-0.002,-0.01):scaletocover(0,0,capWideScale(640,1080),capWideScale(480, 1080)) end }
t[#t+1] = LoadActor("bgscroll3.png") .. { InitCommand=function(self) self:xy(100,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,capWideScale(640,1080),capWideScale(480, 1080)) end }
t[#t+1] = LoadActor("bgscroll.png") .. { InitCommand=function(self) self:xy(30,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,capWideScale(640,1080),capWideScale(480, 1080)) end }
	
t[#t+1] = LoadFont("Common Formal") .. {
	InitCommand=function(self)
		self:xy(2,478):zoom(0.55):valign(1):halign(0)
	end,
	OnCommand=function(self)
		self:settext("PRESS START")
	end,
}

t[#t+1] = LoadFont("Common Formal") .. {
	InitCommand=function(self)
		self:xy(630,25):zoom(0.5):valign(1):halign(1):shadowlength(2)
	end,
	OnCommand=function(self)
		self:settext("Etterna "..GAMESTATE:GetEtternaVersion()):diffuse(color("#999999"))
	end,
}

t[#t+1] = LoadFont("Common Formal") .. {
	InitCommand=function(self)
		self:xy(4,25):zoom(0.5):valign(1):halign(0):shadowlength(2)
	end,
	OnCommand=function(self)
		self:settextf("%i songs in %i groups", SONGMAN:GetNumSongs(), SONGMAN:GetNumSongGroups()):diffuse(color("#999999"))
	end,
}

-- lazy game update button -mina
local gameneedsupdating = false
local buttons = {x=22,y=40,width=140,height=36,fontScale=0.3,color=getMainColor('frames')}
t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:xy(buttons.x,buttons.y):zoomto(buttons.width,buttons.height):halign(1):valign(0):diffuse(buttons.color):diffusealpha(0)
		local latest = tonumber((DLMAN:GetLastVersion():gsub("[.]","",1)))
		local current = tonumber((GAMESTATE:GetEtternaVersion():gsub("[.]","",1)))
		if latest and latest > current then
			gameneedsupdating = true
		end
	end,
	OnCommand=function(self)
		if gameneedsupdating then
			self:diffusealpha(1)
		end
	end,
	MouseLeftClickMessageCommand=function(self)
		if isOver(self) and gameneedsupdating then
			GAMESTATE:ApplyGameCommand("urlnoexit,https://github.com/etternagame/etterna/releases;text,GitHub")
		end
	end
}

t[#t+1] = LoadFont("Common Large") .. {
	OnCommand=function(self)
		self:xy(buttons.x+3,buttons.y+14):halign(1):zoom(buttons.fontScale):diffuse(getMainColor('positive'))
		if gameneedsupdating then
			self:settext("Update Available\nClick to Update")
		else
			self:settext("")
		end
	end
}


function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

local transformF = THEME:GetMetric("ScreenTitleMenu", "ScrollerTransform")
local scrollerX = THEME:GetMetric("ScreenTitleMenu", "ScrollerX")
local scrollerY = THEME:GetMetric("ScreenTitleMenu", "ScrollerY")
local scrollerChoices = THEME:GetMetric("ScreenTitleMenu", "ChoiceNames")
local _, count = string.gsub(scrollerChoices, "%,", "")
local choices = mysplit(scrollerChoices, ",")
local choiceCount = count+1
local i
for i=1,choiceCount do
	t[#t+1] = Def.Quad {
		OnCommand=function(self)
			self:xy(scrollerX,scrollerY):zoomto(260,16)
			transformF(self, 0, i, choiceCount)
			self:addx(SCREEN_CENTER_X-20)
			self:addy(SCREEN_CENTER_Y-20)
			self:diffusealpha(0)
		end,
		MouseLeftClickMessageCommand = function(self)
			if(isOver(self)) then
				SCREENMAN:GetTopScreen():playcommand("MadeChoicePlayer_1")
				SCREENMAN:GetTopScreen():playcommand("Choose")
				if choices[i] ~= "Multi" and choices[i] ~= "GameStart" then -- for some reason multi gets stuck :/
					GAMESTATE:ApplyGameCommand(THEME:GetMetric("ScreenTitleMenu", "Choice"..choices[i]))
				end
			end
		end,
	}
end


return t
