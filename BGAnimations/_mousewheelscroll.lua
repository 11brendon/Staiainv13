
local moving = false
local whee
local pressingtab = false
local top

local function scrollInput(event)
	if top:GetSelectionState() == 2 then
		return
	elseif event.DeviceInput.button == "DeviceButton_tab" then
		if event.type == "InputEventType_FirstPress" then
			pressingtab = true
		elseif event.type == "InputEventType_Release" then
			pressingtab = false
		end
	elseif event.DeviceInput.button == "DeviceButton_mousewheel up" and event.type == "InputEventType_FirstPress" and top:GetSelectionState() ~= 2 then
		moving = true
		if pressingtab == true then
			whee:Move(-2)
		elseif whee:IsSettled() then
			whee:Move(-1)
		else
			whee:Move(-1)
		end
	elseif event.DeviceInput.button == "DeviceButton_mousewheel down" and event.type == "InputEventType_FirstPress" and top:GetSelectionState() ~= 2 then
		moving = true
		if pressingtab == true then
			whee:Move(2)
		elseif whee:IsSettled() then
			whee:Move(1)
		else
			whee:Move(1)
		end
	elseif moving == true then
		whee:Move(0)
		moving = false
	end
	
	if top:GetSelectionState() == 2 then
		return
	end
	
	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()
	
	if mouseX > capWideScale(160,465) and mouseX < 480 then
		if event.DeviceInput.button == "DeviceButton_left mouse button" and event.type == "InputEventType_FirstPress"then
			local n=0
			local m=1
			if mouseY > 299 and mouseY < 327 then
				m=0
			elseif mouseY > 327 and mouseY < 355 then
				m=1
				n=1
			elseif mouseY > 355 and mouseY < 383 then
				m=1
				n=2
			elseif mouseY > 383 and mouseY < 411 then
				m=1
				n=3
			elseif mouseY > 311 and mouseY < 435 then
				m=1
				n=4
			elseif mouseY > 272 and mouseY < 299 then
				m=-1
				n=1
			elseif mouseY > 245 and mouseY < 272 then
				m=-1
				n=2
			elseif mouseY > 218 and mouseY < 245 then
				m=-1
				n=3
			elseif mouseY > 191 and mouseY < 218 then
				m=-1
				n=4
			elseif mouseY > 164 and mouseY < 191 then
				m=-1
				n=5
			elseif mouseY > 100 and mouseY < 164 then
				m=-1
				n=5
			end
			
			local doot = whee:MoveAndCheckType(m*n)
			whee:Move(0)
			if m == 0 or doot == "WheelItemDataType_Section" then
				top:SelectCurrent(0)
			end
		elseif event.DeviceInput.button == "DeviceButton_right mouse button" and event.type == "InputEventType_FirstPress"then
			setTabIndex(7)
			MESSAGEMAN:Broadcast("TabChanged")
		end
	end
return false
end

local t = Def.ActorFrame{
	BeginCommand=function(self)
		whee = SCREENMAN:GetTopScreen():GetMusicWheel()
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(scrollInput)
		self:visible(false)
	end,
}
return t
