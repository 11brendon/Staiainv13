local t = 
    Def.ActorFrame {
	}
t[#t+1] = LoadActor("rip.png") .. { InitCommand=function(self) self:xy(0,0):halign(0):valign(0):diffusealpha(1):linear(3) end }
t[#t+1] = LoadActor("failed.png") .. { InitCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):diffusealpha(1):zoom(0.5) end }
t[#t+1] = LoadActor("failed.ogg") .. {StartTransitioningCommand=function(self) self:play() end}

	
return t