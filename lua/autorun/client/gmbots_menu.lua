function OpenGMBotsMenu(ply,cmd,args)
	local frame = vgui.Create( "DFrame" )
	frame:SetSize( ScrW()/3, ScrH()/1.1 )
	frame:Center()
	frame:SetTitle("GMBots Admin Menu")
	frame:SetBackgroundBlur( true )
	frame:MakePopup()
	
	
	local sheet = vgui.Create( "DPropertySheet", frame )
	sheet:SetSize(frame:GetSize() )
	sheet:Dock( FILL )
	
	--[[
		ADD/REMOVE BOT STUFF
	]]
	
	local panel1 = vgui.Create( "DPanel", sheet )
	panel1.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end
	sheet:AddSheet( "Add/Remove Bots", panel1, "icon16/application.png" )
	
	--[[
		BOT INFO STUFF
	]]
	
	local panel2 = vgui.Create( "DPanel", sheet )
	panel2.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 255, 128, 0 ) ) end
	sheet:AddSheet( "Bot Info", panel2, "icon16/box.png" )
	
	local layout = vgui.Create("DComboBox", panel2 )
	layout:SetSize( panel2:GetWide()/.5,panel2:GetTall()/1.2)
	
	function layout:OnSelect( index,value,data)
		if data and type(data) == "function" then
			data()
		end
	end
	
	local name = vgui.Create("DLabel",panel2)
	name:SetSize(frame:GetWide(),name:GetTall() )
	name:SetPos(panel2:GetWide()/.3,panel2:GetTall()/1.2)
	name:SetText("Name: None")
	
	for a,b in pairs( player.GetAll() ) do
		if b and b:SteamID() == "BOT" or b and b:SteamID() == "NULL" then
			layout:AddChoice(b:Name(),function()
				if b and b:IsValid() then
					name:SetText("Name: "..b:Name() )
				end
			end)
			
			print(player,b)
		else
			print(b:SteamID() )
		end
	end
end

concommand.Add("gmbots_adminmenu",function(ply,cmd,args)
	if not ply then
		ply = LocalPlayer()
	end
	if ply and ply:IsSuperAdmin() then
		OpenGMBotsMenu(ply,cmd,args)
	end
end)