-- Everything relating to the gameplay screen is gradually moved to WifeJudgmentSpotting.lua
local t = Def.ActorFrame{}
t[#t + 1] = LoadActor("spacegorillaiscool")
t[#t+1] = LoadActor("WifeJudgmentSpotting")
t[#t+1] = LoadActor("titlesplash")
t[#t+1] = LoadActor("bn.png") .. { InitCommand=function(self) self:xy(0,0):halign(0):valign(0):diffusealpha(1) end }
return t
