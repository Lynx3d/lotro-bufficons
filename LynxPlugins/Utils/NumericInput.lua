
import "Turbine.UI";
import "Turbine.UI.Lotro";

AdjustButton = class(Turbine.UI.Control);

function AdjustButton:Constructor(leftSide)
	Turbine.UI.Control.Constructor(self);

	if leftSide then
		self.baseImageID = 0x410001c7;
	else
		self.baseImageID = 0x410001cb;
	end
	self.pressed = false;
	self:SetSize(20, 20);
	self:SetBackground(self.baseImageID + 2);
	self:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);

	self.MouseDown = self.MouseDownCallback;
	self.MouseUp = self.MouseUpCallback;
	self.MouseEnter = self.MouseEnterCallback;
	self.MouseLeave = self.MouseLeaveCallback;
end

function AdjustButton:IsMouseInside(x, y)
	return x>=0 and x<20 and y>=0 and y<20;
end

function AdjustButton.MouseDownCallback(self, args)
	if (not self:IsEnabled()) then
		return;
	end

	if (args.Button == Turbine.UI.MouseButton.Left) then
		self.pressed = true;
		self:SetBackground(self.baseImageID + 1);
	end
end

function AdjustButton.MouseUpCallback(self, args)
	if (not self:IsEnabled()) then
		return;
	end

	if (args.Button == Turbine.UI.MouseButton.Left) then
		self.pressed = false;
		if (self:IsMouseInside(args.X, args.Y)) then
			-- rollover
			self:SetBackground(self.baseImageID + 3);
		else
			-- default
			self:SetBackground(self.baseImageID + 2);
			return;
		end
		ExecuteCallback(self, "Action", args);
	end
end

function AdjustButton.MouseEnterCallback(self, args)
	if (not self:IsEnabled()) then
		return;
	end
	if self.pressed then
		-- pressed
		self:SetBackground(self.baseImageID + 1);
	else
		-- rollover
		self:SetBackground(self.baseImageID + 3);
	end
end

function AdjustButton.MouseLeaveCallback(self, args)
	if (not self:IsEnabled()) then
		return;
	end
	if self.pressed then
		-- rollover
		self:SetBackground(self.baseImageID + 3);
	else
		-- default
		self:SetBackground(self.baseImageID + 2);
	end
end

NumericInput = class (Turbine.UI.Control);

function NumericInput:Constructor()
	Turbine.UI.Control.Constructor(self);
	self:SetSize(90, 20);
	self.numericValue = 0;
	-- text field
	self.numBox = Turbine.UI.Lotro.TextBox();
	self.numBox:SetParent(self);
	self.numBox:SetSize(50, 20);
	self.numBox:SetPosition(20, 0);
	self.numBox:SetFont(Turbine.UI.Lotro.Font.Verdana16);
	self.numBox:SetText("0");
	self.numBox:SetMultiline(false);
	self.numBox:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleCenter);
	self.numBox.FocusLost = function(sender, args) self:UpdateValue(); end;
	self.numBox.KeyDown =
	function(sender, args)
		-- return/enter key
		if args.Action == 162 then
			self:UpdateValue();
		end
	end;

	self.leftArrow = AdjustButton(true);
	self.leftArrow:SetParent(self);
	self.leftArrow.Action = function(sender, args) self:Decrement(); end;

	self.rightArrow = AdjustButton(false);
	self.rightArrow:SetPosition(self:GetWidth() - self.rightArrow:GetWidth(), 0);
	self.rightArrow:SetParent(self);
	self.rightArrow.Action = function(sender, args) self:Increment(); end;
end

function NumericInput:SetLimits(lower, upper)
	self.lowerLimit = lower;
	self.upperLimit = upper;
end

function NumericInput:SetValue(val)
	self.numericValue = math.floor(val);
	self.numBox:SetText(tostring(self.numericValue));
end

function NumericInput:GetValue()
	return self.numericValue;
end

function NumericInput:UpdateValue()
	local val = tonumber(self.numBox:GetText());
	if (val == nil) then
		val = self.lowerLimit or 0;
	else
		-- no way to prevent float input unfortunately
		val = math.floor(val);
		if (self.lowerLimit ~= nil and val < self.lowerLimit) then
			val = self.lowerLimit;
		elseif (self.upperLimit ~= nil and val > self.upperLimit) then
			val = self.upperLimit;
		end
	end
	self.numBox:SetText(tostring(val));
	if (val ~= self.numericValue) then
		self.numericValue = val;
		ExecuteCallback(self, "ValueChanged", {Value = val});
	end
end

function NumericInput:Increment()
	local val = self.numericValue + 1;
	if (self.upperLimit ~= nil and val > self.upperLimit) then
		return;
	end
	self.numericValue = val;
	self.numBox:SetText(tostring(self.numericValue));
	ExecuteCallback(self, "ValueChanged", {Value = self.numericValue});
end

function NumericInput:Decrement()
	local val = self.numericValue - 1;
	if (self.lowerLimit ~= nil and val < self.lowerLimit) then
		return;
	end
	self.numericValue = val;
	self.numBox:SetText(tostring(self.numericValue));
	ExecuteCallback(self, "ValueChanged", {Value = self.numericValue});
end
