return Def.ActorFrame {
    Def.Sprite {
        InitCommand = function(self)
            self:Load(THEME:GetPathG("", "rectangleforpacks"))
			self:xy(160,-2)
        end
    }
}