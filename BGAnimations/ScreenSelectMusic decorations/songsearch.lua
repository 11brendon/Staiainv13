local searchstring = ""
local frameX = 160
local frameY = 180+capWideScale(get43size(120),120)
local active = false
local whee
local lastsearchstring = ""

local function searchInput(event)
	if event.type ~= "InputEventType_Release" and active == true then
		if event.button == "Back" then
			searchstring = ""
			whee:SongSearch(searchstring)
			resetTabIndex(0)
			MESSAGEMAN:Broadcast("TabChanged")
			MESSAGEMAN:Broadcast("EndingSearch")
		elseif event.button == "Start" then
			resetTabIndex(0)
			MESSAGEMAN:Broadcast("EndingSearch")
			MESSAGEMAN:Broadcast("TabChanged")
		elseif event.DeviceInput.button == "DeviceButton_space" then					-- add space to the string
			searchstring = searchstring.." "
		elseif event.DeviceInput.button == "DeviceButton_backspace"then
			searchstring = searchstring:sub(1, -2)								-- remove the last element of the string
		elseif event.DeviceInput.button == "DeviceButton_delete"  then
			searchstring = ""
		elseif event.DeviceInput.button == "DeviceButton_="  then
			searchstring = searchstring.."="	
		elseif event.DeviceInput.button == "DeviceButton_v" and CtrlPressed then
			searchstring = searchstring..HOOKS:GetClipboard()
		else
			--if not nil and (not a number or (ctrl pressed and not online))
			local CtrlPressed = INPUTFILTER:IsBeingPressed("left ctrl") or INPUTFILTER:IsBeingPressed("right ctrl")
			if event.char and event.char:match("[%%%+%-%!%@%#%$%^%&%*%(%)%=%_%.%,%:%;%'%\"%>%<%?%/%~%|%w]") and (not tonumber(event.char) or CtrlPressed == (SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic")) then
				searchstring = searchstring..event.char
			end
		end
		if lastsearchstring ~= searchstring then
			MESSAGEMAN:Broadcast("UpdateString")
			whee:SongSearch(searchstring)
			lastsearchstring = searchstring
		end
	end
end

local t = Def.ActorFrame{
	OnCommand=function(self)
		whee = SCREENMAN:GetTopScreen():GetMusicWheel()
		SCREENMAN:GetTopScreen():AddInputCallback(searchInput)
		self:visible(false)
	end,
	Def.Quad{
		InitCommand=function(self)
			self:xy(13,102):zoomto(132,78):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	},
	Def.Quad{
		InitCommand=function(self)
			self:xy(177,35):zoomto(288,38):halign(0):valign(0):diffuse(color("#030505CC"))
		end,
	},
	SetCommand=function(self)
		self:finishtweening()
		if getTabIndex() == 3 then
			ms.ok("Song search activated")
			MESSAGEMAN:Broadcast("BeginningSearch")
			self:visible(true)
			active = true
			whee:Move(0)
			SCREENMAN:set_input_redirected(PLAYER_1, true)
			MESSAGEMAN:Broadcast("RefreshSearchResults")
		else 
			self:visible(false)
			self:queuecommand("Off")
			active = false
			SCREENMAN:set_input_redirected(PLAYER_1, false)
		end
	end,
	TabChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	
	
	
	LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(frameX+250-capWideScale(get43size(120),30),frameY-225):zoom(0.7):halign(0.5):maxwidth(470)
		end,
		SetCommand=function(self) 
			if active then
				self:settext("Search Active:")
				self:diffuse(getGradeColor("Grade_Tier03"))
			else
				self:settext("Search Complete:")
				self:diffuse(byJudgment("TapNoteScore_Miss"))
			end
		end,
		UpdateStringMessageCommand=function(self)
			self:queuecommand("Set")
		end,
	},
	LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(frameX+250-capWideScale(get43size(120),30),frameY-210):zoom(0.7):halign(0.5):maxwidth(410)
		end,
		SetCommand=function(self) 
			self:settext(searchstring)
		end,
	UpdateStringMessageCommand=function(self)
		self:queuecommand("Set")
	end,
	},
	LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(frameX-142,frameY-160):zoom(0.4):halign(0)
		end,
		SetCommand=function(self) 
			self:settext("Start to lock search results.")
		end,
		UpdateStringMessageCommand=function(self)
			self:queuecommand("Set")
		end,
	},
	LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(frameX-142,frameY-140):zoom(0.4):halign(0)
		end,
		SetCommand=function(self) 
			self:settext("Back to cancel search.")
		end,
		UpdateStringMessageCommand=function(self)
			self:queuecommand("Set")
		end,
	},
	LoadFont("Common Large")..{
		InitCommand=function(self)
			self:xy(frameX-142,frameY-120):zoom(0.4):halign(0)
		end,
		SetCommand=function(self) 
			self:settext("Delete resets search query.")
		end,
		UpdateStringMessageCommand=function(self)
			self:queuecommand("Set")
		end,
	},
	LoadFont("Common Normal")..{
		InitCommand=function(self)
			self:xy(frameX-80,frameY-100):zoom(0.3):halign(0.5)
		end,
		SetCommand=function(self) 
			self:settext("Currently supports standard\n english alphabet only.")
		end,
		UpdateStringMessageCommand=function(self)
			self:queuecommand("Set")
		end,
	},
}

t[#t+1] = LoadActor("2.png") .. { InitCommand=function(self) self:xy(0,85):halign(0):valign(0):diffusealpha(1) end }
t[#t+1] = LoadActor("4.png") .. { InitCommand=function(self) self:xy(-66,-100):halign(0):valign(0):diffusealpha(1) end }

return t