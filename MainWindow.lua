local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy2")

--++ Local FrameFlash functions derived from Blizzard code ++--
local SpyFrameFlashManager = CreateFrame("FRAME");
local SPYFADEFRAMES = {};
local SPYFLASHFRAMES = {};
local SpyFrameFlashTimers = {};
local SpyFrameFlashTimerRefCount = {};

-- Fucntion to see if a frame is fading
function SpyFrameIsFading(frame)
	for index, value in pairs(SPYFADEFRAMES) do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to stop flashing --
local function SpyFrameFlashStop(frame)
    tDeleteItem(SPYFLASHFRAMES, frame);
    frame:SetAlpha(1.0);
    frame.flashTimer = nil;
    if (frame.syncId) then
        SpyFrameFlashTimerRefCount[frame.syncId] = SpyFrameFlashTimerRefCount[frame.syncId]-1;
        if (SpyFrameFlashTimerRefCount[frame.syncId] == 0) then
            SpyFrameFlashTimers[frame.syncId] = nil;
            SpyFrameFlashTimerRefCount[frame.syncId] = nil;
        end
        frame.syncId = nil;
    end
    if ( frame.showWhenDone ) then
        frame:Show();
    else
        frame:Hide();
    end
end

-- Call every frame to update flashing frames  --
local function SpyFrameFlash_OnUpdate(self, elapsed)
    local frame;
    local index = #SPYFLASHFRAMES;
     
    -- Update timers for all synced frames
    for syncId, timer in pairs(SpyFrameFlashTimers) do
        SpyFrameFlashTimers[syncId] = timer + elapsed;
    end
     
    while SPYFLASHFRAMES[index] do
        frame = SPYFLASHFRAMES[index];
        frame.flashTimer = frame.flashTimer + elapsed;
        if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
            SpyFrameFlashStop(frame);
        else
            local flashTime = frame.flashTimer;
            local alpha;
            if (frame.syncId) then
                flashTime = SpyFrameFlashTimers[frame.syncId];
            end
            flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0));
            if (flashTime < frame.fadeInTime) then
                alpha = flashTime/frame.fadeInTime;
            elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)) then
                alpha = 1;
            elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime) then
                alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime);
            else
                alpha = 0;
            end
            frame:SetAlpha(alpha);
            frame:Show();
        end
        -- Loop in reverse so that removing frames is safe
        index = index - 1;
    end
    if ( #SPYFLASHFRAMES == 0 ) then
        self:SetScript("OnUpdate", nil);
    end
end

-- Function to start a frame flashing
local function SpyFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
    if ( frame ) then
        local index = 1;
        -- If frame is already set to flash then return
        while SPYFLASHFRAMES[index] do		
            if ( SPYFLASHFRAMES[index] == frame ) then
                return;
            end
            index = index + 1;
        end
        if (syncId) then
            frame.syncId = syncId;
            if (SpyFrameFlashTimers[syncId] == nil) then
                SpyFrameFlashTimers[syncId] = 0;
                SpyFrameFlashTimerRefCount[syncId] = 0;
            end
            SpyFrameFlashTimerRefCount[syncId] = SpyFrameFlashTimerRefCount[syncId]+1;
        else
            frame.syncId = nil;
        end
        -- Time it takes to fade in a flashing frame
        frame.fadeInTime = fadeInTime;
        -- Time it takes to fade out a flashing frame
        frame.fadeOutTime = fadeOutTime;
        -- How long to keep the frame flashing
        frame.flashDuration = flashDuration;
        -- Show the flashing frame when the fadeOutTime has passed
        frame.showWhenDone = showWhenDone;
        -- Internal timer
        frame.flashTimer = 0;
        -- How long to hold the faded in state
        frame.flashInHoldTime = flashInHoldTime;
        -- How long to hold the faded out state
        frame.flashOutHoldTime = flashOutHoldTime;
         
        tinsert(SPYFLASHFRAMES, frame);		
         
       SpyFrameFlashManager:SetScript("OnUpdate", SpyFrameFlash_OnUpdate);
    end
end

function Spy2:SetFontSize(string, size)
	local Font, Height, Flags = string:GetFont()
	string:SetFont(Font, size, Flags)
end

-- watches for the left button coming up while the window is being moved. a row's own OnMouseUp
-- can miss the release: ClampToScreen pins the frame at the screen edge while the cursor keeps
-- going, so the mouse-up lands off the rows. polling the button here catches the release wherever
-- the cursor is and writes the position. only runs while a move is in progress.
local function WatchMainWindowMove(frame)
	if not IsMouseButtonDown("LeftButton") then
		frame:StopMovingOrSizing()
		frame.isMoving = false
		frame:SetScript("OnUpdate", nil)
		Spy2:SaveMainWindowPosition()
	end
end

function Spy2:CreateRow(num)
	if num < 1 or Spy2.MainWindow.Rows[num] then
		return
	end

	local row = CreateFrame("Button", "Spy2_MainWindow_Bar"..num, Spy2.MainWindow, "Spy2SecureActionButtonTemplate")
	row:SetPoint("TOPLEFT", Spy2.MainWindow, "TOPLEFT", 0, -(Spy2.db.profile.MainWindow.RowHeight + Spy2.db.profile.MainWindow.RowSpacing) * (num - 1))
	row:SetHeight(Spy2.db.profile.MainWindow.RowHeight)
	row:SetWidth(Spy2.MainWindow:GetWidth())

	row.id = num
	Spy2:SetupBar(row)
	Spy2.MainWindow.Rows[num] = row
	-- start blank and click-through; rows are kept shown (ManageBarsDisplayed) and RefreshList fills
	-- only the ones with an enemy, so an unfilled row must read as not there from the first frame.
	Spy2:BlankRow(num)
	row:EnableMouse(false)

	-- the rows cover the whole window, so a Ctrl-drag to move it has to start on a row, not the
	-- bare frame. Ctrl + left-drag on any row moves the window; a plain left-click still targets
	-- the player through the secure macro. the release is detected by WatchMainWindowMove rather
	-- than this row's OnMouseUp, which can miss it when the frame is clamped at a screen edge.
	-- the window parents the secure row buttons, so StartMoving on it is a protected action and is
	-- blocked in combat; the move is gated on InCombatLockdown so the Ctrl-drag is a no-op there.
	row:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and IsControlKeyDown() and not InCombatLockdown() then
			Spy2:SetWindowTop(Spy2.MainWindow)
			Spy2.MainWindow:StartMoving()
			Spy2.MainWindow.isMoving = true
			Spy2.MainWindow:SetScript("OnUpdate", WatchMainWindowMove)
		end
	end)
end

-- A 1px black edge texture anchored to two corners of the bar. Pass width for a vertical edge or
-- height for a horizontal one; the other dimension comes from the two anchor points.
local function AddBarEdge(parent, p1, p2, width, height)
	local edge = parent:CreateTexture(nil, "OVERLAY")
	edge:SetColorTexture(0, 0, 0, 1)
	edge:SetPoint(p1, parent, p1, 0, 0)
	edge:SetPoint(p2, parent, p2, 0, 0)
	if width then edge:SetWidth(width) end
	if height then edge:SetHeight(height) end
	return edge
end

-- Fades a row's outline edges in or out. SetAlpha on a texture is allowed in combat, so an empty row
-- can be made fully invisible (alpha 0) and a filled one outlined (alpha 1) on any refresh.
local function SetRowBordersShown(row, shown)
	local a = shown and 1 or 0
	local bar = row.StatusBar
	if bar.BorderBottom then bar.BorderBottom:SetAlpha(a) end
	if bar.BorderLeft then bar.BorderLeft:SetAlpha(a) end
	if bar.BorderRight then bar.BorderRight:SetAlpha(a) end
	if bar.BorderTop then bar.BorderTop:SetAlpha(a) end
end

function Spy2:SetupBar(row)
	row.StatusBar = CreateFrame("StatusBar", nil, row)
	row.StatusBar:SetAllPoints(row)

	local BarTexture = Spy2.db.profile.BarTexture
	BarTexture = SM:Fetch("statusbar", BarTexture or "Blizzard")
	row.StatusBar:SetStatusBarTexture(BarTexture)
	row.StatusBar:SetStatusBarColor(.5, .5, .5, 0.8)
	row.StatusBar:SetMinMaxValues(0, 100)
	row.StatusBar:SetValue(100)
	row.StatusBar:Show()

	-- 1px black outline around the bar so adjacent players read as separate rows. interior rows draw
	-- no top edge: with RowSpacing 0 the rows sit flush, so a top edge would stack against the bottom
	-- edge of the row above and read as a 2px separator. row 1 is the physical top of the stack with
	-- nothing above it, so it carries the top edge of the whole list.
	local bar = row.StatusBar
	bar.BorderBottom = AddBarEdge(bar, "BOTTOMLEFT", "BOTTOMRIGHT", nil, 1)
	bar.BorderLeft = AddBarEdge(bar, "TOPLEFT", "BOTTOMLEFT", 1, nil)
	bar.BorderRight = AddBarEdge(bar, "TOPRIGHT", "BOTTOMRIGHT", 1, nil)
	if row.id == 1 then
		bar.BorderTop = AddBarEdge(bar, "TOPLEFT", "TOPRIGHT", nil, 1)
	end

	row.LeftText = row.StatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.LeftText:SetPoint("LEFT", row.StatusBar, "LEFT", 2, 0)
	row.LeftText:SetJustifyH("LEFT")
	row.LeftText:SetHeight(Spy2.db.profile.MainWindow.TextHeight)
	row.LeftText:SetTextColor(1, 1, 1, 1)
	-- thin 1px shadow for edge definition; the bar itself is darkened in SetBar so white text reads
	row.LeftText:SetShadowColor(0, 0, 0, 1)
	row.LeftText:SetShadowOffset(1, -1)
	Spy2:SetFontSize(row.LeftText, math.max(Spy2.db.profile.MainWindow.RowHeight * 0.75, Spy2.db.profile.MainWindow.RowHeight - 3))

	row.RightText = row.StatusBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	row.RightText:SetPoint("RIGHT", row.StatusBar, "RIGHT", -2, 0)
	row.RightText:SetJustifyH("RIGHT")
	row.RightText:SetTextColor(1, 1, 1, 1)
	row.RightText:SetShadowColor(0, 0, 0, 1)
	row.RightText:SetShadowOffset(1, -1)
	Spy2:SetFontSize(row.RightText, math.max(Spy2.db.profile.MainWindow.RowHeight * 0.65, Spy2.db.profile.MainWindow.RowHeight - 12))

	Spy2.Colors:RegisterFont("Bar", "Bar Text", row.LeftText)
	Spy2.Colors:RegisterFont("Bar", "Bar Text", row.RightText)
end

function Spy2:UpdateBarTextures()
	local Texture = SM:Fetch(SM.MediaType.STATUSBAR, Spy2.db.profile.BarTexture)
	for k, v in pairs(Spy2.MainWindow.Rows) do
		v.StatusBar:SetStatusBarTexture(Texture)
	end
end

function Spy2:SetBarTextures(handle)
	Spy2.db.profile.BarTexture = handle
	Spy2:UpdateBarTextures()
end

function Spy2:CreateMainWindow()
	if not Spy2.MainWindow then
		Spy2.MainWindow = Spy2:CreateFrame("Spy2_MainWindow", "", 34, 200,
		function()
			Spy2.db.profile.MainWindowVis = true
		end,
		function()
			Spy2.db.profile.MainWindowVis = false
		end)

		Spy2:UpdateMainWindow()

		local theFrame = Spy2.MainWindow
		-- the window width is set from the Window width slider; height tracks the bar count. there is
		-- no mouse resizing, so the window cannot be resized by an accidental edge drag.
		theFrame:SetMovable(true)

		-- count of nearby enemies above the top-right corner. it is a label only (no mouse), so it
		-- never starts the Ctrl-drag move handled by the rows, and its value can exceed the row limit.
		theFrame.Counter = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		theFrame.Counter:SetPoint("BOTTOMRIGHT", theFrame, "TOPRIGHT", -4, 1)
		theFrame.Counter:SetJustifyH("RIGHT")
		theFrame.Counter:SetTextColor(1, 0.82, 0, 1)
		Spy2:SetFontSize(theFrame.Counter, Spy2.db.profile.MainWindow.TextHeight)

		Spy2.MainWindow.Rows = {}
		Spy2.MainWindow.CurRows = 0

		for i = 1, Spy2.ButtonLimit do
			Spy2:CreateRow(i)
		end

		-- scale must be applied before the position restore: SaveMainWindowPosition stores
		-- GetLeft/GetTop in the frame's scaled coordinate space, so the anchor offsets only line
		-- up if the frame is already at that scale when SetPoint runs.
		Spy2.MainWindow:SetScale(Spy2.db.profile.Scaling)
		Spy2:RestoreMainWindowPosition(Spy2.db.profile.MainWindow.Position.x, Spy2.db.profile.MainWindow.Position.y, Spy2.db.profile.MainWindow.Position.w, 34)
		Spy2:ResizeMainWindow()
		Spy2:ScheduleRepeatingTimer("ManageExpirations", 10, true)
		Spy2:InitOrder()
	end

	if not Spy2.AlertWindow then
		Spy2.AlertWindow = CreateFrame("Frame", "Spy2_AlertWindow", UIParent, "BackdropTemplate")
		Spy2.AlertWindow:ClearAllPoints()
		Spy2.AlertWindow:SetClampedToScreen(true)
		Spy2:UpdateAlertWindow()
		Spy2.AlertWindow:SetHeight(42)
		Spy2.AlertWindow:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 8, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
			insets = { left = 2, right = 2, top = 2, bottom = 2 },
		})
		Spy2.Colors:RegisterBackground("Alert", "Background", Spy2.AlertWindow)

		Spy2.AlertWindow.Icon = CreateFrame("Frame", nil, Spy2.AlertWindow, "BackdropTemplate")
		Spy2.AlertWindow.Icon:ClearAllPoints()
		Spy2.AlertWindow.Icon:SetPoint("TOPLEFT", Spy2.AlertWindow, "TOPLEFT", 6, -5)
		Spy2.AlertWindow.Icon:SetWidth(32)
		Spy2.AlertWindow.Icon:SetHeight(32)

		Spy2.AlertWindow.Title = Spy2.AlertWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		Spy2.AlertWindow.Title:SetPoint("TOPLEFT", Spy2.AlertWindow, "TOPLEFT", 42, -3)
		Spy2.AlertWindow.Title:SetHeight(Spy2.db.profile.MainWindow.TextHeight)

		Spy2.AlertWindow.Name = Spy2.AlertWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		Spy2.AlertWindow.Name:SetPoint("TOPLEFT", Spy2.AlertWindow, "TOPLEFT", 42, -15)
		Spy2.AlertWindow.Name:SetHeight(Spy2.db.profile.MainWindow.TextHeight)
		Spy2:SetFontSize(Spy2.AlertWindow.Name, Spy2.db.profile.AlertWindow.NameSize)

		Spy2.AlertWindow.Location = Spy2.AlertWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		Spy2.AlertWindow.Location:SetPoint("TOPLEFT", Spy2.AlertWindow, "TOPLEFT", 42, -26)
		Spy2.AlertWindow.Location:SetHeight(Spy2.db.profile.MainWindow.TextHeight)
		Spy2:SetFontSize(Spy2.AlertWindow.Location, Spy2.db.profile.AlertWindow.LocationSize)

		Spy2.AlertWindow:Hide()
	end

	Spy2:ManageExpirations()
	Spy2:RefreshList()
end

function Spy2:SetBar(num, name, desc, value, colorgroup, colorclass, tooltipData, opacity)
	if num < 1 or not Spy2.MainWindow.Rows[num] then
		return
	end

	local Row = Spy2.MainWindow.Rows[num]
	Row.StatusBar:SetValue(value)
	Row.LeftText:SetText(Spy2:DisplayName(name))
	Row.RightText:SetText(desc)
	Row.Name = name
	Row.TooltipData = tooltipData
	Row.LeftText:SetWidth(Row:GetWidth() - Row.RightText:GetStringWidth() - 4)

	if colorgroup and colorclass and type(colorclass) == "string" then
		Spy2.Colors:UnregisterItem(Row.StatusBar)
		-- scale the class color down so the white row text always contrasts against it. the hue is
		-- kept (all three channels scaled equally), so classes stay distinguishable, just darker.
		local Multi = { r = 0.5, g = 0.5, b = 0.5, a = opacity }
		Spy2.Colors:RegisterTexture(colorgroup, colorclass, Row.StatusBar, Multi)
	end

	Row.LeftText:SetTextColor(Spy2.db.profile.Colors.Bar["Bar Text"].r, Spy2.db.profile.Colors.Bar["Bar Text"].g, Spy2.db.profile.Colors.Bar["Bar Text"].b, opacity)
	Row.RightText:SetTextColor(Spy2.db.profile.Colors.Bar["Bar Text"].r, Spy2.db.profile.Colors.Bar["Bar Text"].g, Spy2.db.profile.Colors.Bar["Bar Text"].b, opacity)
	SetRowBordersShown(Row, true)
end

-- Empties a row in place: zero fill, no text, no outline. The row frame stays shown (showing/hiding is
-- blocked in combat), but with nothing drawn and no backdrop behind it the slot reads as not there.
-- Only value/text/alpha change here, all allowed in combat, so a blanked row can be refilled mid-fight.
function Spy2:BlankRow(num)
	local Row = Spy2.MainWindow.Rows[num]
	if not Row then
		return
	end
	Row.StatusBar:SetValue(0)
	Row.LeftText:SetText("")
	Row.RightText:SetText("")
	Row.Name = nil
	Row.TooltipData = nil
	SetRowBordersShown(Row, false)
end

function Spy2:AutomaticallyResize()
	local detected = Spy2.ListAmountDisplayed
	if detected > Spy2.db.profile.ResizeSpyLimit then detected = Spy2.db.profile.ResizeSpyLimit end
	Spy2.MainWindow.CurRows = detected

	-- height is exactly the stacked bars: N rows plus the gaps between them, nothing more. with
	-- no bars the window collapses to a hairline and stays shown, so it never has to be toggled.
	local height
	if detected == 0 then
		height = 0.001
	else
		height = detected * Spy2.db.profile.MainWindow.RowHeight + (detected - 1) * Spy2.db.profile.MainWindow.RowSpacing
	end
	-- only the height changes here. the window keeps the anchor set at restore (TOPLEFT, or
	-- BOTTOMLEFT when inverted), so it grows downward (or upward) from a fixed edge. re-deriving the
	-- anchor from a live GetTop/GetBottom would bake in any ClampToScreen shift and creep the window
	-- across refreshes; the anchored edge is read only from the saved position, never from geometry.
	if not InCombatLockdown() then
		Spy2.MainWindow:SetHeight(height)
	end
end

function Spy2:ManageBarsDisplayed()
	local bars = Spy2.ListAmountDisplayed
	if bars > Spy2.db.profile.ResizeSpyLimit then
		bars = Spy2.db.profile.ResizeSpyLimit
	end
	Spy2.MainWindow.CurRows = bars

	-- every row is kept shown so an enemy first seen in combat -- when Show is blocked on the secure
	-- rows -- lands on a row already on screen. RefreshList blanks the unused rows (invisible, no
	-- outline) and mouse-disables them so they add no bar and pass clicks through. only the showing
	-- happens here, out of combat, where it is allowed.
	if not InCombatLockdown() then
		for i, row in pairs(Spy2.MainWindow.Rows) do
			row:Show()
		end
	end
end

function Spy2:ResizeMainWindow()
	local CurWidth = Spy2.MainWindow:GetWidth()
	Spy2.MainWindow.Title:SetWidth(CurWidth)
	for i,row in pairs(Spy2.MainWindow.Rows) do
		row:SetWidth(CurWidth)
	end

	Spy2:ManageBarsDisplayed()
end

function Spy2:SaveMainWindowPosition()
	Spy2.db.profile.MainWindow.Position.x = Spy2.MainWindow:GetLeft()
	if not Spy2.db.profile.InvertSpy then 
		Spy2.db.profile.MainWindow.Position.y = Spy2.MainWindow:GetTop()
    else 
		Spy2.db.profile.MainWindow.Position.y = Spy2.MainWindow:GetBottom()
    end
	Spy2.db.profile.MainWindow.Position.w = Spy2.MainWindow:GetWidth()
	Spy2.db.profile.MainWindow.Position.h = Spy2.MainWindow:GetHeight()
end

function Spy2:RestoreMainWindowPosition(x, y, width, height)
	-- callers re-anchor from GetLeft/GetTop, which return nil before the frame's layout is resolved
	-- (during load, prior to the first screen draw). fall back to the saved position so an early
	-- resize pass cannot lose it; only center when nothing has ever been saved.
	local pos = Spy2.db.profile.MainWindow.Position
	if not x then x = pos.x end
	if not y then y = pos.y end
	if not width then width = pos.w end
	Spy2.MainWindow:ClearAllPoints()
	if not x or not y then
		-- no saved position yet: open centered on screen
		Spy2.MainWindow:SetPoint("CENTER", UIParent)
	elseif not Spy2.db.profile.InvertSpy then
		Spy2.MainWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
	else
		Spy2.MainWindow:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
	Spy2.MainWindow:SetWidth(width)
	for i,row in pairs(Spy2.MainWindow.Rows) do
		row:SetWidth(width)
	end
	Spy2.MainWindow:SetHeight(height)
end

function Spy2:SaveAlertWindowPosition()
	Spy2.db.profile.AlertWindow.Position.x = Spy2.AlertWindow:GetLeft()
	Spy2.db.profile.AlertWindow.Position.y = Spy2.AlertWindow:GetTop()
end

function Spy2:RestoreAlertWindowPosition(x, y)
	Spy2.AlertWindow:ClearAllPoints()
	Spy2.AlertWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

function Spy2:UpdateMainWindow()
	if Spy2.InInstance then
		Spy2.MainWindow:SetAlpha(Spy2.db.profile.MainWindow.AlphaBG)
	else	
		Spy2.MainWindow:SetAlpha(Spy2.db.profile.MainWindow.Alpha)
	end	
end

function Spy2:UpdateAlertWindow()
	if Spy2.db.profile.DisplayWarnings == "Moveable" then
		Spy2.AlertWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Spy2.db.profile.AlertWindow.Position.x, Spy2.db.profile.AlertWindow.Position.y)
		Spy2.AlertWindow:SetMovable(true)
		Spy2.AlertWindow:EnableMouse(true)
		Spy2.AlertWindow:SetScript("OnMouseDown", function(self, button) 
			Spy2.AlertWindow:StartMoving();
			Spy2.AlertWindow.isMoving = true;
		end)
		Spy2.AlertWindow:SetScript("OnMouseUp", function(self) 
			if (Spy2.AlertWindow.isMoving) then
				Spy2.AlertWindow:StopMovingOrSizing();
				Spy2.AlertWindow.isMoving = false;
				Spy2:SaveAlertWindowPosition()
			end
		end)
	else
		Spy2.AlertWindow:ClearAllPoints()	
		Spy2.AlertWindow:SetPoint("TOP", UIParent, "TOP", 0, -140)
	end		
end	

function Spy2:ShowTooltip(self, show, id)
	if show then
		local name = Spy2.ButtonName[self.id]
		if name and name ~= "" then
			local titleText = Spy2.db.profile.Colors.Tooltip["Title Text"]

			if not Spy2.db.profile.DisplayTooltipNearSpyWindow then
				GameTooltip:SetOwner(Spy2.MainWindow, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y)
			else
				GameTooltip:SetOwner(self, Spy2.db.profile.TooltipAnchor)
			end
			GameTooltip:ClearLines()
			GameTooltip:AddLine(string.gsub(Spy2:DisplayName(name), "%-", " - "), titleText.r, titleText.g, titleText.b)

			local playerData = Spy2.PlayerData[name]
			if playerData then
				local detailsText = Spy2.db.profile.Colors.Tooltip["Details Text"]
				if playerData.guild and playerData.guild ~= "" then
					GameTooltip:AddLine(playerData.guild, detailsText.r, detailsText.g, detailsText.b)
				end

				local details = ""
				if playerData.level then details = L["Level"].." "..playerData.level.." " end
				if playerData.race then details = details..playerData.race.." " end
				if playerData.class then details = details..L[playerData.class] end
				if details ~= "" then
					GameTooltip:AddLine(details..L["Player"], detailsText.r, detailsText.g, detailsText.b)
				end

				if Spy2.db.profile.DisplayLastSeen then
					local locationText = Spy2.db.profile.Colors.Tooltip["Location Text"]
					if playerData.time then
						local lastSeen = L["LastSeen"]
						local minutes = math.floor((time() - playerData.time) / 60)
						local hours = math.floor(minutes / 60)
						if minutes <= 0 then
							lastSeen = lastSeen.." "..L["LessThanOneMinuteAgo"]
						elseif minutes > 0 and minutes < 60 then
							lastSeen = lastSeen.." "..minutes.." "..L["MinutesAgo"]
						elseif hours > 0 and hours < 24 then
							lastSeen = lastSeen.." "..hours.." "..L["HoursAgo"]
						else
							local days = math.floor(hours / 24)
							lastSeen = lastSeen.." "..days.." "..L["DaysAgo"]
						end
						GameTooltip:AddLine(lastSeen, locationText.r, locationText.g, locationText.b)
					end
					GameTooltip:AddLine(Spy2:GetPlayerLocation(playerData), locationText.r, locationText.g, locationText.b)
				end
			end

			GameTooltip:Show()
		end
	else
		GameTooltip:Hide()
	end
end

function Spy2:ShowAlert(type, name, source, location)
	if type == "stealth" or type == "prowl" then
		Spy2.Colors:RegisterBorder("Alert", "Stealth Border", Spy2.AlertWindow)
		if type == "stealth" then
			Spy2.AlertWindow.Icon:SetBackdrop({ bgFile = "Interface\\Icons\\Ability_Stealth" })
		else
			Spy2.AlertWindow.Icon:SetBackdrop({ bgFile = "Interface\\Icons\\Ability_Ambush" })
		end
		Spy2.Colors:RegisterBorder("Alert", "Background", Spy2.AlertWindow.Icon)
		Spy2.Colors:RegisterBackground("Alert", "Icon", Spy2.AlertWindow.Icon)
		Spy2.Colors:RegisterFont("Alert", "Stealth Text", Spy2.AlertWindow.Title)
		Spy2.AlertWindow.Title:SetText(L["AlertStealthTitle"])
		Spy2.Colors:RegisterFont("Alert", "Name Text", Spy2.AlertWindow.Name)
		Spy2.AlertWindow.Name:SetText(name)
		Spy2.AlertWindow.Location:SetText("")
		if (Spy2.AlertWindow.Title:GetStringWidth() < Spy2.AlertWindow.Name:GetStringWidth()) then
			Spy2.AlertWindow:SetWidth(Spy2.AlertWindow.Name:GetStringWidth() + 52)
		else
			Spy2.AlertWindow:SetWidth(Spy2.AlertWindow.Title:GetStringWidth() + 52)
		end

		SpyFrameFlashStop(Spy2.AlertWindow)
		SpyFrameFlash(Spy2.AlertWindow, 0, 1, 5, false, 4, 0)
	end
	Spy2.AlertWindow.Name:SetWidth(Spy2.AlertWindow:GetWidth() - 52)
	Spy2.AlertWindow.Location:SetWidth(Spy2.AlertWindow:GetWidth() - 52)
end

function Spy2:BarsChanged()  
	for k, v in pairs(Spy2.MainWindow.Rows) do
		v:SetHeight(Spy2.db.profile.MainWindow.RowHeight)
		v:SetPoint("TOPLEFT", Spy2.MainWindow, "TOPLEFT", 0, -(Spy2.db.profile.MainWindow.RowHeight + Spy2.db.profile.MainWindow.RowSpacing) * (k - 1))
		Spy2:SetFontSize(v.LeftText, math.max(Spy2.db.profile.MainWindow.RowHeight * 0.75, Spy2.db.profile.MainWindow.RowHeight - 3))
		Spy2:SetFontSize(v.RightText, math.max(Spy2.db.profile.MainWindow.RowHeight * 0.5, Spy2.db.profile.MainWindow.RowHeight - 12))
	end
	Spy2:ResizeMainWindow()
end
