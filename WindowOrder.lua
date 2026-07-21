local TopWindow
local AllWindows = {}

function Spy2:SetLevel(frame, level)
	frame:SetFrameLevel(level)
end

function Spy2:InitOrder()
	TopWindow = UIParent
	Spy2:AddWindow(Spy2.MainWindow)
end

function Spy2:SetWindowTop(window)
	if InCombatLockdown() then
		return
	end
	local Check = window.Above

	while Check ~= nil do
		window.Above = Check.Above
		Check.Above = window

		Check.Below = window.Below
		window.Below = Check

		Check.Below.Above = Check

		Spy2:SetLevel(Check, Check.Below:GetFrameLevel() + 10)
		Check = window.Above
	end
	Spy2:SetLevel(window, window.Below:GetFrameLevel() + 10)
	TopWindow = window
end

function Spy2:AddWindow(window)
	window.Below = TopWindow
	TopWindow.Above = window
	window.Above = nil

	Spy2:SetLevel(window, TopWindow:GetFrameLevel() + 10)
	TopWindow = window

	AllWindows[#AllWindows + 1] = window
end

function Spy2:ResetPositionAllWindows()
	for k, v in pairs(AllWindows) do
		v:ClearAllPoints()
		v:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

function Spy2:ClampToScreen()
	for k, v in pairs(AllWindows) do
		v:SetClampedToScreen(Spy2.db.profile.ClampToScreen)
	end
end