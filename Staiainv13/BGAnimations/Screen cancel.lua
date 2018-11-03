local t = 
    Def.ActorFrame {

        Def.Quad {
            InitCommand=function(self)
                self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(color("#000000"))
            end,
            OnCommand=function(self)
                self:stretchto(SCREEN_LEFT,SCREEN_TOP,SCREEN_RIGHT,SCREEN_BOTTOM):cropleft(1):fadeleft(0.5):linear(0.5):cropleft(-0.5):diffuse(color("#000000"))
            end
        },
        LoadActor ( "Screen cancel.ogg" )..{StartTransitioningCommand=function(self)
			self:play()
		end}
	}

return t
