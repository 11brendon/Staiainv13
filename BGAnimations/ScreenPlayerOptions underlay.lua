t = Def.ActorFrame {};

local frameX = THEME:GetMetric("ScreenTitleMenu","ScrollerX")-10
local frameY = THEME:GetMetric("ScreenTitleMenu","ScrollerY")
local enabled = themeConfig:get_data().global.SongBGEnabled
local brightness = 0.4

if enabled then
	t[#t+1] = LoadSongBackground()..{
		BeginCommand=function(self)
			self:scaletocover(5,0,SCREEN_WIDTH,SCREEN_BOTTOM)
			self:diffusealpha(brightness)
		end
	}
end
t[#t+1] = LoadActor("bgscroll1.png") .. { InitCommand=function(self) self:xy(20,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll2.png") .. { InitCommand=function(self) self:xy(0,30):halign(0):valign(0):texcoordvelocity(-0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll3.png") .. { InitCommand=function(self) self:xy(100,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll.png") .. { InitCommand=function(self) self:xy(30,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }

t[#t+1] = LoadActor(THEME:GetPathG("","_OptionsScreen")) .. {
		OnCommand=function(self)
			self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):Center():zoom(1):diffusealpha(0)
		end	
}

local x = 75
local y = 500
if GetScreenAspectRatio( ) > 1.7 then
    x = 310
    y = 500
end
t[#t+2] = LoadActor(THEME:GetPathG("","_OptionsActor")) .. {
        OnCommand=function(self)
            self:zoomto(x,y):y(SCREEN_CENTER_Y):diffusealpha(0)
    end    
}

return t
