return Def.ActorFrame{
	Def.Quad{
		InitCommand=function(self)
			self:xy(17,-2):zoomto(2,23)
		end,
		SetGradeCommand=function(self,params)
			if params.Grade then
				self:diffuse(getDifficultyColor("Difficulty_"..params.Difficulty))
				self:diffusealpha(0.5)
			else
				self:diffusealpha(0)
			end
		end
	},
	Def.Sprite {
		InitCommand=function(self)
			self:xy(320,-2)
		end,
		SetGradeCommand=function(self,params)
			if params.Favorited then
				self:Load(THEME:GetPathG("","favorite"))
				self:zoomto(16,16)
				self:visible(true)
			else
				self:visible(false)
			end
		end,
	},
	Def.Sprite {
		InitCommand=function(self)
			self:xy(320,-2):zoomto(4,19)
		end,
		SetGradeCommand=function(self,params)
			if params.PermaMirror then
				self:Load(THEME:GetPathG("","mirror"))
				self:zoomto(24,24)
				self:visible(true)
			else
				self:visible(false)
			end
		end,
	},
	Def.Quad{
		InitCommand=function(self)
			self:xy(2,-2):zoomto(4,19)
		end,
		SetGradeCommand=function(self,params)
			if params.HasGoal then
				self:diffuse(byJudgment("TapNoteScore_Miss"))
				self:diffusealpha(1)
			else
				self:diffusealpha(0)
			end
		end
	},
	LoadFont("Common Normal") .. {
        InitCommand=function(self)
        	self:xy(7,-3):zoom(0.5):maxwidth(WideScale(get43size(20),20)/0.5)
        end,
        SetGradeCommand=function(self,params)
			local sGrade = params.Grade or 'Grade_None'
			self:valign(0.5)
			self:settext(THEME:GetString("Grade",ToEnumShortString(sGrade)) or "")
			self:diffuse(getGradeColor(sGrade))
        end
	}
}