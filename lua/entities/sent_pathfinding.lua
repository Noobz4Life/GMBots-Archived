if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	self:SetModel("models/player/Group01/male_01.mdl")
	self:SetNoDraw( true )
	self:DrawShadow( false )
	self:SetSolid( SOLID_NONE )
	
	self:SetHealth(math.huge)
	self.PosGen = nil
end

-- Resets Pathfinding.
concommand.Add("gmbots_reset_pathfinding",function(ply)
	if SERVER and ( ply and ply:IsValid() and ply:IsSuperAdmin() or ( not ply or ply and not ply:IsValid())) then
		for a,b in pairs(ents.FindByClass("sent_pathfinding")) do
			if IsValid(b) then
				b:Remove()
			end
		end
		
		for a,b in pairs(player.GetAll()) do
			if b.ResetPathfinding then
				b:ResetPathfinding()
			end
		end	
	end
end)

-- This is to prevent the pathfinding entity appearing in the killfeed.
function ENT:OnKilled()
	self:Remove()
end

function ENT:ChasePos( options )
	self.P = Path( "Chase" )
	self.P:SetMinLookAheadDistance( options.lookahead or 300 )
	self.P:SetGoalTolerance( options.goaltolerance or 20 )
	self.P:Compute( self, self.PosGen )
	
	if !self.P:IsValid() then return end
	while self.P:IsValid() do
		if self.P:GetAge() > 0.1 then
			self.P:Compute( self, self.PosGen )
		end
		self.P:Draw()
		
		if self.loco:IsStuck() then
			self:HandleStuck()
			return
		end
		self:SetModelAndCollision()
		coroutine.yield()
	end
end

function ENT:SetModelAndCollision()
	if self.Owner and IsValid(self.Owner) then
				
		if self.Owner.ph_prop and self.Owner.ph_prop:IsValid() then
			self:SetModel( self.Owner.ph_prop:GetModel() )
			self:SetCollisionBounds( self.Owner.ph_prop:GetCollisionBounds() )
		else
			self:SetModel( self.Owner:GetModel() )
			self:SetCollisionBounds( self.Owner:GetCollisionBounds() ) 
		end
				
		if self.Owner:Health() <= 10 then
			self.loco:SetDeathDropHeight( 100 )
		else
			self.loco:SetDeathDropHeight( 200 )
		end
				
		self.ResetPathfindingTimer = self.ResetPathfindingTimer or 0
		self.ResetPathfindingTimer = self.ResetPathfindingTimer+1
		if self.ResetPathfindingTimer > 1200 then
			self:Remove()
		end
	end
end

function ENT:HandleStuck()
	if self and IsValid( self ) and self.Owner and IsValid(self.Owner) then
		self.Owner.ShouldJump = true
	end
end

function ENT:RunBehaviour()
	while ( true ) do
		if self and IsValid(self) then
			if self.PosGen and self.loco then
				self:ChasePos( {} )
			end
			

			
			self:SetModelAndCollision()
			
			--self:SetDesiredSpeed(5000)
		end
		coroutine.yield()
	end
end