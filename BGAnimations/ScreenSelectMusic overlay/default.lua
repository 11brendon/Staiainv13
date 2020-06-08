local function input(event)
	local top = SCREENMAN:GetTopScreen()
	if event.DeviceInput.button == "DeviceButton_left mouse button" and event.type == "InputEventType_Release" then
		MESSAGEMAN:Broadcast("MouseLeftClick")
	elseif event.DeviceInput.button == "DeviceButton_right mouse button" and event.type == "InputEventType_Release" then
		MESSAGEMAN:Broadcast("MouseRightClick")
	end
return false
end

local t = Def.ActorFrame{
	BeginCommand=function(self) 
		local s = SCREENMAN:GetTopScreen()
		s:AddInputCallback(input) 
		if s:GetName() == "ScreenNetSelectMusic" then
			s:UsersVisible(false) 
		end
	end
}

t[#t+1] = LoadActor("tabs")

t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:xy(0,466):zoomto(640,17):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	};

t[#t+1] = LoadActor("../_PlayerInfo")
t[#t+1] = LoadActor("currentsort")
t[#t+1] = LoadFont("Common Large")..{
	InitCommand=function(self)
		self:xy(5,32):halign(0):valign(1):zoom(0.55):diffuse(getMainColor('positive')):settext("")
	end;
}

t[#t+1] = LoadActor("../_cursor")
t[#t+1] = LoadActor("../_halppls")
t[#t+1] = LoadActor("currenttime")
t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,0):halign(0):valign(0):diffusealpha(1) end }

GAMESTATE:UpdateDiscordMenu(GetPlayerOrMachineProfile(PLAYER_1):GetDisplayName() .. ": " .. string.format("%5.2f", GetPlayerOrMachineProfile(PLAYER_1):GetPlayerRating()))

return t
