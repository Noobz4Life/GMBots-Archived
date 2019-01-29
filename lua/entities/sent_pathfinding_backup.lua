if SERVER then AddCSLuaFile() end

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

function ENT:Initialize()
	self:SetModel( "models/humans/group01/male_03.mdl" )
        -- remove the line below if you want it to be invisible, it's only visible for debug purposes right now
	self:SetNoDraw( true )
	self:SetSolid( SOLID_NONE )
	self.PosGen = nil
end

function ENT:ChasePos( options )
	self.P = Path( "Follow" )
	self.P:SetMinLookAheadDistance( options.lookahead or 300 )
	self.P:SetGoalTolerance( options.goaltolerance or 20 )
	self.P:Compute( self, self.PosGen )
	
	if !self.P:IsValid() then return end
	while self.P:IsValid() do
		if self.P and self.P:GetAge() > 0.1 then
			self.P:Compute( self, self.PosGen )
		end
		self.P:Draw()
		
		if self.loco:IsStuck() then
			self:HandleStuck()
			return
		end
		
		coroutine.yield()
	end
end

function ENT:HandleStuck()
	if self:GetOwner() then
		self:GetOwner().ShouldTaunt = true
		self:GetOwner().PosGen = Vector(math.random(-200,200),math.random(-200,200),math.random(-200,200))
		self.PosGen = self:GetOwner().PosGen
	end
	self:ClearStuck()
end

function ENT:RunBehaviour()
	while ( true ) do
		if self.PosGen then
			self:ChasePos( {} )
		end
		
		//self.loco:SetDesiredSpeed( self:GetOwner():GetWalkSpeed()+5 )
		
		coroutine.yield()
	end
end