local cdg

-- hurrrrr nps quadzapalooza -mina
local wodth = capWideScale(280, 300)
local hidth = 40
local txtoff = 10

local textonleft = true


local function makeABar(vertices, x, y, barWidth, barHeight, prettycolor)
	vertices[#vertices + 1] = {{x,y-barHeight,0},prettycolor}
	vertices[#vertices + 1] = {{x-barWidth,y-barHeight,0},prettycolor}
	vertices[#vertices + 1] = {{x-barWidth,y,0},prettycolor}
	vertices[#vertices + 1] = {{x,y,0},prettycolor}
end

local function getColorForDensity(density)
	if density == 1 then
		return color(".75,.75,.75") -- nps color
	elseif density == 2 then
		return color(".5,.5,.5") -- jumps color
	elseif density == 3 then
		return color(".25,.25,.25") -- hands color
	else
		return color(".1,.1,.1") -- quads color
	end
end

local function updateGraphMultiVertex(parent, realgraph)
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
	if steps then
		local graphVectors = steps:GetCDGraphVectors()
		if graphVectors == nil then
			-- reset everything if theres nothing to show
			realgraph:SetVertices({})
			realgraph:SetDrawState( {Mode = "DrawMode_Quads", First = 0, Num = 0} )
			realgraph:visible(false)
			return
		end
		
		local npsVector = graphVectors[1] -- refers to the cps vector for 1 (tap notes)
		local numberOfColumns = #npsVector
		local columnWidth = wodth/numberOfColumns
		
		-- set height scale of graph relative to the max nps
		local hodth = 0
		for i=1,#npsVector do
			if npsVector[i] * 2 > hodth then
				hodth = npsVector[i] * 2
			end
		end
		
		parent:GetChild("npsline"):y(-hidth * 0.7)
		parent:GetChild("npstext"):settext(hodth / 2 * 0.7 .. " nps"):y(-hidth * 0.94):zoomx(0.7):x(2):diffuse(getMainColor("positive"))
		hodth = hidth/hodth
		local verts = {} -- reset the vertices for the graph
		local yOffset = 0 -- completely unnecessary, just a Y offset from the graph
		for density = 1,4 do
			for column = 1,numberOfColumns do
					if graphVectors[density][column] > 0 then
						local barColor = getColorForDensity(density)
						makeABar(verts, column * columnWidth, yOffset, columnWidth, graphVectors[density][column] * 2 * hodth, barColor)
					end
			end
		end
		
		realgraph:SetVertices(verts)
		realgraph:SetDrawState( {Mode = "DrawMode_Quads", First = 1, Num = #verts} )
	end
end

local t = Def.ActorFrame {
    Name = "ChordDensityGraph",
    InitCommand=function(self)
		self:SetUpdateFunction(textmover)
		cdg = self
	end,
	DelayedChartUpdateMessageCommand = function(self)
		self:queuecommand("GraphUpdate")
	end,
	Def.Quad {
        Name = "cdbg",
        InitCommand = function(self)
            self:zoomto(wodth, hidth + 2):valign(1):diffuse(color("1,1,1,1")):halign(0)
        end
    }
}

t[#t+1] =
	Def.ActorMultiVertex {
		Name = "CDGraphDrawer",
		GraphUpdateCommand = function(self)
			if self:GetVisible() then
				updateGraphMultiVertex(cdg, self)
			end
		end
	}

-- down here for draw order
t[#t + 1] = Def.Quad {
    Name = "npsline",
    InitCommand = function(self)
        self:zoomto(wodth, 2):diffusealpha(1):valign(1):diffuse(color(".75,0,0,0.75")):halign(0)
    end,

}

t[#t + 1] = LoadFont("Common Normal") .. {
    Name = "npstext",
    InitCommand = function(self)
        self:halign(0)
        self:zoom(0.4)
        self:settext(""):diffuse(color("1,0,0"))
    end
}

return t
