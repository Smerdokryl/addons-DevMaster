function ToggleButtonTemplate_OnClick(self)
	if ( self:IsEnabled() ) then
		if (self:GetChecked()) then
			self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
			self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
			self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Down");
		else
			self.Left:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
			self.Middle:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
			self.Right:SetTexture("Interface\\Buttons\\UI-Panel-Button-Up");
		end		
	end
end