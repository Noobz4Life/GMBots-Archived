-- This generates abunch of nodes, and then uses the default pathfinding to get to one of those nodes.

local plymeta = FindMetaTable( "Player" )

local CurNavMesh = {}
local IsGenerating = false

function RayBrushes(start,endpos)
	local trace = {
		start = start,
		endpos = endpos,
		filter = ents.GetAll(),
	}
	
	return util.TraceLine(trace)
end

function GenerateGMNav()
	if IsGenerating then return end
	CurNavMesh = {}
	IsGenerating = true
	local allents = ents.GetAll()
	for i = 1,#allents do
		local ent = allents[i]
		if ent and ent:IsValid() then
			local lastpos = ent:GetPos()
			for i = 1,50 do
				local x = math.random(-10000000,10000000)
				local y = math.random(-10000000,10000000)
				local z = math.random(-10000000,10000000)
				local raylastposup = RayBrushes(lastpos,lastpos+Vector(0,5,0))
				if raylastposup.HitPos then
					local starttrace = RayBrushes(raylastposup.HitPos,Vector(x,y,z))
					
					
					if starttrace.HitPos then
						local endtrace = RayBrushes(starttrace.HitPos,starttrace.HitPos - Vector(0,9999999,0))
						if endtrace.HitPos then
							table.insert(CurNavMesh,endtrace.HitPos)
							lastpos = endtrace.HitPos
						end
					end
				end
			end
		end
	end
end

function plymeta:PathfindProtoGetClosestNode(pos)
	if pos and self and self:IsValid() and self.GCNCooldown and not IsGenerating and #CurNavMesh > 0 then
		if CurTime() > self.GCNCooldown then
			local lastdist = 1000000000
			local lastnode = nil
			local NavMeshWithPos = CurNavMesh
			NavMeshWithPos[#NavMeshWithPos+1] = pos
			for i = 1,#CurNavMesh do
				local node = CurNavMesh[i]
				if node and self and self:IsValid() then
					local dist = node:Distance(pos)
					if dist < lastdist then
						if RayBrushes(self:GetPos(),node) then
							lastdist = dist
							lastnode = node
						end
					end
				end
			end
			self.GCNCooldown = CurTime()+1
			self.GCNLast = lastnode
			
			if lastnode == pos then
				self.GCNUseDefault = true
			else
				self.GCNUseDefault = false
			end
			return lastnode or self.GCNLast or pos or self:GetPos()
		else
			return self.GCNLast or pos or self:GetPos()
		end
	else
		return self.GCNLast or pos or self:GetPos()
	end
end

function plymeta:PathfindProtoType(cmd,pos,slow)
	if not self.GCNUseDefault then
		if #CurNavMesh <= 0 and not IsGenerating then
			GenerateGMNav() -- Generate.
		elseif not IsGenerating then -- It's been generated, we can now actually do the pathfinding.
			
		end
	else
		self:PathfindProtoGetClosestNode(pos)
	end
	return self:Pathfind(cmd,pos,slow,true) -- If nothing has been returned, then go back to default pathfinding.
end