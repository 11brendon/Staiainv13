return Def.ActorFrame{
	
	Def.Quad{
		Name="Horizontal";
		InitCommand=function(self)
			self:xy(160,-2):zoomto(290,23):halign(0.5)
		end;
		SetCommand=function(self)
			self:diffuseramp();
			self:effectcolor1(color("#4444444a"));
			self:effectcolor2(color("#4444444a"));
		end;
		BeginCommand=function(self)
			self:queuecommand("Set")
		end;
		OffCommand=function(self)
			self:visible(false)
		end;
	};

};