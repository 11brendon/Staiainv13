local t = 
    Def.ActorFrame {
	}
t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,-23):halign(0):valign(0):diffusealpha(1) end }
t[#t+1] = LoadActor("bgscroll1.png") .. { InitCommand=function(self) self:xy(20,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll2.png") .. { InitCommand=function(self) self:xy(0,30):halign(0):valign(0):texcoordvelocity(-0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll3.png") .. { InitCommand=function(self) self:xy(100,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }
t[#t+1] = LoadActor("bgscroll.png") .. { InitCommand=function(self) self:xy(30,0):halign(0):valign(0):texcoordvelocity(0.002,-0.01):scaletocover(0,0,640,480) end }
	
return t