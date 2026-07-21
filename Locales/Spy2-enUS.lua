local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Spy2", "enUS", true)
if not L then return end

-- Configuration
L["Spy2"] = "Spy2"
L["Spy2 Option"] = "Spy2"
L["Profiles"] = "Profiles"

-- Information
L["About"] = "About"
L["SpyDescription1"] = [[
Spy2 detects nearby enemy players and lists them in a minimal, transparent window. The list persists until you clear it; players age off if they are not detected again for a while.

]]

L["SpyDescription2"] = [[
|cffffd000Targeting|r
|cffffd000Left-click|r a player to target them.

|cffffd000Clearing the list|r
|cffffd000Right-click|r any player in the list to clear it (when the right-click-to-clear option is enabled).

|cffffd000Moving the window|r
Hold |cffffd000Ctrl|r and drag the window to move it.
]]

L["SpyDescription3"] = [[
|cffffd000 Author:|cffffffff EinBaum

Based on Spy by Immolation / Slipjack.
]]

-- New options
L["RightClickClear"] = "Right-click to clear list"
L["RightClickClearDescription"] = "When enabled, right-clicking any player in the list clears the entire nearby list."
L["Scaling"] = "Window scale"
L["ScalingDescription"] = "Scales the Spy2 window."

-- General Settings
L["GeneralSettings"] = "General Settings"
L["GeneralSettingsDescription"] = [[
Options for when Spy2 is Enabled or Disabled.
]]
L["EnabledInBattlegrounds"] = "Enable Spy2 in battlegrounds"
L["EnabledInBattlegroundsDescription"] = "Enables or disables Spy2 when you are in a battleground."
L["DisableWhenPVPUnflagged"] = "Enable Spy2 only when flagged for PvP"
L["DisableWhenPVPUnflaggedDescription"] = "When enabled, Spy2 detects only while you are flagged for PvP."
L["DisabledInZones"] = "Disable Spy2 while in these locations"
L["DisabledInZonesDescription"]	= "Select locations where Spy2 will be disabled"
L["Booty Bay"] = "Booty Bay"
L["Everlook"] = "Everlook"
L["Gadgetzan"] = "Gadgetzan"
L["Ratchet"] = "Ratchet"
L["The Salty Sailor Tavern"] = "The Salty Sailor Tavern"
L["Cenarion Hold"] = "Cenarion Hold"

-- Display
L["DisplayOptions"] = "Display"
L["DisplayOptionsDescription"] = [[
Options for the Spy2 window and tooltips.
]]
L["Alpha"] = "Transparency"
L["AlphaDescription"] = "Set the transparency of the Spy2 window."
L["AlphaBG"] = "Transparency in BGs"
L["AlphaBGDescription"] = "Set the transparency of the Spy2 window in battlegrounds."
L["ClampToScreen"] = "Clamp to Screen"
L["ClampToScreenDescription"] = "Controls whether the Spy2 window can be dragged off screen."
L["InvertSpy"] = "Invert the Spy2 window"
L["InvertSpyDescription"] = "Flips the Spy2 window upside down."
L["Reload"] = "Reload UI"
L["ReloadDescription"] = "Required when changing the Spy2 window."
L["ResizeSpyLimit"] = "List Limit"
L["ResizeSpyLimitDescription"] = "Limit the number of enemy players shown in the Spy2 window."
L["WindowWidth"] = "Window width"
L["WindowWidthDescription"] = "Set the width of the Spy2 window."
L["DisplayTooltipNearSpyWindow"] = "Display tooltip near the Spy2 window"
L["DisplayTooltipNearSpyWindowDescription"] = "Set this to display tooltips near the Spy2 window."
L["SelectTooltipAnchor"] = "Tooltip Anchor Point"
L["SelectTooltipAnchorDescription"] = "Select the anchor point for the tooltip if the option above has been checked"
L["ANCHOR_CURSOR"] = "Cursor"
L["ANCHOR_TOP"] = "Top"
L["ANCHOR_BOTTOM"] = "Bottom"
L["ANCHOR_LEFT"] = "Left"
L["ANCHOR_RIGHT"] = "Right"
L["TooltipDisplayLastSeen"] = "Display last seen details in tooltip"
L["TooltipDisplayLastSeenDescription"] = "Set this to display the last known time and location of a player in the player's tooltip."
L["DisplayListData"] = "Select enemy data to display"
L["Name"] = "Name"
L["Class"] = "Class"
L["Rank"] = "Rank"
L["RowHeight"] = "Select the Row Height"
L["RowHeightDescription"] = "Select the Row Height for the Spy2 window."
L["Texture"] = "Texture"
L["TextureDescription"] = "Select a texture for the Spy2 Window"
L["MinimapDetection"] = "Enable minimap detection"
L["MinimapDetectionDescription"] = "Rolling the cursor over known enemy players detected on the minimap will add them to the Nearby list. Only works for players that can Track Humanoids."
L["MinimapDetails"] = "Display level/class details in minimap tooltips"
L["MinimapDetailsDescription"] = "Set this to update the minimap tooltips so that level/class details are displayed alongside enemy names."

-- Alerts
L["AlertOptions"] = "Alerts"
L["AlertOptionsDescription"] = [[
Options for the stealth and prowl alerts when enemy players are detected.
]]
L["SoundChannel"] = "Select Sound Channel"
L["Master"] = "Master"
L["SFX"] = "Sound Effects"
L["Music"] = "Music"
L["Ambience"] = "Ambience"
L["Guild"] = "Guild"
L["WarnOnStealth"] = "Warn upon stealth detection"
L["WarnOnStealthDescription"] = "Set this to display a warning and sound an alert when an enemy player gains stealth."
L["DisplayWarnings"] = "Select warnings message location"
L["Default"] = "Default"
L["ErrorFrame"] = "Error Frame"
L["Moveable"] = "Moveable"
L["EnableSound"] = "Enable audio alerts"
L["EnableSoundDescription"] = "Set this to play an audio alert when an enemy player gains stealth or prowl."
L["StopAlertsOnTaxi"] = "Turn off alerts while on a flight path"
L["StopAlertsOnTaxiDescription"] = "Stop all new alerts and warnings while on a flight path."

-- Nearby List
L["RemoveUndetected"] = "Remove enemy players from the Nearby list after:"
L["1Min"] = "1 minute"
L["1MinDescription"] = "Remove an enemy player who has been undetected for over 1 minute."
L["2Min"] = "2 minutes"
L["2MinDescription"] = "Remove an enemy player who has been undetected for over 2 minutes."
L["5Min"] = "5 minutes"
L["5MinDescription"] = "Remove an enemy player who has been undetected for over 5 minutes."
L["10Min"] = "10 minutes"
L["10MinDescription"] = "Remove an enemy player who has been undetected for over 10 minutes."
L["15Min"] = "15 minutes"
L["15MinDescription"] = "Remove an enemy player who has been undetected for over 15 minutes."
L["Never"] = "Never remove"
L["NeverDescription"] = "Never remove enemy players. The Nearby list can still be cleared manually."

-- Commands
L["SlashHelp"] = [[commands:
/spy2 config - open the options window
/spy2 clear - clear the nearby list
/spy2 reset - recenter the window
/spy2 test - add fake players to the list to preview the window
Detection runs automatically; the window appears when an enemy player is detected.]]

-- Alert window / warning text
L["AlertStealthTitle"] = "Stealth player detected!"
L["StealthWarning"] = "|cff9933ffStealth player detected: |cffffffff"
L["Player"] = " (Player)"
L["Level"] = "Level"
L["LastSeen"] = "Last seen"
L["LessThanOneMinuteAgo"] = "less than a minute ago"
L["MinutesAgo"] = "minutes ago"
L["HoursAgo"] = "hours ago"
L["DaysAgo"] = "days ago"

-- Class descriptions
L["UNKNOWN"] = "Unknown"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"

-- Stealth abilities
L["Stealth"] = "Stealth"
L["Prowl"] = "Prowl"

-- Minimap class colour codes
L["MinimapClassTextUNKNOWN"] = "|cff191919"
L["MinimapClassTextDRUID"] = "|cffff7c0a"
L["MinimapClassTextHUNTER"] = "|cffaad372"
L["MinimapClassTextMAGE"] = "|cff68ccef"
L["MinimapClassTextPALADIN"] = "|cfff48cba"
L["MinimapClassTextPRIEST"] = "|cffffffff"
L["MinimapClassTextROGUE"] = "|cfffff468"
L["MinimapClassTextSHAMAN"] = "|cff2359ff"
L["MinimapClassTextWARLOCK"] = "|cff9382c9"
L["MinimapClassTextWARRIOR"] = "|cffc69b6d"

Spy2_IgnoreList = {
	["Mailbox"]=true,
	["Treasure Chest"]=true,
	["Small Treasure Chest"]=true,
};
