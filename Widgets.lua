local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy2")

function Spy2:CreateFrame(Name, Title, Height, Width, ShowFunc, HideFunc)
	local theFrame = CreateFrame("Frame", Name, UIParent)

	theFrame:ClearAllPoints()
	theFrame:SetPoint("CENTER", UIParent)
	theFrame:SetHeight(Height)
	theFrame:SetWidth(Width)
	-- the window has no background and is sized to its bars, so it has no clickable area of its
	-- own. There is nothing to grab on the frame itself; the move is initiated from the rows
	-- (Ctrl + left-drag, see CreateRow). SetMovable stays because those rows call StartMoving on
	-- this frame.
	theFrame:SetMovable(true)

	theFrame.ShowFunc = ShowFunc
	theFrame:SetScript("OnShow", function(self)
		Spy2:SetWindowTop(self)
		if self.ShowFunc then
			self:ShowFunc()
		end
	end)
	theFrame.HideFunc = HideFunc
	theFrame:SetScript("OnHide", function(self)
		if self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
		end
		if self.HideFunc then
			self:HideFunc()
		end
	end)

	-- no backdrop: the window is the bars only, nothing rendered behind them

	-- a hidden Title is kept only so ResizeMainWindow can size it; the window shows no title text
	theFrame.Title = theFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	theFrame.Title:SetPoint("TOPLEFT", theFrame, "TOPLEFT", 8, -2)
	theFrame.Title:SetHeight(Spy2.db.profile.MainWindow.TextHeight)
	theFrame.Title:Hide()

	return theFrame
end
