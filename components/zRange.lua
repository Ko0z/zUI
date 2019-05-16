zUI:RegisterComponent("zRange", function () 
	if C.bars.glowrange == "1" then
		hooksecurefunc("ActionButton_OnUpdate", function(elapsed)
		-- Button color based on range
		if ( this.rangeTimer ) then
			this.rangeTimer = this.rangeTimer - elapsed
			if ( this.rangeTimer <= 0.2 ) then -- 0.1
				if ( IsActionInRange( ActionButton_GetPagedID(this)) == 0 ) then
					if not this.a then
						this.r,this.g,this.b,this.a = strsplit(",", C.bars.rangecolor)
					end
					_G[this:GetName() .. 'Icon']:SetVertexColor(this.r, this.g, this.b, this.a)
					elseif IsUsableAction(ActionButton_GetPagedID(this)) then
						_G[this:GetName() .. 'Icon']:SetVertexColor(1, 1, 1, 1)
					end
					this.rangeTimer = TOOLTIP_UPDATE_TIME
				end
			end
		end)
	end
end)
