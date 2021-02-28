SliderMixin = {};

function SkewedSliderVal(slider, val)
    val = val or slider:GetValue();
    if val <= 0 then
        val = 0.9 + (cur/10);
    end
    return val;
end

function ExtendedSliderVal(slider,cur,prev,extralow,extrahigh)
	if cur <= 0 then 
		cur = 0.9 + (cur/10)
	end
	
	--[[ if floor(cur) == 1 then
		if prev > 1 then
			--slidername:SetValueStep(1)
			if extralow then extralow() end
		elseif prev < 1 then
			--slidername:SetValueStep(10)
			if extrahigh then extrahigh() end
		end
	end ]]
	
	if cur ~= prev then
		return cur
	end
end