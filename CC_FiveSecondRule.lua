--[[
Overall goal is to create a bar that will track when the next mana tick will occur.

Start a counter upon successful cast.
	This counts down from 5 and resets when another cast completes.
Figure out which event mana regen occurs on.
	Print this in chat.
Figure out a way to do a timer
	Link the timer to see if they line up with the mana tick
	
Create a Frame that displays a 5 second countdown timer.
Create a Frame that displays 2 second ticks.

Create a window/bar that is on screen.
	Moveable
	Using xml?
	Basically just a blue bar with a tick that moves.
		Count down in seconds above or on the bar.
		
Order of operations:
	Cast spell that uses mana
		Gets the time of the cast and when 5 seconds is.
	Check the players mana to make sure they aren't full
		Show 5 second timer.
	Check to see if 5 seconds has past
		Turn off 5 second timer
		Show 2 second tick timer.
	
Options:
Change width
Change height
Moveable
Show timer
]]--

barWidth = 125
barHeight = 20

FiveSecondRule = CreateFrame("Frame", nil, PlayerFrame)
FiveSecondRule:SetWidth(barWidth)
FiveSecondRule:SetHeight(barHeight)
FiveSecondRule:SetPoint("RIGHT", 0, 50)

ManaRegenTimeFrame = CreateFrame ("StatusBar", nil, FiveSecondRule)
ManaRegenTimeFrame:SetWidth(barWidth)
ManaRegenTimeFrame:SetHeight(barHeight)
ManaRegenTimeFrame:SetPoint("LEFT", 0, 0)
ManaRegenTimeFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar.blp")
ManaRegenTimeFrame:SetStatusBarColor(0, 0, 1)
ManaRegenTimeFrame.bg = ManaRegenTimeFrame:CreateTexture(nil, "BACKGROUND")
ManaRegenTimeFrame.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
ManaRegenTimeFrame.bg:SetAllPoints(true)
ManaRegenTimeFrame.bg:SetVertexColor(0, 1, 0, 0.5)
ManaRegenTimeFrame:SetMinMaxValues(0, 5)

ManaRegenTimeFrame.value = ManaRegenTimeFrame:CreateFontString(nil, "OVERLAY")
ManaRegenTimeFrame.value:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
ManaRegenTimeFrame.value:SetJustifyH("LEFT")
ManaRegenTimeFrame.value:SetTextColor(1, 1, 1, 1)
ManaRegenTimeFrame.value:SetPoint("LEFT", ManaRegenTimeFrame, "LEFT", 4, 0)


ManaTickTimeFrame = CreateFrame ("StatusBar", nil, FiveSecondRule)
ManaTickTimeFrame:SetWidth(barWidth)
ManaTickTimeFrame:SetHeight(barHeight)
ManaTickTimeFrame:SetPoint("LEFT", 0, 0)
ManaTickTimeFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar.blp")
ManaTickTimeFrame:SetStatusBarColor(.85, .85, .85)
ManaTickTimeFrame.bg = ManaTickTimeFrame:CreateTexture(nil, "BACKGROUND")
ManaTickTimeFrame.bg:SetTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
ManaTickTimeFrame.bg:SetAllPoints(true)
ManaTickTimeFrame.bg:SetVertexColor(.5, .5, .5, 0.5)
ManaTickTimeFrame:SetMinMaxValues(0, 2)

ManaTickTimeFrame.value = ManaTickTimeFrame:CreateFontString(nil, "OVERLAY")
ManaTickTimeFrame.value:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
ManaTickTimeFrame.value:SetJustifyH("LEFT")
ManaTickTimeFrame.value:SetTextColor(1, 1, 1, 1)
ManaTickTimeFrame.value:SetPoint("LEFT", ManaTickTimeFrame, "LEFT", 4, 0)


fullMana = true;
regenMana = false;
startRegenTimer = 0;
tickTimer = 0;

function showRegenTimerFrame()
	ManaTickTimeFrame:Hide()
	ManaRegenTimeFrame:Show()
end

function showTickTimerFrame()
	regenMana = true
	ManaRegenTimeFrame:Hide()
	ManaTickTimeFrame:Show()
end

	
function onEvent(self, event, ...)
	
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...;
		local powerCost = GetSpellPowerCost(spellID)
		for _, costInfo in pairs  (powerCost) do
			if costInfo.type == 0 then
				startRegenTimer = GetTime() + 5;
				showRegenTimerFrame()
			end
		end
	end
	
	if event == "UNIT_POWER_UPDATE" then
		local unitTarget, powerType = ...;
		if (unitTarget == "player" and powerType == "MANA") then
			if (fullMana == false and regenMana == true) then
				tickTimer = GetTime() + 2
			end
		end
	end
	
	if event == "ADDONS_LOADED" then
		ManaTickTimeFrame:Hide()
		ManaRegenTimeFrame:Hide()
	end
	
	if event == "VARIABLES_LOADED" then
		FiveSecondOnLoad(self)
	end
end

function onUpdate(self)
	local currentMana = UnitPower("player", 0)
	local maxMana = UnitPowerMax("player", 0)
	if (currentMana < maxMana) then
		fullMana = false;
	else 
		ManaTickTimeFrame:Hide()
		regenMana = false;
		fullMana = true;
	end
	
	if (fullMana == false) then
		currentTime = GetTime();
		if (startRegenTimer >  0) then
			remainingTime = startRegenTimer - currentTime
			if (remainingTime >= 0) then
				ManaRegenTimeFrame:SetValue(remainingTime)
				ManaRegenTimeFrame.value:SetText(string.format("%.1f", remainingTime).."s")
			else
				showTickTimerFrame()
				startRegenTimer = 0
				tickTimer = 2
			end
		end
		if (tickTimer > 0) then
			remainingTime = tickTimer - currentTime
			if (remainingTime >= 0) then
				ManaTickTimeFrame:SetValue(remainingTime)
				ManaTickTimeFrame.value:SetText(string.format("%.1f", remainingTime).."s")
			end
		end
	end
end	

-- Load events
function FiveSecondOnLoad(self)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_POWER_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
	
	ManaRegenTimeFrame:Hide()
	ManaTickTimeFrame:Hide()
end

FiveSecondRule:RegisterEvent("VARIABLES_LOADED")
FiveSecondRule:SetScript("OnEvent", onEvent);
FiveSecondRule:SetScript("OnUpdate", onUpdate);





