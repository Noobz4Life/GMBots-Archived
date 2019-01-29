-- This code is for pathfinding if you have gm_navigation, otherwise it will use nextbot pathfinding.
CreateConVar("gmbots_dev_mode",0)
developerMode = 0
local plymeta = FindMetaTable( "Player" )

function plymeta:debug( text )
	developerMode = ( GetConVar("gmbots_dev_mode"):GetInt() > 0 )
	if not developerMode then return end
	
	print(self:Nick()..":", text)
end


function plymeta:generateNav( callback )
	developerMode = ( GetConVar("gmbots_dev_mode"):GetInt() > 0 )
	
	local navmesh = nav.Create( 64 )
	self.tttBot_nav = navmesh -- Global variable to access the navmesh
	
	navmesh:SetDiagonal( true )
	navmesh:SetMask( MASK_PLAYERSOLID )
	--navmesh:SetHeuristic(nav.HEURISTIC_EUCLIDEAN)
	
	-- Find a random position to add as a seed
	local landmark = table.Random( tttBot.landmarks )
	local pos
	if IsValid( landmark ) then
		pos = landmark:GetPos()
	else
		pos = table.Random( player.GetAll() ):GetPos()
	end

	local normal = Vector( 0, 0, 0 )
	local normalUp = Vector(0, 0, 1)

	self:debug("Creating navmesh")
	
	if IsValid( self ) then
		-- Remove this line if you don't want a max distance
		navmesh:SetupMaxDistance(self:GetPos(), 1024) -- All nodes must stay within 256 vector distance from the players position
	end
	
	navmesh:ClearGroundSeeds()
	navmesh:ClearAirSeeds()
	
	-- Once 1 seed runs out, it will go onto the next seed
	navmesh:AddGroundSeed(pos, normal)
	
	-- The module will account for node overlapping
	navmesh:AddGroundSeed(pos, normalUp)
	navmesh:AddGroundSeed(pos, normalUp)
	
	local StartTime = os.time()
	
	-- Generate the nav
	navmesh:Generate( function(navmesh)
		self:debug("Generated "..navmesh:GetNodeTotal().." nodes in "..string.ToMinutesSeconds(os.time() - StartTime).."")
		
		if callback then
			callback()
		end
	end, 
	function( navmesh, GeneratedNodes )
		self:debug("Generated "..GeneratedNodes.." nodes so far")
	end)
end