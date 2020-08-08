return Def.ActorFrame{
    InitCommand=function(self)
        self:xy(SCREEN_WIDTH/2,SCREEN_HEIGHT-3):halign(0):valign(1):y(450)
    end;

    Def.Quad{
        InitCommand=function(self)
            self:zoomto(SCREEN_WIDTH+10,1):diffuse(color("#ffffffaa"))
        end;
    };

    Def.ActorFrame{
        Def.SongMeterDisplay {
            InitCommand=function(self)
                self:SetStreamWidth(SCREEN_WIDTH)
            end;
            Stream=Def.Actor{};
            Tip=Def.ActorFrame{
                Def.Quad{
                    InitCommand=function(self)
                        self:draworder(6):zoomto(2,10):diffuse(color("White"))
                    end;
                };
            };
        };
    };
};
