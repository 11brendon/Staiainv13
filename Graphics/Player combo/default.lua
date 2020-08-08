local threePressed = false
local fourPressed = false
local changed = false
local c
local x = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboX
local y = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboY
local zoom = playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplaySizes.ComboZoom
local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt");

local function input(event)
	if event.DeviceInput.button == "DeviceButton_3" then
		threePressed = not (event.type == "InputEventType_Release")
	end
	if event.DeviceInput.button == "DeviceButton_4" then
		fourPressed = not (event.type == "InputEventType_Release")
	end
	if event.type ~= "InputEventType_Release" and threePressed then
		if event.DeviceInput.button == "DeviceButton_up" then
			y = y - 5
			c.Label:y(y)
			c.Number:y(y)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboY = y
			changed = true
		end
		if event.DeviceInput.button == "DeviceButton_down" then
			y = y + 5
			c.Label:y(y)
			c.Number:y(y)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboY = y
			changed = true
		end
		if event.DeviceInput.button == "DeviceButton_left" then
			x = x - 5
			c.Label:x(x)
			c.Number:x(x-4)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboX = x
			changed = true
		end
		if event.DeviceInput.button == "DeviceButton_right" then
			x = x + 5
			c.Label:x(x)
			c.Number:x(x-4)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplayXYCoordinates.ComboX = x
			changed = true
		end
		if changed then
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
			playerConfig:save(pn_to_profile_slot(PLAYER_1))
			changed = false
		end
	end
	if event.type ~= "InputEventType_Release" and fourPressed then
		if event.DeviceInput.button == "DeviceButton_up" then
			zoom = zoom + 0.01
			c.Label:zoom(zoom)
			c.Number:zoom(zoom - 0.1)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplaySizes.ComboZoom = zoom
			changed = true
		end
		if event.DeviceInput.button == "DeviceButton_down" then
			zoom = zoom - 0.01
			c.Label:zoom(zoom)
			c.Number:zoom(zoom - 0.1)
			playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).GameplaySizes.ComboZoom = zoom
			changed = true
		end
		if changed then
			playerConfig:set_dirty(pn_to_profile_slot(PLAYER_1))
			playerConfig:save(pn_to_profile_slot(PLAYER_1))
			changed = false
		end
	end
	return false
end

local t = Def.ActorFrame {
	InitCommand=function(self)
		self:vertalign(bottom)
	end,
	LoadFont( "Combo", "numbers" ) .. {
		Name="Number",
		InitCommand=function(self)
			self:xy(x-30,y):zoom(zoom + 0.3):halign(0.5):valign(1):visible(false)
		end,
	},
	LoadFont("Common Normal") .. {
		Name="Label",
		InitCommand=function(self)
			self:xy(x,y):zoom(zoom):diffusebottomedge(color("#AAAAAA")):halign(0):valign(1):visible(false)
		end,
	},
	InitCommand = function(self)
		c = self:GetChildren()
	end,
	OnCommand=function(self) 
		if(playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).CustomizeGameplay) then
			SCREENMAN:GetTopScreen():AddInputCallback(input)
		end
	end,
	ComboCommand=function(self, param)
		local iCombo = param.Combo
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false)
			c.Label:visible(false)
			return
		end
		
		c.Label:settext("")
		c.Number:visible(true)
		c.Label:visible(true)
		c.Number:settext(iCombo):diffuse(color("#AAAAAA"))
		
		-- FullCombo Rewards
		if param.FullComboW1 then
			c.Number:diffuse(color("#AAAAAA"))
			c.Number:glowshift()
		elseif param.FullComboW2 then
			c.Number:diffuse(color("#AAAAAA"))
			c.Number:glowshift()
		elseif param.FullComboW3 then
			c.Number:diffuse(color("#AAAAAA"))
			c.Number:stopeffect()
		elseif param.Combo then
			c.Number:diffuse(color("#AAAAAA"))
			c.Number:stopeffect()
			c.Label:diffuse(color("#AAAAAA"))
			c.Label:diffusebottomedge(color("#AAAAAA"))
		else
			c.Number:diffuse(color("#AAAAAA"))
			c.Number:stopeffect()
			c.Label:diffuse(color("#AAAAAA"))
			c.Label:diffusebottomedge(color("#AAAAAA"))
		end
	end
}

return t
