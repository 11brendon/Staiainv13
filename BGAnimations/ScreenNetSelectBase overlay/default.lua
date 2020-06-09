-- forcibly set the game style to single so we dont crash when loading songs
GAMESTATE:SetCurrentStyle("single")
GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')

local t = Def.ActorFrame{
}

t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_PlayerInfo")
t[#t+1] = LoadActor("currentsort")
t[#t+1] = LoadActor("currenttime")
t[#t+1] = LoadFont("Common Large")..{InitCommand=function(self)
	self:xy(5,32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor("positive")):maxwidth(SCREEN_WIDTH/2-10):settext("Room: "..(NSMAN:GetCurrentRoomName() or ""))
end}
t[#t+1] = LoadActor("../_cursor")
t[#t+1] = LoadActor("../_mouseselect")
t[#t+1] = LoadActor("../_halppls")
t[#t+1] = LoadActor("../_userlist")

return t
