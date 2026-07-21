local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("Spy2")
local _

Spy2 = LibStub("AceAddon-3.0"):NewAddon("Spy2", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
Spy2.Version = "1.0.0"
Spy2.ButtonLimit = 20
Spy2.MaximumPlayerLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

Spy2.NearbyList = {}
Spy2.ActiveList = {}
Spy2.InactiveList = {}
Spy2.ListAmountDisplayed = 0
Spy2.ButtonName = {}
Spy2.EnabledInZone = false
Spy2.InInstance = false
Spy2.ChnlTime = 0
Spy2.Skull = -1
Spy2.PetGUID = {}
Spy2.PlayerData = {}

Spy2.options = {
	name = L["Spy2"],
	type = "group",
	args = {
		About = {
			name = L["About"],
			desc = L["About"],
			type = "group",
			order = 10,
			args = {
				intro1 = { name = L["SpyDescription1"], type = "description", order = 1, fontSize = "medium" },
				intro2 = { name = L["SpyDescription2"], type = "description", order = 2, fontSize = "medium" },
				intro3 = { name = L["SpyDescription3"], type = "description", order = 3, fontSize = "medium" },
			},
		},
		General = {
			name = L["GeneralSettings"],
			desc = L["GeneralSettings"],
			type = "group",
			order = 1,
			args = {
				intro = {
					name = L["GeneralSettingsDescription"],
					type = "description",
					order = 1,
					fontSize = "medium",
				},
				EnabledInBattlegrounds = {
					name = L["EnabledInBattlegrounds"],
					desc = L["EnabledInBattlegroundsDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info) return Spy2.db.profile.EnabledInBattlegrounds end,
					set = function(info, value)
						Spy2.db.profile.EnabledInBattlegrounds = value
						Spy2:ZoneChangedEvent()
					end,
				},
				DisableWhenPVPUnflagged = {
					name = L["DisableWhenPVPUnflagged"],
					desc = L["DisableWhenPVPUnflaggedDescription"],
					type = "toggle",
					order = 3,
					width = "full",
					get = function(info) return Spy2.db.profile.DisableWhenPVPUnflagged end,
					set = function(info, value)
						Spy2.db.profile.DisableWhenPVPUnflagged = value
						Spy2:ZoneChangedEvent()
					end,
				},
				DisabledInZones = {
					name = L["DisabledInZones"],
					desc = L["DisabledInZonesDescription"],
					type = "multiselect",
					order = 4,
					get = function(info, key) return Spy2.db.profile.FilteredZones[key] end,
					set = function(info, key, value) Spy2.db.profile.FilteredZones[key] = value end,
					values = {
						["Booty Bay"] = L["Booty Bay"],
						["Everlook"] = L["Everlook"],
						["Gadgetzan"] = L["Gadgetzan"],
						["Ratchet"] = L["Ratchet"],
						["The Salty Sailor Tavern"] = L["The Salty Sailor Tavern"],
						["Cenarion Hold"] = L["Cenarion Hold"],
					},
				},
				RightClickClear = {
					name = L["RightClickClear"],
					desc = L["RightClickClearDescription"],
					type = "toggle",
					order = 8,
					width = "full",
					get = function(info) return Spy2.db.profile.RightClickClear end,
					set = function(info, value) Spy2.db.profile.RightClickClear = value end,
				},
			},
		},
		DisplayOptions = {
			name = L["DisplayOptions"],
			desc = L["DisplayOptions"],
			type = "group",
			order = 2,
			args = {
				intro = {
					name = L["DisplayOptionsDescription"],
					type = "description",
					order = 1,
					fontSize = "medium",
				},
				Alpha = {
					name = L["Alpha"],
					desc = L["AlphaDescription"],
					type = "range",
					order = 3,
					min = 0, max = 1, step = 0.01,
					isPercent = true,
					get = function() return Spy2.db.profile.MainWindow.Alpha end,
					set = function(info, value)
						Spy2.db.profile.MainWindow.Alpha = value
						Spy2:UpdateMainWindow()
					end,
				},
				AlphaBG = {
					name = L["AlphaBG"],
					desc = L["AlphaBGDescription"],
					type = "range",
					order = 4,
					min = 0, max = 1, step = 0.01,
					isPercent = true,
					get = function() return Spy2.db.profile.MainWindow.AlphaBG end,
					set = function(info, value)
						Spy2.db.profile.MainWindow.AlphaBG = value
						Spy2:UpdateMainWindow()
					end,
				},
				ClampToScreen = {
					name = L["ClampToScreen"],
					desc = L["ClampToScreenDescription"],
					type = "toggle",
					order = 5,
					get = function(info) return Spy2.db.profile.ClampToScreen end,
					set = function(info, value)
						Spy2.db.profile.ClampToScreen = value
						Spy2:ClampToScreen(value)
					end,
				},
				InvertSpy = {
					name = L["InvertSpy"],
					desc = L["InvertSpyDescription"],
					type = "toggle",
					order = 6,
					get = function(info) return Spy2.db.profile.InvertSpy end,
					set = function(info, value) Spy2.db.profile.InvertSpy = value end,
				},
				[L["Reload"]] = {
					name = L["Reload"],
					desc = L["ReloadDescription"],
					type = 'execute',
					order = 7,
					width = .6,
					func = function() C_UI.Reload() end
				},
				ResizeSpyLimit = {
					type = "range",
					order = 9,
					name = L["ResizeSpyLimit"],
					desc = L["ResizeSpyLimitDescription"],
					min = 1, max = Spy2.ButtonLimit, step = 1,
					get = function() return Spy2.db.profile.ResizeSpyLimit end,
					set = function(info, value)
						Spy2.db.profile.ResizeSpyLimit = value
						if value then
							Spy2:ResizeMainWindow()
							Spy2:RefreshList()
						end
					end,
				},
				WindowWidth = {
					type = "range",
					order = 9.5,
					name = L["WindowWidth"],
					desc = L["WindowWidthDescription"],
					min = 90, max = 300, step = 1,
					get = function() return Spy2.db.profile.MainWindow.Position.w end,
					set = function(info, value)
						Spy2.db.profile.MainWindow.Position.w = value
						if Spy2.MainWindow then
							Spy2.MainWindow:SetWidth(value)
							Spy2:ResizeMainWindow()
						end
					end,
				},
				DisplayListData = {
					name = L["DisplayListData"],
					type = 'select',
					order = 10,
					values = {
						["1NameLevelClass"] = L["Name"].." / "..L["Level"].." / "..L["Class"],
						["2NameLevelGuild"] = L["Name"].." / "..L["Level"].." / "..L["Guild"],
						["3NameLevelOnly"] = L["Name"].." / "..L["Level"],
						["4NamePvPRank"] = L["Name"].." / "..L["Rank"],
						["5NameGuild"] = L["Name"].." / "..L["Guild"],
						["6NameOnly"] = L["Name"],
					},
					get = function() return Spy2.db.profile.DisplayListData end,
					set = function(info, value)
						Spy2.db.profile.DisplayListData = value
						Spy2:RefreshList()
					end,
				},
				RowHeight = {
					type = "range",
					order = 11,
					name = L["RowHeight"],
					desc = L["RowHeightDescription"],
					min = 8, max = 20, step = 1,
					get = function() return Spy2.db.profile.MainWindow.RowHeight end,
					set = function(info, value)
						Spy2.db.profile.MainWindow.RowHeight = value
						if value then Spy2:BarsChanged() end
					end,
				},
				BarTexture = {
					type = "select",
					order = 12,
					name = L["Texture"],
					desc = L["TextureDescription"],
					dialogControl = "LSM30_Statusbar",
					width = "double",
					values = SM:HashTable("statusbar"),
					get = function() return Spy2.db.profile.BarTexture end,
					set = function(_, key)
						Spy2.db.profile.BarTexture = key
						Spy2:UpdateBarTextures()
					end,
				},
				Scaling = {
					type = "range",
					order = 13,
					name = L["Scaling"],
					desc = L["ScalingDescription"],
					min = 0.5, max = 2, step = 0.05,
					isPercent = true,
					get = function() return Spy2.db.profile.Scaling end,
					set = function(info, value)
						Spy2.db.profile.Scaling = value
						if Spy2.MainWindow then Spy2.MainWindow:SetScale(value) end
					end,
				},
				DisplayTooltipNearSpyWindow = {
					name = L["DisplayTooltipNearSpyWindow"],
					desc = L["DisplayTooltipNearSpyWindowDescription"],
					type = "toggle",
					order = 14,
					width = "full",
					get = function(info) return Spy2.db.profile.DisplayTooltipNearSpyWindow end,
					set = function(info, value) Spy2.db.profile.DisplayTooltipNearSpyWindow = value end,
				},
				SelectTooltipAnchor = {
					type = "select",
					order = 15,
					name = L["SelectTooltipAnchor"],
					desc = L["SelectTooltipAnchorDescription"],
					values = {
						["ANCHOR_CURSOR"] = L["ANCHOR_CURSOR"],
						["ANCHOR_TOP"] = L["ANCHOR_TOP"],
						["ANCHOR_BOTTOM"] = L["ANCHOR_BOTTOM"],
						["ANCHOR_LEFT"] = L["ANCHOR_LEFT"],
						["ANCHOR_RIGHT"] = L["ANCHOR_RIGHT"],
					},
					get = function() return Spy2.db.profile.TooltipAnchor end,
					set = function(info, value) Spy2.db.profile.TooltipAnchor = value end,
				},
				DisplayLastSeen = {
					name = L["TooltipDisplayLastSeen"],
					desc = L["TooltipDisplayLastSeenDescription"],
					type = "toggle",
					order = 16,
					width = "full",
					get = function(info) return Spy2.db.profile.DisplayLastSeen end,
					set = function(info, value) Spy2.db.profile.DisplayLastSeen = value end,
				},
				MinimapDetection = {
					name = L["MinimapDetection"],
					desc = L["MinimapDetectionDescription"],
					type = "toggle",
					order = 16.1,
					width = "full",
					get = function(info) return Spy2.db.profile.MinimapDetection end,
					set = function(info, value) Spy2.db.profile.MinimapDetection = value end,
				},
				MinimapDetails = {
					name = L["MinimapDetails"],
					desc = L["MinimapDetailsDescription"],
					type = "toggle",
					order = 16.2,
					width = "full",
					get = function(info) return Spy2.db.profile.MinimapDetails end,
					set = function(info, value) Spy2.db.profile.MinimapDetails = value end,
				},
				RemoveUndetected = {
					name = L["RemoveUndetected"],
					type = "group",
					order = 17,
					inline = true,
					args = {
						OneMinute = {
							name = L["1Min"], desc = L["1MinDescription"], type = "toggle", order = 1,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "OneMinute" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "OneMinute" Spy2:UpdateTimeoutSettings() end,
						},
						TwoMinutes = {
							name = L["2Min"], desc = L["2MinDescription"], type = "toggle", order = 2,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "TwoMinutes" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "TwoMinutes" Spy2:UpdateTimeoutSettings() end,
						},
						FiveMinutes = {
							name = L["5Min"], desc = L["5MinDescription"], type = "toggle", order = 3,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "FiveMinutes" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "FiveMinutes" Spy2:UpdateTimeoutSettings() end,
						},
						TenMinutes = {
							name = L["10Min"], desc = L["10MinDescription"], type = "toggle", order = 4,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "TenMinutes" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "TenMinutes" Spy2:UpdateTimeoutSettings() end,
						},
						FifteenMinutes = {
							name = L["15Min"], desc = L["15MinDescription"], type = "toggle", order = 5,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "FifteenMinutes" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "FifteenMinutes" Spy2:UpdateTimeoutSettings() end,
						},
						Never = {
							name = L["Never"], desc = L["NeverDescription"], type = "toggle", order = 6,
							get = function(info) return Spy2.db.profile.RemoveUndetected == "Never" end,
							set = function(info, value) Spy2.db.profile.RemoveUndetected = "Never" Spy2:UpdateTimeoutSettings() end,
						},
					},
				},
			},
		},
		AlertOptions = {
			name = L["AlertOptions"],
			desc = L["AlertOptions"],
			type = "group",
			order = 3,
			args = {
				intro = {
					name = L["AlertOptionsDescription"],
					type = "description",
					order = 1,
					fontSize = "medium",
				},
				EnableSound = {
					name = L["EnableSound"],
					desc = L["EnableSoundDescription"],
					type = "toggle",
					order = 2,
					width = "full",
					get = function(info) return Spy2.db.profile.EnableSound end,
					set = function(info, value) Spy2.db.profile.EnableSound = value end,
				},
				SoundChannel = {
					name = L["SoundChannel"],
					type = 'select',
					order = 3,
					values = {
						["Master"] = L["Master"],
						["SFX"] = L["SFX"],
						["Music"] = L["Music"],
						["Ambience"] = L["Ambience"],
					},
					get = function() return Spy2.db.profile.SoundChannel end,
					set = function(info, value) Spy2.db.profile.SoundChannel = value end,
				},
				StopAlertsOnTaxi = {
					name = L["StopAlertsOnTaxi"],
					desc = L["StopAlertsOnTaxiDescription"],
					type = "toggle",
					order = 4,
					width = "full",
					get = function(info) return Spy2.db.profile.StopAlertsOnTaxi end,
					set = function(info, value) Spy2.db.profile.StopAlertsOnTaxi = value end,
				},
				DisplayWarnings = {
					name = L["DisplayWarnings"],
					type = 'select',
					order = 5,
					values = {
						["Default"] = L["Default"],
						["ErrorFrame"] = L["ErrorFrame"],
						["Moveable"] = L["Moveable"],
					},
					get = function() return Spy2.db.profile.DisplayWarnings end,
					set = function(info, value)
						Spy2.db.profile.DisplayWarnings = value
						Spy2:UpdateAlertWindow()
					end,
				},
				WarnOnStealth = {
					name = L["WarnOnStealth"],
					desc = L["WarnOnStealthDescription"],
					type = "toggle",
					order = 6,
					width = "full",
					get = function(info) return Spy2.db.profile.WarnOnStealth end,
					set = function(info, value) Spy2.db.profile.WarnOnStealth = value end,
				},
			},
		},
	},
}

local Default_Profile = {
	profile = {
		Colors = {
			["Window"] = {
				["Title"] = { r = 1, g = 1, b = 1, a = 1 },
				["Background"]= { r = 24/255, g = 24/255, b = 24/255, a = 0.2 },
				["Title Text"] = { r = 1, g = 1, b = 1, a = 1 },
			},
			["Other Windows"] = {
				["Title"] = { r = 1, g = 0, b = 0, a = 1 },
				["Background"]= { r = 24/255, g = 24/255, b = 24/255, a = 1 },
				["Title Text"] = { r = 1, g = 1, b = 1, a = 1 },
			},
			["Bar"] = {
				["Bar Text"] = { r = 1, g = 1, b = 1 },
			},
			["Warning"] = {
				["Warning Text"] = { r = 1, g = 1, b = 1 },
			},
			["Tooltip"] = {
				["Title Text"] = { r = 0.8, g = 0.3, b = 0.22 },
				["Details Text"] = { r = 1, g = 1, b = 1 },
				["Location Text"] = { r = 1, g = 0.82, b = 0 },
			},
			["Alert"] = {
				["Background"]= { r = 0, g = 0, b = 0, a = 0.4 },
				["Icon"] = { r = 1, g = 1, b = 1, a = 0.5 },
				["Stealth Border"] = { r = 0.6, g = 0.2, b = 1, a = 0.4 },
				["Stealth Text"] = { r = 0.6, g = 0.2, b = 1 },
				["Location Text"] = { r = 1, g = 0.82, b = 0 },
				["Name Text"] = { r = 1, g = 1, b = 1 },
			},
			["Class"] = {
				["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, a = 1 },
				["WARLOCK"] = { r = 0.53, g = 0.53, b = 0.93, a = 1 },
				["PRIEST"] = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
				["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, a = 1 },
				["MAGE"] = { r = 0.25, g = 0.78, b = 0.92, a = 1 },
				["ROGUE"] = { r = 1.00, g = 0.96, b = 0.41, a = 1 },
				["DRUID"] = { r = 1.00, g = 0.49, b = 0.04, a = 1 },
				["SHAMAN"] = { r = 0.00, g = 0.44, b = 0.87, a = 1 },
				["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, a = 1 },
				["PET"] = { r = 0.09, g = 0.61, b = 0.55, a = 1 },
				["MOB"] = { r = 0.58, g = 0.24, b = 0.63, a = 1 },
				["UNKNOWN"] = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
				["HOSTILE"] = { r = 0.7, g = 0.1, b = 0.1, a = 1 },
				["UNGROUPED"] = { r = 0.63, g = 0.58, b = 0.24, a = 1 },
			},
		},
		MainWindow={
			Alpha=1,
			AlphaBG=1,
			RowHeight=14,
			RowSpacing=0,
			TextHeight=12,
			Position={
				w = 160,
				h = 34,
			},
		},
		AlertWindow={
			Position={
				x = 750,
				y = 750,
			},
			NameSize=14,
			LocationSize=10,
		},
		BarTexture="Raid",
		MainWindowVis=true,
		ClampToScreen=true,
		Scaling=1,
		Enabled=true,
		EnabledInBattlegrounds=true,
		DisableWhenPVPUnflagged=false,
		MinimapDetection=false,
		MinimapDetails=true,
		DisplayTooltipNearSpyWindow=false,
		TooltipAnchor="ANCHOR_CURSOR",
		DisplayLastSeen=true,
		DisplayListData="1NameLevelClass",
		RightClickClear=true,
		InvertSpy=false,
		ResizeSpyLimit=15,
		SoundChannel="SFX",
		WarnOnStealth=true,
		DisplayWarnings="Default",
		EnableSound=true,
		StopAlertsOnTaxi=true,
		RemoveUndetected="OneMinute",
		FilteredZones = {
			["Booty Bay"] = false,
			["Gadgetzan"] = false,
			["Ratchet"] = false,
			["Everlook"] = false,
			["The Salty Sailor Tavern"] = false,
			["Cenarion Hold"] = false,
		},
	},
}

-- Blizzard built-in statusbar textures registered so the Texture picker has options (no bundled files)
SM:Register("statusbar", "Solid", [[Interface\Buttons\WHITE8X8]])
SM:Register("statusbar", "Raid", [[Interface\RaidFrame\Raid-Bar-Hp-Fill]])
SM:Register("statusbar", "Skills", [[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]])

function Spy2:HandleProfileChanges()
	Spy2:CreateMainWindow()
	Spy2.MainWindow:SetScale(Spy2.db.profile.Scaling)
	Spy2:RestoreMainWindowPosition(Spy2.db.profile.MainWindow.Position.x, Spy2.db.profile.MainWindow.Position.y, Spy2.db.profile.MainWindow.Position.w, 34)
	Spy2:ResizeMainWindow()
	Spy2:UpdateTimeoutSettings()
	Spy2:ClampToScreen(Spy2.db.profile.ClampToScreen)
end

function Spy2:RegisterModuleOptions(name, optionTbl, displayName)
	Spy2.options.args[name] = (type(optionTbl) == "function") and optionTbl() or optionTbl
	self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Spy2", displayName, L["Spy2 Option"], name)
end

function Spy2:SetupOptions()
	self.optionsFrames = {}

 	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Spy2", Spy2.options)

	local ACD3 = LibStub("AceConfigDialog-3.0")
	self.optionsFrames.Spy2 = ACD3:AddToBlizOptions("Spy2", L["Spy2 Option"], nil, "General")
	self.optionsFrames.About = ACD3:AddToBlizOptions("Spy2", L["About"], L["Spy2 Option"], "About")
	self.optionsFrames.DisplayOptions = ACD3:AddToBlizOptions("Spy2", L["DisplayOptions"], L["Spy2 Option"], "DisplayOptions")
	self.optionsFrames.AlertOptions = ACD3:AddToBlizOptions("Spy2", L["AlertOptions"], L["Spy2 Option"], "AlertOptions")

	self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), L["Profiles"])
	Spy2.options.args.Profiles.order = -2

	Spy2:RegisterChatCommand("spy2", "SlashCommand")
end

function Spy2:SlashCommand(input)
	input = strtrim(input or ""):lower()
	if input == "config" then
		Spy2:ShowConfig()
	elseif input == "reset" then
		Spy2:ResetPositions()
	elseif input == "clear" then
		Spy2:ClearList()
	elseif input == "test" then
		Spy2:AddTestData()
	else
		Spy2:Print(L["SlashHelp"])
	end
end

-- {ActiveTimeout, InactiveTimeout} in seconds; InactiveTimeout -1 means never expire.
local TimeoutSettings = {
	OneMinute = { 30, 60 },
	TwoMinutes = { 60, 120 },
	FiveMinutes = { 150, 300 },
	TenMinutes = { 300, 600 },
	FifteenMinutes = { 450, 900 },
	Never = { 30, -1 },
}

function Spy2:UpdateTimeoutSettings()
	local s = TimeoutSettings[Spy2.db.profile.RemoveUndetected] or TimeoutSettings.OneMinute
	Spy2.ActiveTimeout = s[1]
	Spy2.InactiveTimeout = s[2]
end

function Spy2:ResetPositions()
	-- clear the stored position so the window re-centers and stays centered across reloads
	Spy2.db.profile.MainWindow.Position.x = nil
	Spy2.db.profile.MainWindow.Position.y = nil
	Spy2:ResetPositionAllWindows()
end

function Spy2:ShowConfig()
	local ACD3 = LibStub("AceConfigDialog-3.0")
	if ACD3.OpenFrames["Spy2"] then
		ACD3:Close("Spy2")
	else
		ACD3:Open("Spy2")
	end
end

function Spy2:OnEnable(first)
	Spy2.timeid = Spy2:ScheduleRepeatingTimer("ManageExpirations", 10, true)
	Spy2:RegisterEvent("ZONE_CHANGED", "ZoneChangedEvent")
	Spy2:RegisterEvent("ZONE_CHANGED_INDOORS", "ZoneChangedEvent")
	Spy2:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedNewAreaEvent")
	Spy2:RegisterEvent("PLAYER_ENTERING_WORLD", "PlayerEnteringWorldEvent")
	Spy2:RegisterEvent("UNIT_FACTION", "ZoneChangedEvent")
	Spy2:RegisterEvent("PLAYER_REGEN_ENABLED", "LeftCombatEvent")
	Spy2:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", "ChannelNoticeEvent")
	-- The new-target detection events (combat log, nameplate, mouseover, target, pet) are
	-- registered per-zone by UpdateDetectionEvents, so they stop firing in dungeons/raids.
	-- The expiration timer above keeps aging already-known enemies regardless of zone, so the
	-- list still fades out while you are in an instance.
	Spy2.DetectionRegistered = false
	Spy2.IsEnabled = true
end

function Spy2:OnDisable()
	if not Spy2.IsEnabled then
		return
	end
	if Spy2.timeid then
		Spy2:CancelTimer(Spy2.timeid)
		Spy2.timeid = nil
	end
	Spy2:UnregisterEvent("ZONE_CHANGED")
	Spy2:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	Spy2:UnregisterEvent("ZONE_CHANGED_INDOORS")
	Spy2:UnregisterEvent("PLAYER_ENTERING_WORLD")
	Spy2:UnregisterEvent("UNIT_FACTION")
	Spy2:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Spy2:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE")
	Spy2.EnabledInZone = false
	Spy2:UpdateDetectionEvents()
	Spy2.IsEnabled = false
end

-- Registers the new-target detection events when the current zone allows detection and
-- unregisters them otherwise. In dungeons/raids (EnabledInZone false) these stay unregistered
-- so combat-log/nameplate/mouseover/target/pet handlers never run, while the expiration timer
-- keeps fading already-detected enemies.
function Spy2:UpdateDetectionEvents()
	if Spy2.EnabledInZone then
		if Spy2.DetectionRegistered then return end
		Spy2:RegisterEvent("PLAYER_TARGET_CHANGED", "PlayerTargetEvent")
		Spy2:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "PlayerMouseoverEvent")
		Spy2:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLogEvent")
		Spy2:RegisterEvent("UNIT_PET", "UnitPets")
		Spy2:RegisterEvent("NAME_PLATE_UNIT_ADDED", "NamePlateEvent")
		Spy2:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "NamePlateEvent")
		Spy2.DetectionRegistered = true
	else
		if not Spy2.DetectionRegistered then return end
		Spy2:UnregisterEvent("PLAYER_TARGET_CHANGED")
		Spy2:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		Spy2:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		Spy2:UnregisterEvent("UNIT_PET")
		Spy2:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
		Spy2:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
		Spy2.DetectionRegistered = false
	end
end

function Spy2:OnInitialize()
	Spy2.FactionName = select(1, UnitFactionGroup("player"))
	if Spy2.FactionName == "Alliance" then
		Spy2.EnemyFactionName = "Horde"
	elseif Spy2.FactionName == "Horde" then
		Spy2.EnemyFactionName = "Alliance"
	else
		Spy2.EnemyFactionName = "None"
	end
	Spy2.CharacterName = UnitName("player")

	Spy2.ValidClasses = {
		["DRUID"] = true,
		["HUNTER"] = true,
		["MAGE"] = true,
		["PALADIN"] = true,
		["PRIEST"] = true,
		["ROGUE"] = true,
		["SHAMAN"] = true,
		["WARLOCK"] = true,
		["WARRIOR"] = true,
	}

	Spy2.ValidRaces = {
		["Human"] = true,
		["Orc"] = true,
		["Dwarf"] = true,
		["Tauren"] = true,
		["Troll"] = true,
		["NightElf"] = true,
		["Scourge"] = true,
		["Gnome"] = true,
	}

	local acedb = LibStub:GetLibrary("AceDB-3.0")

	Spy2.db = acedb:New("Spy2DB", Default_Profile)

	self.db.RegisterCallback(self, "OnNewProfile", "HandleProfileChanges")
	self.db.RegisterCallback(self, "OnProfileReset", "HandleProfileChanges")
	self.db.RegisterCallback(self, "OnProfileChanged", "HandleProfileChanges")
	self.db.RegisterCallback(self, "OnProfileCopied", "HandleProfileChanges")
	self:SetupOptions()

	SpyTempTooltip = CreateFrame("GameTooltip", "SpyTempTooltip", nil, "GameTooltipTemplate")
	SpyTempTooltip:SetOwner(UIParent, "ANCHOR_NONE")

	Spy2.PlayerData = {}
	Spy2:CreateMainWindow()
	Spy2:UpdateTimeoutSettings()

	SM.RegisterCallback(Spy2, "LibSharedMedia_Registered", "UpdateBarTextures")
	SM.RegisterCallback(Spy2, "LibSharedMedia_SetGlobal", "UpdateBarTextures")
	if Spy2.db.profile.BarTexture then
		Spy2:SetBarTextures(Spy2.db.profile.BarTexture)
	end

	Spy2:ClampToScreen(Spy2.db.profile.ClampToScreen)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", Spy2.FilterNotInParty)
	Spy2:FixUnitPopupServerName()
end

-- Blizzard's target-frame context menu builds "name-server" in UnitPopupSharedUtil.GetFullPlayerName
-- and errors when an enemy player's context carries no server. Targeting an enemy from a Spy2 row
-- makes that menu reachable, so supply the player's own realm when the server field is missing.
function Spy2:FixUnitPopupServerName()
	local util = UnitPopupSharedUtil
	if not util or type(util.GetFullPlayerName) ~= "function" then return end
	local original = util.GetFullPlayerName
	util.GetFullPlayerName = function(contextData, ...)
		if type(contextData) == "table" and contextData.name and not contextData.server then
			contextData.server = GetNormalizedRealmName()
		end
		return original(contextData, ...)
	end
end

function Spy2:ChannelNoticeEvent(_, chStatus, _, _, Channel)
	if chStatus ~= "SUSPENDED" then
		Spy2.ChnlTime = time()
		local _, zone = string.match(Channel, "(.+) %- (.+)")
		local InFilteredZone = Spy2:InFilteredZone(zone)
		if InFilteredZone then
			Spy2.EnabledInZone = false
		end
	end
end

-- A channel-notice burst fires on every zone-in. Wait until 6s after the last one before reading
-- the zone, so InFilteredZone sees the settled channel list. Returns true while still waiting.
local function ZoneDebounce(method)
	if Spy2.ChnlTime > (time() - 6) then
		Spy2:ScheduleTimer(method, 6)
		return true
	end
	return false
end

function Spy2:PlayerEnteringWorldEvent()
	Spy2.EnabledInZone = false
	if ZoneDebounce("PlayerEnteringWorldEvent") then return end
	Spy2:ZoneChanged()
end

function Spy2:ZoneChangedEvent()
	if ZoneDebounce("ZoneChangedEvent") then return end
	Spy2:ZoneChanged()
end

function Spy2:ZoneChangedNewAreaEvent()
	if ZoneDebounce("ZoneChangedNewAreaEvent") then return end
	Spy2:ZoneChanged()
end

function Spy2:ZoneChanged()
	Spy2.InInstance = false
 	local zone = GetZoneText()
	local subZone = GetSubZoneText()
	local InFilteredZone = Spy2:InFilteredZone(zone, subZone)
	Spy2.EnabledInZone = true
	if zone == "" or InFilteredZone then
		Spy2.EnabledInZone = false
	else
		Spy2.EnabledInZone = true
		local inInstance, instanceType = IsInInstance()
		if inInstance then
			Spy2.InInstance = true
			if instanceType == "party" or instanceType == "raid" or (not Spy2.db.profile.EnabledInBattlegrounds and instanceType == "pvp") then
				Spy2.EnabledInZone = false
			end
		elseif UnitIsPVP("player") == false and Spy2.db.profile.DisableWhenPVPUnflagged then
			Spy2.EnabledInZone = false
		end
	end

	-- start or stop the new-target detection events for this zone; in dungeons/raids they stay
	-- off so no CPU is spent finding new enemies, while the expiration timer keeps fading the
	-- enemies already on the list.
	Spy2:UpdateDetectionEvents()

	-- the window stays shown in every zone; with no bars it collapses to nothing, so there is
	-- never a reason to hide it. detection is gated separately by EnabledInZone above.
	if not InCombatLockdown() then Spy2.MainWindow:Show() end
	Spy2:RefreshList()
	Spy2:UpdateMainWindow()
end

function Spy2:InFilteredZone(zone, subzone)
	local InFilteredZone = false
	for filteredZone, value in pairs(Spy2.db.profile.FilteredZones) do
		if zone == filteredZone and value then
			InFilteredZone = true
		elseif subzone == filteredZone and value then
			InFilteredZone = true
--			break
		end
	end
	return InFilteredZone
end

-- Picks the best raw name from a GUID lookup: "Name-Realm" when the GUID carries a realm, the bare
-- GUID name when it does not, or the combat-log fallback when the GUID has no cached player info.
function Spy2:GUIDPlayerName(name, realm, fallback)
	if not name or name == "" then return fallback end
	if realm and realm ~= "" then return name.."-"..realm end
	return name
end

-- Normalises a player name to the single canonical key used everywhere: "Name-Realm" with spaces
-- stripped from the realm. GetUnitName strips realm spaces but the combat-log realm keeps them, so
-- both must be stripped to agree. A bare name (same-realm unit, uncached combat-log GUID) takes the
-- player's own realm, so every detection path produces one realm-qualified key.
function Spy2:CanonicalName(name)
	if not name or name == "" then return name end
	local base, realm = strsplit("-", name, 2)
	if realm and realm ~= "" then
		return base.."-"..string.gsub(realm, "%s", "")
	end
	return base.."-"..GetNormalizedRealmName()
end

-- Renders a stored "Name-Realm" key for display: the realm is shortened to three letters, and dropped
-- entirely when it is the player's own realm. The stored key is unchanged; this affects UI text only.
function Spy2:DisplayName(name)
	if not name then return name end
	local base, realm = strsplit("-", name, 2)
	if not realm or realm == "" or realm == GetNormalizedRealmName() then
		return base
	end
	return base.."-"..strsub(realm, 1, 3)
end

-- The name a /targetexact macro must use to select a stored "Name-Realm" key. A same-realm unit's
-- name carries no realm, so the suffix is dropped for the player's own realm; a connected-realm unit's
-- name includes the realm, so it is kept in full (DisplayName's 3-letter realm would not match).
function Spy2:TargetName(name)
	if not name then return name end
	local base, realm = strsplit("-", name, 2)
	if not realm or realm == "" or realm == GetNormalizedRealmName() then
		return base
	end
	return base.."-"..realm
end

-- Reads class/race/level/guild/faction/PvP-rank off a hostile player unit and records it. A
-- skull level (too high to read) is estimated from prior data or the player's own level. The
-- three detection events (target, mouseover, nameplate) all funnel here with their unit token.
function Spy2:DetectUnit(unit)
	local name = GetUnitName(unit, true)
	if not name or not UnitIsPlayer(unit) then return end
	name = Spy2:CanonicalName(name)

	local playerData = Spy2.PlayerData[name]
	if UnitIsEnemy("player", unit) then
		local learnt = true
		if playerData and playerData.isGuess == false then learnt = false end

		local _, class = UnitClass(unit)
		local race = select(1, UnitRace(unit))
		local level = tonumber(UnitLevel(unit))
		local guild = GetGuildInfo(unit)
		local faction = select(1, UnitFactionGroup(unit))
		local guess = false
		if level == Spy2.Skull then
			if playerData and playerData.level then
				if playerData.level > (UnitLevel("player") + 10) and playerData.level < Spy2.MaximumPlayerLevel then
					guess = true
					level = nil
				elseif UnitLevel("player") < Spy2.MaximumPlayerLevel - 9 then
					guess = true
					level = UnitLevel("player") + 10
				end
			else
				guess = true
				level = UnitLevel("player") + 10
			end
		end
		local _, rank = GetPVPRankInfo(UnitPVPRank(unit))
		if not rank then rank = nil end

		Spy2:UpdatePlayerData(name, class, level, race, guild, faction, true, guess, rank)
		if Spy2.EnabledInZone then
			Spy2:AddDetected(name, time(), learnt)
		end
	elseif playerData then
		Spy2:RemovePlayerData(name)
	end
end

function Spy2:PlayerTargetEvent()
	Spy2:DetectUnit("target")
end

function Spy2:PlayerMouseoverEvent()
	Spy2:DetectUnit("mouseover")
end

function Spy2:NamePlateEvent(_, unit)
	Spy2:DetectUnit(unit)
end

function Spy2:CombatLogEvent()
	local timestamp, event, hideCaster, srcGUID, srcName, srcFlags, sourceRaidFlags, dstGUID, dstName, dstFlags, destRaidFlags, arg12, arg13 = CombatLogGetCurrentEventInfo()
	if Spy2.EnabledInZone then
		-- analyse the source unit
		if bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and srcGUID and srcName then
			local srcType = strsub(srcGUID, 1,6)
			if srcType == "Player" then
				local _, class, race, raceFile, _, gname, grealm = GetPlayerInfoByGUID(srcGUID)
				if not Spy2.ValidClasses[class] then
					class = nil
				end
				if not Spy2.ValidRaces[raceFile] then
					race = nil
				end
				local name = Spy2:CanonicalName(Spy2:GUIDPlayerName(gname, grealm, srcName))
				local learnt = false
				local detected = true
				local playerData = Spy2.PlayerData[name]
				if not playerData or playerData.isGuess then
					learnt, playerData = Spy2:ParseUnitAbility(true, event, name, class, race, arg12, arg13)
				end
				if not learnt then
					detected = Spy2:UpdatePlayerData(name, class, nil, race, nil, nil, true, nil, nil)
				end

				if detected then
					Spy2:AddDetected(name, timestamp, learnt)
					if event == "SPELL_AURA_APPLIED" and (arg13 == L["Stealth"]) then
						Spy2:AlertStealthPlayer(name)
					end
					if event == "SPELL_AURA_APPLIED" and (arg13 == L["Prowl"]) then
						Spy2:AlertProwlPlayer(name)
					end
				end
			end
		end

		-- analyse the destination unit
		if bit.band(dstFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE and dstGUID and dstName then
			local dstType = strsub(dstGUID, 1,6)
			if dstType == "Player" then
				local _, class, race, raceFile, _, gname, grealm = GetPlayerInfoByGUID(dstGUID)
				if not Spy2.ValidClasses[class] then
					class = nil
				end
				if not Spy2.ValidRaces[raceFile] then
					race = nil
				end
				local name = Spy2:CanonicalName(Spy2:GUIDPlayerName(gname, grealm, dstName))
				local learnt = false
				local detected = true
				local playerData = Spy2.PlayerData[name]
				if not playerData or playerData.isGuess then
					learnt, playerData = Spy2:ParseUnitAbility(false, event, name, class, race, arg12, arg13)
				end
				if not learnt then
					detected = Spy2:UpdatePlayerData(name, class, nil, race, nil, nil, true, nil, nil)
				end
				if detected then
					Spy2:AddDetected(name, timestamp, learnt)
				end
			end
		end

		-- track the player's own pet GUIDs for pet-based detection attribution
		if event == "SPELL_SUMMON" and srcName == Spy2.CharacterName then
			Spy2.PetGUID[dstGUID] = time()
		end
	end
end

function Spy2:LeftCombatEvent()
	-- a reset pressed during combat is deferred to here, where the rows can be cleared and the window
	-- resized again. ClearList ends with its own RefreshList, so only refresh directly otherwise.
	if Spy2.ClearPending then
		Spy2:ClearList()
		return
	end
	Spy2:RefreshList()
end

function Spy2:UnitPets(event, unit)
	local petUnit
	if unit == "player" then
		petUnit = "pet"
	end
	if petUnit and UnitExists(petUnit) then
		local guid = UnitGUID(unit)
		local petGUID = UnitGUID(petUnit)
		Spy2.PetGUID[petGUID] = time()
		local petCount = 0
		for k, v in pairs(Spy2.PetGUID) do
			petCount = petCount + 1
			if petCount > 50 then
				if (time() - 9000) > v then
					Spy2.PetGUID[k] = nil
				end	
			end
		end	
	end
end

function Spy2:TrackHumanoids()
	local tooltip = GameTooltipTextLeft1:GetText()
	if tooltip and tooltip ~= Spy2.LastTooltip then
		tooltip = Spy2:ParseMinimapTooltip(tooltip)
		if Spy2.db.profile.MinimapDetails then
			GameTooltipTextLeft1:SetText(tooltip)
			Spy2.LastTooltip = tooltip
		end
		GameTooltip:Show()
	end
end

function Spy2:FilterNotInParty(frame, event, message)
	if (event == ERR_NOT_IN_GROUP or event == ERR_NOT_IN_RAID) then
		return true
	end
	return false
end

function Spy2:GetPlayerLocation(playerData)
	local location = playerData.zone
	local mapX = playerData.mapX
	local mapY = playerData.mapY
	if location and playerData.subZone and playerData.subZone ~= "" and playerData.subZone ~= location then
		location = playerData.subZone..", "..location
	end
	if mapX and mapX ~= 0 and mapY and mapY ~= 0 then
		location = location.." ("..math.floor(tonumber(mapX) * 100)..","..math.floor(tonumber(mapY) * 100)..")"
	end
	return location
end
