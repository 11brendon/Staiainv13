local t = Def.ActorFrame{
	OnCommand=function(self) SCREENMAN:GetTopScreen():UsersVisible(false) end;
}

t[#t+1] = LoadActor("../_frame");
t[#t+1] = LoadActor("../_PlayerInfo")
t[#t+1] = LoadActor("currentsort");
t[#t+1] = LoadFont("Common Large")..{
	InitCommand=function(self)
		self:xy(5,32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor('positive')):settext("Lobby")
	end;
}
t[#t+1] = LoadActor("../_cursor");
t[#t+1] = LoadActor("../_mouseselect")
t[#t+1] = LoadActor("../_mousewheelscroll")
t[#t+1] = LoadActor("currenttime");
t[#t+1] = LoadActor("../_halppls");
t[#t+1] = LoadActor("../_userlist");

return t
