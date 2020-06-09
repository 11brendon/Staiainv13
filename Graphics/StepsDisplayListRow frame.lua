t = Def.ActorFrame{}


t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:zoomto(22,22):diffuse(color("#ffffff")):diffusealpha(0)
	end;
}

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:x(22):zoomto(66,22):diffuse(color("#ffffff")):diffusealpha(0)
	end,
	MouseLeftClickMessageCommand=function(self)
		if isOver(self) and self:GetParent():GetParent():GetDiffuseAlpha() > 0 then
			local s = GAMESTATE:GetCurrentSong()
			if s then
				local idx = self:GetParent():GetParent():GetIndex() - self:GetParent():GetParent():GetParent():GetCurrentIndex()
				if idx ~= 0 then
					SCREENMAN:GetTopScreen():ChangeSteps(idx)
				end
			end
		end
	end,
}



return t