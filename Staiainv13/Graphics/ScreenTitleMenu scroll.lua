local gc = Var("GameCommand")

return Def.ActorFrame {
	LoadFont("Common Normal") .. {
		Text=THEME:GetString("ScreenTitleMenu",gc:GetText()),
		OnCommand=function(self)
			self:xy(SCREEN_CENTER_X,-80):halign(0):valign(0):halign(0.5):zoom(1.1):shadowlength(5)
		end,
		GainFocusCommand=function(self)
			self:bouncebegin(0.1)
			self:zoom(1.2)
			self:diffuseshift();
			self:effectcolor1(color("#7BF77B"));
			self:effectcolor2(color("#418241"));
			self:effectperiod(0.5);
		end,
		LoseFocusCommand=function(self)
			self:stopeffect():bounceend(0.1):zoom(1.1):diffuse(color("#ffffff"));
		end,
 	}
}

