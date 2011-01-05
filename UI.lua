local WindowBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

local PaneBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local DraggerBackdrop  = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil,
	tile = true, tileSize = 16, edgeSize = 0,
	insets = { left = 3, right = 3, top = 7, bottom = 7 }
}

local filters_label_open = "|T" .. [[Interface\AddOns\DeathNote\Textures\tri-open.tga]] .. ":0|t Filters"
local filters_label_closed = "|T" .. [[Interface\AddOns\DeathNote\Textures\tri-closed.tga]] .. ":0|t Filters"
local normal_hilight = { r = 0.5, g = 0.5, b = 0.5, a = 0.4 }
local spell_hilight = { r = 0.25, g = 0.25, b = 0.5, a = 0.4 }
local source_hilight = { r = 0, g = 0, b = 0.6, a = 0.4 }

function DeathNote:Show()
	if not self.frame then
		local AceGUI = LibStub("AceGUI-3.0")
		local AceConfig = LibStub("AceConfig-3.0")
		local AceConfigDialog = LibStub("AceConfigDialog-3.0")

		local frame = CreateFrame("Frame", "DeathNoteFrame", UIParent)
		
		frame:SetWidth(self.settings.display.w)
		frame:SetHeight(self.settings.display.h)
		frame:SetPoint("CENTER", UIParent, "CENTER", self.settings.display.x, self.settings.display.y)
		frame:SetBackdrop(WindowBackdrop)
		frame:SetBackdropColor(0, 0, 0, 1)
		frame:SetBackdropBorderColor(0.4, 0.4, 0.4)		

		frame:EnableMouse()
		frame:SetMovable(true)
		frame:SetResizable(true)
		frame:SetClampedToScreen(true)
		frame:SetFrameStrata("DIALOG")
		
		-- titlebar
		local titlebar = frame:CreateTexture(nil, "BACKGROUND")
		titlebar:SetTexture(1, 1, 1, 1)
		titlebar:SetGradient("HORIZONTAL", 0.6, 0.6, 0.6, 0.3, 0.3, 0.3)
		titlebar:SetPoint("TOPLEFT", 4, -4)
		titlebar:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -4, -28)
		
		local titlebarframe = CreateFrame("Frame", nil, frame)
		titlebarframe:SetAllPoints(titlebar)
		titlebarframe:EnableMouse()

		local titleicon = frame:CreateTexture(nil, "ARTWORK")
		titleicon:SetTexture([[Interface\AddOns\DeathNote\Textures\icon.tga]])
		titleicon:SetPoint("TOPLEFT", titlebar, "TOPLEFT", 2, -2)
		titleicon:SetWidth(22)
		titleicon:SetHeight(22)
		
		local titletext = frame:CreateFontString(nil, "ARTWORK")
		titletext:SetFontObject(GameFontNormal)
		titletext:SetTextColor(0.6, 0.6, 0.6)
		titletext:SetPoint("TOPLEFT", titlebar, "TOPLEFT", 26, 0)
		titletext:SetPoint("BOTTOMRIGHT", titlebar)
		
		titletext:SetHeight(28)
		titletext:SetText("Death Note")
		titletext:SetJustifyH("LEFT")
		titletext:SetJustifyV("MIDDLE")
		
		-- close button
		local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", 0, 0)
		close:SetFrameLevel(3)
		close:SetScript("OnClick", function() frame:Hide() end)
		
		-- resizer
		local sizer_se = CreateFrame("Frame", nil, frame)
		sizer_se:SetPoint("BOTTOMRIGHT", -3, 3)
		sizer_se:SetWidth(16)
		sizer_se:SetHeight(16)

		local sizer_se_tex = frame:CreateTexture(nil, "BORDER")
		sizer_se_tex:SetTexture([[Interface\AddOns\DeathNote\Textures\resize.tga]])
		sizer_se_tex:SetAllPoints(sizer_se)

		local function save_frame_rect()
			local _, _, sw, sh = UIParent:GetRect()
			local x, y, w, h = frame:GetRect()
			self.settings.display.x, self.settings.display.y, self.settings.display.w, self.settings.display.h =
				x + w/2 - sw/2, y + h/2 - sh/2, w, h
		end
		
		titlebarframe:SetScript("OnMouseDown", function()
			self.logframe.content:Hide() -- HACK: for now, either this or huge performance problem
			frame:StartMoving()
		end)
		titlebarframe:SetScript("OnMouseUp", function()
			self.logframe.content:Show()
			frame:StopMovingOrSizing()
			
			save_frame_rect()
		end)

		sizer_se:SetScript("OnMouseDown", function()
			frame:SetMinResize(600, 270)
			frame:SetMaxResize(2000, 2000)
			
			frame:StartSizing() 
		end)
		sizer_se:SetScript("OnMouseUp", function()
			frame:StopMovingOrSizing()
			
			save_frame_rect()
		end)
		
		-- filters
		local filters_frame = CreateFrame("Frame", nil, frame)
		filters_frame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -34)
		filters_frame:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
		filters_frame:SetHeight(30)
		
		filters_frame:SetBackdrop(PaneBackdrop)
		filters_frame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
		filters_frame:SetBackdropBorderColor(0.4, 0.4, 0.4)
		
		local filters_label = filters_frame:CreateFontString(nil, "OVERLAY")
		filters_label:SetPoint("LEFT", 8, 0)
		filters_label:SetPoint("TOP", 0, -6)
		filters_label:SetPoint("BOTTOM", filters_frame, "TOP", 0, -25)
		filters_label:SetFontObject(GameFontNormal)		
		filters_label:SetText(filters_label_closed)
		
		local filters_title = CreateFrame("Frame", nil, filters_frame)
		filters_title:SetAllPoints(filters_label)
		filters_title:EnableMouse()
		
		-- tab group
		local filters_tab = CreateFrame("Frame", "DeathNoteFilters", filters_frame)
		filters_tab:Hide()
		filters_tab:SetPoint("TOP", filters_title, "BOTTOM", 0, -20)
		filters_tab:SetPoint("LEFT", 5, 0)
		filters_tab:SetPoint("RIGHT", -5, 0)
		filters_tab:SetPoint("BOTTOM", 0, 5)
		
		-- manual backdrop ftl
		local topleft = filters_tab:CreateTexture(nil, "BORDER")
		topleft:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		topleft:SetVertexColor(0.4, 0.4, 0.4)
		topleft:SetSize(16, 16)
		topleft:SetTexCoord(0.5, 0.625, 0, 1)
		topleft:SetPoint("TOPLEFT")
				
		local topright = filters_tab:CreateTexture(nil, "BORDER")
		topright:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		topright:SetVertexColor(0.4, 0.4, 0.4)
		topright:SetSize(16, 16)
		topright:SetTexCoord(0.625, 0.75, 0, 1)
		topright:SetPoint("TOPRIGHT")

		local bottomleft = filters_tab:CreateTexture(nil, "BORDER")
		bottomleft:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		bottomleft:SetVertexColor(0.4, 0.4, 0.4)
		bottomleft:SetSize(16, 16)
		bottomleft:SetTexCoord(0.75, 0.875, 0, 1)
		bottomleft:SetPoint("BOTTOMLEFT")
				
		local bottomright = filters_tab:CreateTexture(nil, "BORDER")
		bottomright:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		bottomright:SetVertexColor(0.4, 0.4, 0.4)
		bottomright:SetSize(16, 16)
		bottomright:SetTexCoord(0.875, 1, 0, 1)
		bottomright:SetPoint("BOTTOMRIGHT")				

		local left = filters_tab:CreateTexture(nil, "BORDER")
		left:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		left:SetVertexColor(0.4, 0.4, 0.4)
		left:SetTexCoord(0, 0.125, 0, 1)
		left:SetPoint("TOPLEFT", topleft, "BOTTOMLEFT")
		left:SetPoint("BOTTOMRIGHT", bottomleft, "TOPRIGHT")
		
		local right = filters_tab:CreateTexture(nil, "BORDER")
		right:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		right:SetVertexColor(0.4, 0.4, 0.4)
		right:SetTexCoord(0.125, 0.25, 0, 1)
		right:SetPoint("TOPLEFT", topright, "BOTTOMLEFT")
		right:SetPoint("BOTTOMRIGHT", bottomright, "TOPRIGHT")

		local bottom = filters_tab:CreateTexture(nil, "BORDER")
		bottom:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		bottom:SetVertexColor(0.4, 0.4, 0.4)
		bottom:SetTexCoord(0.8125, 0.875, 0, 1)		
		bottom:SetPoint("BOTTOMLEFT", bottomleft, "BOTTOMRIGHT")
		bottom:SetPoint("BOTTOMRIGHT", bottomright, "BOTTOMLEFT")		
		
		-- damage tab
		local damage_tab_button = CreateFrame("Button", "DeathNoteFiltersTab1", filters_tab, "OptionsFrameTabButtonTemplate")
		damage_tab_button.ntab = 1
		damage_tab_button:SetPoint("BOTTOMLEFT", filters_tab, "TOPLEFT", 6, -3)
		damage_tab_button:SetText("Damage")
		damage_tab_button:SetFrameLevel(2)

		local tabtext = DeathNoteFiltersTab1Text
		tabtext:ClearAllPoints()
		tabtext:SetPoint("LEFT", 14, -3)
		tabtext:SetPoint("RIGHT", -12, -3)
		
		local damage_tab_spacer1 = filters_tab:CreateTexture(nil, "BORDER")
		damage_tab_spacer1:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		damage_tab_spacer1:SetVertexColor(0.4, 0.4, 0.4)
		damage_tab_spacer1:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		damage_tab_spacer1:SetPoint("TOPLEFT", damage_tab_button, "BOTTOMRIGHT", -10, 3)
		damage_tab_spacer1:SetPoint("TOPRIGHT", topright, "TOPLEFT")		
		
		local damage_options = {
			type = "group",
			inline = true,
			args = {
				tgroup = {
					order = 1,
					name = "Threshold",
					type = "group",
					inline = true,
					args = {
						threshold = {
							order = 1,
							name = "",
							type = "range",
							width = "full",
							min = 0,
							softMax = 20000,
							step = 1,
							get = function() return DeathNote.settings.display_filters.damage_threshold end,
							set = function(_, v) DeathNote:SetDisplayFilter("damage_threshold", v) end,
						},
					},
				},
				consolidate = {
					order = 2,
					name = "Consolidate consecutive hits",
					type = "toggle",
					width = "double",
					get = function() return DeathNote.settings.display_filters.consolidate_damage end,
					set = function(_, v) DeathNote:SetDisplayFilter("consolidate_damage", v) end,
				},
				misses = {
					order = 3,
					name = "Hide misses",
					type = "toggle",
					width = "normal",
					get = function() return DeathNote.settings.display_filters.hide_misses end,
					set = function(_, v) DeathNote:SetDisplayFilter("hide_misses", v) end,
				},
			},
		}
		
		local damage_tab = AceGUI:Create("SimpleGroup")
		damage_tab.frame:SetParent(filters_tab)
		damage_tab.frame:SetScale(0.9)
		damage_tab.frame:Hide()
		damage_tab:SetPoint("TOPLEFT", 8, -8)
		damage_tab:SetPoint("BOTTOMRIGHT", -8, 8)
		AceConfig:RegisterOptionsTable("Death Note - Damage", damage_options)
		AceConfigDialog:Open("Death Note - Damage", damage_tab)
			
		-- healing tab
		local healing_tab_button = CreateFrame("Button", "DeathNoteFiltersTab2", filters_tab, "OptionsFrameTabButtonTemplate")
		healing_tab_button.ntab = 2
		healing_tab_button:SetPoint("TOPLEFT", damage_tab_button, "TOPRIGHT", -16, 0)
		healing_tab_button:SetText("Healing")
		healing_tab_button:SetFrameLevel(2)

		tabtext = DeathNoteFiltersTab2Text
		tabtext:ClearAllPoints()
		tabtext:SetPoint("LEFT", 14, -3)
		tabtext:SetPoint("RIGHT", -12, -3)
		
		local healing_tab_spacer1 = filters_tab:CreateTexture(nil, "BORDER")
		healing_tab_spacer1:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		healing_tab_spacer1:SetVertexColor(0.4, 0.4, 0.4)
		healing_tab_spacer1:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		healing_tab_spacer1:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
		healing_tab_spacer1:SetPoint("TOPRIGHT", healing_tab_button, "BOTTOMLEFT", 10, 0)
		
		local healing_tab_spacer2 = filters_tab:CreateTexture(nil, "BORDER")
		healing_tab_spacer2:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		healing_tab_spacer2:SetVertexColor(0.4, 0.4, 0.4)
		healing_tab_spacer2:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		healing_tab_spacer2:SetPoint("TOPLEFT", healing_tab_button, "BOTTOMRIGHT", -10, 3)
		healing_tab_spacer2:SetPoint("TOPRIGHT", topright, "TOPLEFT")
		
		local healing_options = {
			type = "group",
			inline = true,
			args = {
				tgroup = {
					order = 1,
					name = "Threshold",
					type = "group",
					inline = true,
					args = {
						threshold = {
							order = 1,
							name = "",
							type = "range",
							width = "full",
							min = 0,
							softMax = 20000,
							step = 1,
							get = function() return DeathNote.settings.display_filters.heal_threshold end,
							set = function(_, v) DeathNote:SetDisplayFilter("heal_threshold", v) end,
						},
					},
				},
				consolidate = {
					order = 2,
					name = "Consolidate consecutive heals",
					type = "toggle",
					width = "full",
					get = function() return DeathNote.settings.display_filters.consolidate_heals end,
					set = function(_, v) DeathNote:SetDisplayFilter("consolidate_heals", v) end,					
				},
			},
		}
		
		local healing_tab = AceGUI:Create("SimpleGroup")
		healing_tab.frame:SetParent(filters_tab)
		healing_tab.frame:SetScale(0.9)
		healing_tab.frame:Hide()
		healing_tab:SetPoint("TOPLEFT", 8, -8)
		healing_tab:SetPoint("BOTTOMRIGHT", -8, 8)
		AceConfig:RegisterOptionsTable("Death Note - Healing", healing_options)
		AceConfigDialog:Open("Death Note - Healing", healing_tab)
		
		-- auras tab
		local auras_tab_button = CreateFrame("Button", "DeathNoteFiltersTab3", filters_tab, "OptionsFrameTabButtonTemplate")
		auras_tab_button.ntab = 3
		auras_tab_button:SetPoint("TOPLEFT", healing_tab_button, "TOPRIGHT", -16, 0)
		auras_tab_button:SetText("Auras")
		auras_tab_button:SetFrameLevel(2)

		tabtext = DeathNoteFiltersTab3Text
		tabtext:ClearAllPoints()
		tabtext:SetPoint("LEFT", 14, -3)
		tabtext:SetPoint("RIGHT", -12, -3)

		local auras_tab_spacer1 = filters_tab:CreateTexture(nil, "BORDER")
		auras_tab_spacer1:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		auras_tab_spacer1:SetVertexColor(0.4, 0.4, 0.4)
		auras_tab_spacer1:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		auras_tab_spacer1:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
		auras_tab_spacer1:SetPoint("TOPRIGHT", auras_tab_button, "BOTTOMLEFT", 10, 0)
		
		local auras_tab_spacer2 = filters_tab:CreateTexture(nil, "BORDER")
		auras_tab_spacer2:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		auras_tab_spacer2:SetVertexColor(0.4, 0.4, 0.4)
		auras_tab_spacer2:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		auras_tab_spacer2:SetPoint("TOPLEFT", auras_tab_button, "BOTTOMRIGHT", -10, 3)
		auras_tab_spacer2:SetPoint("TOPRIGHT", topright, "TOPLEFT")
		
		local auras_options = {
			type = "group",
			inline = true,
			args = {
				display = {
					order = 1,
					name = "Auras",
					type = "group",
					inline = true,
					args = {
						buff_gains = {
							order = 1,
							type = "toggle",
							name = "Buff gains",
							get = function() return DeathNote.settings.display_filters.buff_gains end,
							set = function(_, v) DeathNote:SetDisplayFilter("buff_gains", v) end,
						},
						buff_fades = {
							order = 2,
							type = "toggle",
							name = "Buff fades",
							get = function() return DeathNote.settings.display_filters.buff_fades end,
							set = function(_, v) DeathNote:SetDisplayFilter("buff_fades", v) end,
						},
						debuff_gains = {
							order = 3,
							type = "toggle",
							name = "Debuff gains",
							get = function() return DeathNote.settings.display_filters.debuff_gains end,
							set = function(_, v) DeathNote:SetDisplayFilter("debuff_gains", v) end,
						},
						debuff_fades = {
							order = 4,
							type = "toggle",
							name = "Debuff fades",
							get = function() return DeathNote.settings.display_filters.debuff_fades end,
							set = function(_, v) DeathNote:SetDisplayFilter("debuff_fades", v) end,
						},
						survival_buffs = {
							order = 5,
							type = "toggle",
							name = "Survival cooldowns",
							get = function() return DeathNote.settings.display_filters.survival_buffs end,
							set = function(_, v) DeathNote:SetDisplayFilter("survival_buffs", v) end,
						},
						highlight_survival = {
							order = 6,
							name = "Highlight survival cooldowns",
							type = "toggle",
							-- width = "double",
							get = function() return DeathNote.settings.display_filters.highlight_survival end,
							set = function(_, v) DeathNote:SetDisplayFilter("highlight_survival", v) end,
						},
					},
				},
				consolidate = {
					order = 2,
					name = "Consolidate consecutive auras",
					type = "toggle",
					width = "double",
					get = function() return DeathNote.settings.display_filters.consolidate_auras end,
					set = function(_, v) DeathNote:SetDisplayFilter("consolidate_auras", v) end,
				},
			},
		}
		
		local auras_tab = AceGUI:Create("SimpleGroup")
		auras_tab.frame:SetParent(filters_tab)
		auras_tab.frame:SetScale(0.9)
		auras_tab:SetPoint("TOPLEFT", 8, -8)
		auras_tab:SetPoint("BOTTOMRIGHT", -8, 8)
		AceConfig:RegisterOptionsTable("Death Note - Auras", auras_options)
		AceConfigDialog:Open("Death Note - Auras", auras_tab)
		
		-- others tab
		local others_tab_button = CreateFrame("Button", "DeathNoteFiltersTab4", filters_tab, "OptionsFrameTabButtonTemplate")
		others_tab_button.ntab = 4
		others_tab_button:SetPoint("TOPLEFT", auras_tab_button, "TOPRIGHT", -16, 0)
		others_tab_button:SetText("Other")
		others_tab_button:SetFrameLevel(2)

		tabtext = DeathNoteFiltersTab4Text
		tabtext:ClearAllPoints()
		tabtext:SetPoint("LEFT", 14, -3)
		tabtext:SetPoint("RIGHT", -12, -3)

		local others_tab_spacer1 = filters_tab:CreateTexture(nil, "BORDER")
		others_tab_spacer1:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		others_tab_spacer1:SetVertexColor(0.4, 0.4, 0.4)
		others_tab_spacer1:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		others_tab_spacer1:SetPoint("TOPLEFT", topleft, "TOPRIGHT")
		others_tab_spacer1:SetPoint("TOPRIGHT", others_tab_button, "BOTTOMLEFT", 10, 0)
		
		local others_tab_spacer2 = filters_tab:CreateTexture(nil, "BORDER")
		others_tab_spacer2:SetTexture([[Interface\Tooltips\UI-Tooltip-Border]])
		others_tab_spacer2:SetVertexColor(0.4, 0.4, 0.4)
		others_tab_spacer2:SetTexCoord(0.625-0.0625, 0.628, 0, 1)
		others_tab_spacer2:SetPoint("TOPLEFT", others_tab_button, "BOTTOMRIGHT", -10, 3)
		others_tab_spacer2:SetPoint("TOPRIGHT", topright, "TOPLEFT")
		
		local function format_filter(f)
			local t = {}
			for k, v in pairs(f) do
				table.insert(t, v)
			end
			table.sort(t)
			return table.concat(t, ",")
		end
		
		local others_options = {
			type = "group",
			inline = true,
			args = {
				spell = {
					order = 1,
					name = "Spell filter",
					desc = "Enter one or more spells, separated by commas.\nCtrl+Click on a spell column to add that spell.",
					type = "input",
					width = "full",
					get = function() return format_filter(DeathNote.settings.display_filters.spell_filter) end,
					set = function(_, v) DeathNote:SetDisplayFilter("spell_filter", v) end,
				},
				source = {
					order = 2,
					name = "Source filter",
					desc = "Enter one or more sources, separated by commas.\nCtrl+Click on a source column to add that source.",
					type = "input",
					width = "full",
					get = function() return format_filter(DeathNote.settings.display_filters.source_filter) end,
					set = function(_, v) DeathNote:SetDisplayFilter("source_filter", v) end,
				},
				reset = {
					order = 3,
					name = "Reset",
					type = "execute",
					width = "half",
					func = function() DeathNote:SetDisplayFilter("spell_filter", "") DeathNote:SetDisplayFilter("source_filter", "") end,
				},
			},
		}
		
		local others_tab = AceGUI:Create("SimpleGroup")
		others_tab.frame:SetParent(filters_tab)
		others_tab.frame:SetScale(0.9)
		others_tab:SetPoint("TOPLEFT", 8, -8)
		others_tab:SetPoint("BOTTOMRIGHT", -8, 8)
		AceConfig:RegisterOptionsTable("Death Note - Others", others_options)
		AceConfigDialog:Open("Death Note - Others", others_tab)

		-- final tab setup
		self.filters_label = filters_label
		self.filters_frame = filters_frame
		self.filters_tab = filters_tab

		self.damage_tab = damage_tab
		self.healing_tab = healing_tab
		self.auras_tab = auras_tab
		self.others_tab = others_tab
		
		self.damage_tab_spacer1 = damage_tab_spacer1
		self.healing_tab_spacer1 = healing_tab_spacer1
		self.healing_tab_spacer2 = healing_tab_spacer2
		self.auras_tab_spacer1 = auras_tab_spacer1
		self.auras_tab_spacer2 = auras_tab_spacer2
		self.others_tab_spacer1 = others_tab_spacer1
		self.others_tab_spacer2 = others_tab_spacer2
		
		PanelTemplates_SetNumTabs(filters_tab, 4)
		
		filters_tab:SetScript("OnSizeChanged", function(frame, width, height)
				damage_tab:SetWidth(width - 16)
				damage_tab:SetHeight(height - 16)
				
				healing_tab:SetWidth(width - 16)
				healing_tab:SetHeight(height - 16)
				
				auras_tab:SetWidth(width - 16)
				auras_tab:SetHeight(height - 16)
				
				others_tab:SetWidth(width - 16)
				others_tab:SetHeight(height - 16)
			end)

		local function Tab_OnClick(frame)
			DeathNote:SetFiltersTab(frame.ntab)
		end
		
		damage_tab_button:SetScript("OnClick", Tab_OnClick)
		healing_tab_button:SetScript("OnClick", Tab_OnClick)
		auras_tab_button:SetScript("OnClick", Tab_OnClick)
		others_tab_button:SetScript("OnClick", Tab_OnClick)
		
		Tab_OnClick(damage_tab_button)

		self.collapsed = true
		filters_title:SetScript("OnMouseUp", function() DeathNote:ToggleFiltersFrame() end)
		
		-- tools frame
		local tools_frame = CreateFrame("Frame", nil, filters_frame)
		tools_frame:SetPoint("TOPRIGHT", -8, -9)
		tools_frame:SetWidth(12)
		tools_frame:SetHeight(12)
		tools_frame:EnableMouse()
		
		local tools_icon = tools_frame:CreateTexture(nil, "OVERLAY")
		tools_icon:SetAllPoints()
		tools_icon:SetTexture([[Interface\AddOns\DeathNote\Textures\gear.tga]])		
		
		self.tools_frame = tools_frame
		tools_frame:SetScript("OnMouseUp", function() self:ShowToolsMenu() end)
		
		-- name list
		local name_list_border = CreateFrame("Frame", nil, frame)
		name_list_border:SetPoint("TOPLEFT", filters_frame, "BOTTOMLEFT", 0, 0)
		name_list_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", self.settings.display.namelist_width, 10)
		
		name_list_border:SetBackdrop(PaneBackdrop)
		name_list_border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
		name_list_border:SetBackdropBorderColor(0.4, 0.4, 0.4)
		name_list_border:SetResizable(true)
		name_list_border:SetMinResize(50, 50)
		name_list_border:SetMaxResize(2000, 2000)
		
		local name_list = CreateFrame("ScrollFrame", nil, name_list_border)
		name_list:SetPoint("TOPLEFT", 8, -8)
		name_list:SetPoint("BOTTOMRIGHT", -8, 8)
		name_list:EnableMouseWheel(true)
		
		-- name list scrollbar
		local name_scroll = CreateFrame("Slider", nil, name_list, "UIPanelScrollBarTemplate")
		name_scroll:SetPoint("BOTTOMRIGHT", name_list_border, "BOTTOMRIGHT", -8, 24)
		name_scroll:SetPoint("TOPRIGHT", name_list_border, "TOPRIGHT", -8, -24)
		name_scroll:SetMinMaxValues(0, 1000)
		name_scroll:SetValueStep(1)
		name_scroll:SetValue(0)
		name_scroll:SetWidth(16)
		name_scroll:SetFrameLevel(6)
		name_scroll:Hide()
		
		local name_scrollbg = name_scroll:CreateTexture(nil, "BACKGROUND")
		name_scrollbg:SetAllPoints()
		name_scrollbg:SetTexture(0, 0, 0, 1)

		local name_content = CreateFrame("Frame", nil, name_list)
		name_list:SetScrollChild(name_content)
		name_content:SetPoint("TOPLEFT")
		name_content:SetPoint("TOPRIGHT")		
		
		name_list:SetScript("OnMouseWheel", function(frame, value)
			local l, h = name_scroll:GetMinMaxValues()
			name_scroll:SetValue(min(max(name_scroll:GetValue() - value*45, l), h))
		end)
		
		name_scroll:SetScript("OnValueChanged", function(frame, value)
			name_content:SetPoint("TOPLEFT", 0, value)
			name_content:SetPoint("TOPRIGHT", 0, value)
		end)
		
		self.name_list_border = name_list_border
		self.name_list = name_list
		self.name_content = name_content
		self.name_scroll = name_scroll
		self.name_items = {}
		
		name_list:SetScript("OnSizeChanged", function() self:NameList_SizeChanged() end)
		
		-- dragger
		local dragger = CreateFrame("Frame", nil, name_list_border)
		dragger:SetWidth(8)
		dragger:SetPoint("TOP", name_list_border, "TOPRIGHT")
		dragger:SetPoint("BOTTOM", name_list_border, "BOTTOMRIGHT")
		dragger:SetBackdrop(DraggerBackdrop)
		dragger:SetBackdropColor(1, 1, 1, 0)
		dragger:EnableMouse(true)

		local function Dragger_OnLeave(frame)
			frame:SetBackdropColor(1, 1, 1, 0)
		end

		local function Dragger_OnEnter(frame)
			frame:SetBackdropColor(1, 1, 1, 0.8)
		end

		local function Dragger_OnMouseDown(frame)
			name_list_border:StartSizing("RIGHT")
		end

		local function Dragger_OnMouseUp()
			name_list_border:StopMovingOrSizing()
			name_list_border:SetUserPlaced(false)
			
			local width = name_list_border:GetWidth() + 10
			name_list_border:ClearAllPoints()
			name_list_border:SetPoint("TOPLEFT", filters_frame, "BOTTOMLEFT", 0, 0)
			name_list_border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", width, 10)
			self.settings.display.namelist_width = width
		end

		dragger:SetScript("OnEnter", Dragger_OnEnter)
		dragger:SetScript("OnLeave", Dragger_OnLeave)
		dragger:SetScript("OnMouseDown", Dragger_OnMouseDown)
		dragger:SetScript("OnMouseUp", Dragger_OnMouseUp)

		-- logframe
		local logframe = self:CreateListBox(frame, self.settings.display.scale)
		logframe.frame:SetPoint("TOPLEFT", name_list_border, "TOPRIGHT")
		logframe.frame:SetPoint("BOTTOM", name_list_border, "BOTTOM")
		logframe.frame:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
		
		self.logframe = logframe
		
		logframe:AddColumn("Time", "RIGHT", self.settings.display.columns[1])
		logframe:AddColumn("HP", "CENTER", self.settings.display.columns[2])
		logframe:AddColumn("Amount", "RIGHT", self.settings.display.columns[3])
		logframe:AddColumn("Spell", "LEFT", self.settings.display.columns[4])
		logframe:AddColumn("Source", "LEFT")
		
		logframe:SetSettingsCallback(
			function(columns)
				self.settings.display.columns = columns
			end,
			function(scale)
				self.settings.display.scale = scale
			end)
			
		logframe:SetMouseCallbacks(
			function(button, line, column, userdata)
				if IsModifiedClick("CHATLINK") then
					if column == 1 then -- Time
						ChatEdit_InsertLink(self:FormatChatTimestamp(userdata))
					elseif column == 2 then -- HP
						ChatEdit_InsertLink(self:FormatChatHealth(userdata))
					elseif column == 3 then -- Amount
						ChatEdit_InsertLink(self:FormatChatAmount(userdata))
					elseif column == 4 then -- Spell
						ChatEdit_InsertLink(self:FormatChatSpell(userdata))
					elseif column == 5 then -- Source
						ChatEdit_InsertLink(self:FormatChatSource(userdata))
					end
				elseif button == "LeftButton" then
					if IsControlKeyDown() then
						if column == 4 then
							self:AddSpellFilter(userdata)
						elseif column == 5 then
							self:AddSourceFilter(userdata)
						end
					else
						if column == 1 then
							self:CycleTimestampDisplay()
						elseif column == 2 then
							self:CycleHealthDisplay()
						elseif column == 3 then
						elseif column == 4 then
							self:SetSpellHilight(userdata)
						elseif column == 5 then
							self:SetSourceHilight(userdata)
						end
						
						self:RefreshDeath()
					end
				elseif button == "RightButton" then
					-- menu
					self.dropdown_line = line
					self:ShowLineMenu()
				end
			end,
			function(column, userdata)
				local have_tip = false
				GameTooltip:SetOwner(logframe.frame, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOMLEFT", logframe.frame, "BOTTOMRIGHT")

				if column == 1 then -- Time
					have_tip = self:FormatTooltipTimestamp(userdata)
				elseif column == 2 then -- HP
					have_tip = self:FormatTooltipHealth(userdata)
				elseif column == 3 then -- Amount
					have_tip = self:FormatTooltipAmount(userdata)
				elseif column == 4 then -- Spell
					have_tip = self:FormatTooltipSpell(userdata)
				elseif column == 5 then -- Source
					have_tip = self:FormatTooltipSource(userdata)
				end				
				
				if have_tip then
					GameTooltip:Show()
				end
			end,
			function(column, userdata)
				GameTooltip:Hide()
			end)

			-- hide on escape
			--[[
			local org_CloseSpecialWindows = CloseSpecialWindows
			CloseSpecialWindows = function()
				if not org_CloseSpecialWindows() then
					local found = frame:IsShown() and 1
					frame:Hide()
					return found
				end
			end
			]]
			local org_CloseAllWindows = CloseAllWindows
			CloseAllWindows = function(ignoreCenter)
				local ret = org_CloseAllWindows(ignoreCenter)
				if not ignoreCenter then
					if frame:IsShown() then
						frame:Hide()
						ret = true
					end
				end
				return ret
			end
		
		self.frame = frame
	end

	self.frame:Show()
	self:UpdateNameList()
end

-- Filters UI		
function DeathNote:SetFiltersTab(ntab)
	self.filters_tab.selectedTab = ntab
	PanelTemplates_UpdateTabs(self.filters_tab)
	
	-- this shouldn't be hardcoded
	if ntab == 1 then
		self.damage_tab_spacer1:Show()
		self.healing_tab_spacer1:Hide()
		self.healing_tab_spacer2:Hide()
		self.auras_tab_spacer1:Hide()
		self.auras_tab_spacer2:Hide()
		self.others_tab_spacer1:Hide()
		self.others_tab_spacer2:Hide()
		
		self.damage_tab.frame:Show()
		self.healing_tab.frame:Hide()
		self.auras_tab.frame:Hide()
		self.others_tab.frame:Hide()
	elseif ntab == 2 then
		self.damage_tab_spacer1:Hide()
		self.healing_tab_spacer1:Show()
		self.healing_tab_spacer2:Show()
		self.auras_tab_spacer1:Hide()
		self.auras_tab_spacer2:Hide()
		self.others_tab_spacer1:Hide()
		self.others_tab_spacer2:Hide()
		
		self.damage_tab.frame:Hide()
		self.healing_tab.frame:Show()
		self.auras_tab.frame:Hide()
		self.others_tab.frame:Hide()
	elseif ntab == 3 then
		self.damage_tab_spacer1:Hide()
		self.healing_tab_spacer1:Hide()
		self.healing_tab_spacer2:Hide()
		self.auras_tab_spacer1:Show()
		self.auras_tab_spacer2:Show()
		self.others_tab_spacer1:Hide()
		self.others_tab_spacer2:Hide()
		
		self.damage_tab.frame:Hide()
		self.healing_tab.frame:Hide()
		self.auras_tab.frame:Show()
		self.others_tab.frame:Hide()
	elseif ntab == 4 then
		self.damage_tab_spacer1:Hide()
		self.healing_tab_spacer1:Hide()
		self.healing_tab_spacer2:Hide()
		self.auras_tab_spacer1:Hide()
		self.auras_tab_spacer2:Hide()
		self.others_tab_spacer1:Show()
		self.others_tab_spacer2:Show()
		
		self.damage_tab.frame:Hide()
		self.healing_tab.frame:Hide()
		self.auras_tab.frame:Hide()
		self.others_tab.frame:Show()
	end
end
		
function DeathNote:ToggleFiltersFrame(show)
	if show ~= nil then
		self.collapsed = show
	end
	
	if self.collapsed then
		self.filters_label:SetText(filters_label_open)
		self.filters_frame:SetHeight(175)
		self.filters_tab:Show()
	else
		self.filters_label:SetText(filters_label_closed)
		self.filters_frame:SetHeight(30)
		self.filters_tab:Hide()
	end
	
	self.collapsed = not self.collapsed
end

function DeathNote:ShowFiltersTab(ntab)
	self:SetFiltersTab(ntab)
	self:ToggleFiltersFrame(true)
end
		
------------------------------------------------------------------------------
-- UnitPopup support
------------------------------------------------------------------------------

function DeathNote:ShowUnit(name)
	self:Show()
	
	for i = 1, #self.name_items do
		if self.name_items[i]:IsShown() then
			local userdata = self.name_items[i].userdata
			if userdata[3] == name then
				self.name_scroll:SetValue((i - 3) * 18)
				self.name_items[i]:Click()
				return
			end
		end
	end
end

function DeathNote:AddToUnitPopup()
	UnitPopupButtons["SHOW_DEATH_NOTE"] = {
		text = "Show Death Note",
		icon = [[Interface\AddOns\DeathNote\Textures\icon.tga]],
		dist = 0,
	}

	local types = { "PET", "RAID_PLAYER", "PARTY", "SELF", "TARGET" }
	
	for i, v in ipairs(types) do
		tinsert(UnitPopupMenus[v], #UnitPopupMenus[v], "SHOW_DEATH_NOTE")
	end
	
	self:SecureHook("UnitPopup_ShowMenu")
end

function DeathNote:RemoveFromUnitPopup()
	self:Unhook("UnitPopup_ShowMenu")
	
	for mtype in pairs(UnitPopupMenus) do
		for i = #UnitPopupMenus[mtype], 1, -1 do
			if UnitPopupMenus[mtype][i] == "SHOW_DEATH_NOTE" then
				tremove(UnitPopupMenus[mtype], i)
				break
			end
		end
	end

	UnitPopupButtons["SHOW_DEATH_NOTE"] = nil
end

function DeathNote.UnitPopupClick()
	local name, server = UnitName(UIDROPDOWNMENU_INIT_MENU.unit or UIDROPDOWNMENU_INIT_MENU.name)
	
	if not name then
		return
	end
	
	if server and server ~= "" then
		name = name .. "-" .. server
	end
	
	DeathNote:Debug("unit:", UIDROPDOWNMENU_INIT_MENU.unit, "name:", UIDROPDOWNMENU_INIT_MENU.name, "result:", name)
	
	DeathNote:ShowUnit(name)
end

function DeathNote:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
	local button
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		if button.value == "SHOW_DEATH_NOTE" then
		    button.func = DeathNote.UnitPopupClick
		end
	end
end

------------------------------------------------------------------------------
-- Tools menu
------------------------------------------------------------------------------

 function DeathNote:ShowToolsMenu()
	if not self.tools_dropdownframe then
		self.tools_dropdownframe = CreateFrame("Frame", nil, nil, "UIDropDownMenuTemplate")		
		self.tools_dropdownframe.displayMode = "MENU"
		self.tools_dropdownframe.initialize = self.ToolsDropDownInitialize				
	end
	
	ToggleDropDownMenu(1, nil, self.tools_dropdownframe, self.tools_frame, 0, 0)
 
 end

function DeathNote.ToolsDropDownInitialize(self, level) 
 	local info = {}
	
	if not level then return end

	if level == 1 then
		info.text = "Sort deaths by"
		info.value = "DL_ORDER"
		info.hasArrow = 1
		info.notCheckable = 1
		info.func = function() DeathNote:ResetData() end
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.disabled = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.text = "Time format"
		info.value = "COL_TIME"
		info.hasArrow = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		info.text = "Health format"
		info.value = "COL_HEALTH"
		info.hasArrow = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.disabled = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.text = "Options"
		info.value = "OPTIONS"
		info.notCheckable = 1
		info.func = function() InterfaceOptionsFrame_OpenToCategory("Death Note") end
		UIDropDownMenu_AddButton(info, level)

		wipe(info)
		info.disabled = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
		
		wipe(info)
		info.text = "Reset data"
		info.value = "RESETDATA"
		info.notCheckable = 1
		info.func = function() DeathNote:ResetData() end
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "COL_TIME" then
			info.text = "Seconds from death"
			info.checked = function() return DeathNote.settings.display.timestamp == 1 end
			info.func = function() DeathNote:SetTimestampDisplay(1) end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Real time"
			info.checked = function() return DeathNote.settings.display.timestamp == 2 end
			info.func = function() DeathNote:SetTimestampDisplay(2) end
			UIDropDownMenu_AddButton(info, level)		
		elseif UIDROPDOWNMENU_MENU_VALUE == "COL_HEALTH" then
			info.text = "Bar"
			info.checked = function() return DeathNote.settings.display.health == 1 end
			info.func = function() DeathNote:SetHealthDisplay(1) end
			UIDropDownMenu_AddButton(info, level)

			info.text = "HP %"
			info.checked = function() return DeathNote.settings.display.health == 2 end
			info.func = function() DeathNote:SetHealthDisplay(2) end
			UIDropDownMenu_AddButton(info, level)
			
			info.text = "HP"
			info.checked = function() return DeathNote.settings.display.health == 3 end
			info.func = function() DeathNote:SetHealthDisplay(3) end
			UIDropDownMenu_AddButton(info, level)

			info.text = "HP/HPMax"
			info.checked = function() return DeathNote.settings.display.health == 4 end
			info.func = function() DeathNote:SetHealthDisplay(4) end
			UIDropDownMenu_AddButton(info, level)
		elseif UIDROPDOWNMENU_MENU_VALUE == "DL_ORDER" then
			info.text = "Name"
			info.checked = function() return DeathNote.settings.display.namelist == 1 end
			info.func = function() DeathNote:SetNameListDisplay(1) end
			UIDropDownMenu_AddButton(info, level)

			info.text = "Time"
			info.checked = function() return DeathNote.settings.display.namelist == 2 end
			info.func = function() DeathNote:SetNameListDisplay(2) end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

------------------------------------------------------------------------------
-- Display stuff
------------------------------------------------------------------------------

function DeathNote:SetNameListDisplay(n)
	self.settings.display.namelist = n
	DeathNote:UpdateNameList()
	DeathNote:ScrollNameListToCurrentDeath()
end

function DeathNote:SetTimestampDisplay(n)
	self.settings.display.timestamp = n
	self:RefreshDeath()
end

function DeathNote:SetHealthDisplay(n)
	self.settings.display.health = n
	self:RefreshDeath()
end
 
------------------------------------------------------------------------------
-- Line menu
------------------------------------------------------------------------------

function DeathNote:ShowLineMenu(line)
	if not self.dropdownframe then
		self.dropdownframe = CreateFrame("Frame", nil, nil, "UIDropDownMenuTemplate")		
		self.dropdownframe.displayMode = "MENU"
		self.dropdownframe.initialize = self.LineDropDownInitialize				
	end
	
	ToggleDropDownMenu(1, nil, self.dropdownframe, "cursor")
end

function DeathNote.LineDropDownInitialize(self, level)
	local info = {}
	
	if not level then return end

	if level == 1 then
		info.text = "Send report from this line"
		info.hasArrow = 1
		info.value = "REPORT"
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
		if UIDROPDOWNMENU_MENU_VALUE == "REPORT" then
			info.text = "Say"
			info.func = function() DeathNote:SendReport("SAY") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = "Party"
			info.func = function() DeathNote:SendReport("PARTY") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = "Raid"
			info.func = function() DeathNote:SendReport("RAID") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = "Guild"
			info.func = function() DeathNote:SendReport("GUILD") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = "Officer"
			info.func = function() DeathNote:SendReport("OFFICER") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)

			info.text = "Whisper target"
			info.func = function() DeathNote:SendReport("WHISPER") end
			info.notCheckable = 1
			UIDropDownMenu_AddButton(info, level)
		end
	end

end

------------------------------------------------------------------------------
-- Name list
------------------------------------------------------------------------------

function DeathNote:NameList_SizeChanged()
	local content_height = self.name_content:GetHeight()
	local height = self.name_list:GetHeight()
		
	if height >= content_height then
		self.name_list:SetPoint("BOTTOMRIGHT", -8, 8)
		self.name_scroll:SetMinMaxValues(0, 0)
		self.name_scroll:Hide()
	else
		self.name_list:SetPoint("BOTTOMRIGHT", -8, 8)
		self.name_scroll:SetMinMaxValues(0, content_height - height)
		self.name_scroll:Show()
	end
end

local function NameList_OnClick(frame, button)
	if button == "LeftButton" then
		DeathNote:ShowDeath(frame.userdata)

		for i = 1, #DeathNote.name_items do
			DeathNote.name_items[i]:UnlockHighlight() 
		end

		frame:LockHighlight()
	elseif button == "RightButton" then
		DeathNote:CycleNameListDisplay()
		DeathNote:UpdateNameList()
		DeathNote:ScrollNameListToCurrentDeath()
	end
end

local function NameList_OnEnter(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT")

	local entry = DeathNote:GetKillingBlow(frame.userdata)

	local have_tip = entry and DeathNote:FormatTooltipAmount(entry)
	
	if have_tip then
		GameTooltip:Show()
	end
end

local function NameList_OnLeave(frame)
	GameTooltip:Hide()
end

function DeathNote:ScrollNameListToCurrentDeath()
	if not self.current_death then
		self.name_scroll:SetValue(0)
		return
	end
	
	for i = 1, #self.name_items do
		if self.name_items[i]:IsShown() then
			local userdata = self.name_items[i].userdata
			if userdata == self.current_death then
				self.name_scroll:SetValue((i - 3) * 18)
				return
			end
		end
	end
end

local GetSortedDeathList = {}

function SortDeathsByNameFunc(a, b)
	return a[3] > b[3] or (a[3] == b[3] and a[1] < b[1])
end

GetSortedDeathList[1] = function()
	-- by name
	local deaths = {}
	for _, v in ipairs(DeathNoteData.deaths) do
		table.insert(deaths, v)
	end
	
	table.sort(deaths, SortDeathsByNameFunc)
	
	return deaths
end

GetSortedDeathList[2] = function()
	-- by time
	return DeathNoteData.deaths
end

function DeathNote:CycleNameListDisplay()
	self.settings.display.namelist = self.settings.display.namelist % #GetSortedDeathList + 1
end

function DeathNote:UpdateNameList()
	if not self.frame or not self.frame:IsShown() then
		return
	end
	
	for i = 1, #self.name_items do
		self.name_items[i].userdata = nil
		self.name_items[i]:Hide()
	end
	
	local deaths = GetSortedDeathList[self.settings.display.namelist]()

	local count = #deaths
	for i = 1, count do
		local v = deaths[count - i + 1]
		
		if not self.name_items[i] then
			local button = CreateFrame("Button", "DeathNoteNameListButton" .. i, self.name_content, "OptionsListButtonTemplate")
			
			button:SetNormalFontObject(GameFontNormal)
			button:SetHighlightFontObject(GameFontHighlight)

			button:SetScript("OnClick", NameList_OnClick)
			button:SetScript("OnEnter", NameList_OnEnter)
			button:SetScript("OnLeave", NameList_OnLeave)
			button:SetScript("OnDoubleClick", nil)
						
			button:SetPoint("TOPLEFT", 0, -18 * (i - 1))
			button:SetPoint("RIGHT")
			
			self.name_items[i] = button
		end
		
		local btn = self.name_items[i]
		
		btn.userdata = v
		btn:GetFontString():SetText(self:FormatNameListEntry(v))
		if self.current_death == v then
			btn:LockHighlight()
		else
			btn:UnlockHighlight()
		end
				
		btn:Show()
	end

	self.name_content:SetHeight(18 * count)
	self:NameList_SizeChanged()
end

------------------------------------------------------------------------------
-- ShowDeath
------------------------------------------------------------------------------

function DeathNote:ShowDeath(death)
	if self.settings.debugging then debugprofilestart() end

	self.current_source_hilight = nil
	self.current_spell_hilight = nil

	self.logframe:ClearAllLines()

	self.current_death = death
	
	self:ResetFiltering()
	
	for entry in self:IterateDeath(death, self.settings.death_time) do
		self:ProcessDeathEntry(entry)
	end
	
	self:ProcessDeathEntry(nil)
	self.logframe:UpdateComplete()
	self.logframe:ScrollToBottom()
	
	if self.settings.debugging then self:Debug(string.format("Death shown in %.02f ms (%i lines)", debugprofilestop(), self.logframe:GetLineCount())) end
end


local function IsGroupEntry(entry)
	return type(entry[1]) == "table"
end

local prev
local group -- { { entries }, "type", hp, hpmax, t1, t2, { spells }, { sources } }
function DeathNote:ProcessDeathEntry(entry)
	if entry then
		local filtered, highlight_spellid = self:IsEntryFiltered(entry)
		if filtered then
			if self:IsEntryOverThreshold(entry) then
				self:AddDeathEntry(entry, highlight_spellid)
			end
		end
	else
	end
end

function DeathNote:AddDeathEntry(entry, highlight_spellid)
	local line = self:FormatEntry(entry)
	
	if line then
		local nline = self.logframe:AddLine(line, entry)

		if highlight_spellid then
			local highlight = self.SurvivalColors[self.SurvivalIDs[highlight_spellid]]
			self.logframe:SetLineHighlight(nline, highlight)
		end
	end
end

function DeathNote:RefreshDeath()
	local count = self.logframe:GetLineCount()
	
	for i = 1, count do
		self.logframe:UpdateLine(i, self:FormatEntry(self.logframe:GetLineUserdata(i)))
	end
end

function DeathNote:RefreshFilters()
	if self.current_death then
		self:ShowDeath(self.current_death)
	end
end

function DeathNote:AddSpellFilter(entry)
	local _, spellname = self:GetEntrySpell(entry)

	if spellname then
		self.settings.display_filters.spell_filter[string.lower(spellname)] = spellname
		LibStub("AceConfigDialog-3.0"):Open("Death Note - Others", self.others_tab)
		self:RefreshFilters()
		self:ShowFiltersTab(4)
	end
end

function DeathNote:AddSourceFilter(entry)
	local source = entry[6] or ""
	
	self.settings.display_filters.source_filter[string.lower(source)] = source
	LibStub("AceConfigDialog-3.0"):Open("Death Note - Others", self.others_tab)
	self:RefreshFilters()
	self:ShowFiltersTab(4)
end

function DeathNote:SetSpellHilight(entry)
	local spellid = self:GetEntrySpell(entry)
	
	local count = self.logframe:GetLineCount()
	for i = 1, count do
		local userdata = self.logframe:GetLineUserdata(i)
		
		if not spellid or spellid == self.current_spell_hilight then
			self.logframe:SetLineHighlight(i, nil)
		else		
			self.logframe:SetLineHighlight(i, self:GetEntrySpell(userdata) == spellid and spell_hilight)
		end
	end

	self.current_source_hilight = nil
	self.current_spell_hilight = self.current_spell_hilight ~= spellid and spellid or nil
end

function DeathNote:SetSourceHilight(entry)
	local source = entry[5]
	
	local count = self.logframe:GetLineCount()
	for i = 1, count do
		local userdata = self.logframe:GetLineUserdata(i)
		
		if source == self.current_source_hilight then
			self.logframe:SetLineHighlight(i, nil)
		else
			self.logframe:SetLineHighlight(i, userdata[5] == source and source_hilight)
		end
	end
	
	self.current_source_hilight = self.current_source_hilight ~= source and source or nil
	self.current_spell_hilight = nil
end

------------------------------------------------------------------------------
-- Display filters
------------------------------------------------------------------------------

function DeathNote:SetDisplayFilter(filter, value)
	if filter == "spell_filter" or filter == "source_filter" then
		local result = {}
		value = string.gsub(value, "^%s*(.-)%s*$", "%1")
		if #value > 0 then
			for v in string.gmatch(value, "([^,]+),?") do
				local r = string.gsub(v, "^%s*(.-)%s*$", "%1") or ""
				result[string.lower(r)] = r
			end
		end
		value = result
	end
	
	self.settings.display_filters[filter] = value
	
	self:RefreshFilters()
end

------------------------------------------------------------------------------
-- ListBox
------------------------------------------------------------------------------

local function ListBox_Column_Dragger_OnLeave(frame)
	frame.background:SetTexture(0.7, 0.7, 0.7, 0.8)
end

local function ListBox_Column_Dragger_OnEnter(frame)
	frame.background:SetTexture(1, 1, 1, 1)
end

local function ListBox_Column_Dragger_OnMouseDown(frame)
	local lastcol = frame.obj.columns[#frame.obj.columns]
	
	frame.prev:SetMaxResize(frame.prev:GetWidth() + lastcol:GetWidth(), 1)

	frame.prev:StartSizing("RIGHT")
end

local function ListBox_PlaceColumn(self, column, prev, width)	
	column:ClearAllPoints()
	
	if not prev then
		column:SetPoint("TOPLEFT", self.iframe, "TOPLEFT", 8, -8)
		column:SetPoint("BOTTOMRIGHT", self.iframe, "BOTTOMLEFT", width + 8, 8)
	else
		column:SetPoint("TOPLEFT", prev, "TOPRIGHT")
		if width then
			column:SetPoint("RIGHT", prev, "RIGHT", width, 0)
		else
			column:SetPoint("RIGHT", self.content, "RIGHT", 0, 0)
		end
	end
	
	column:SetPoint("BOTTOM", self.scrollframe, "BOTTOM")
end

local function ListBox_Column_Dragger_OnMouseUp(frame)
	local self = frame.obj
	local prev = frame.prev
	local prevprev = frame.prevprev
	
	prev:StopMovingOrSizing()
	prev:SetUserPlaced(false)
	
	ListBox_PlaceColumn(self, prev, prevprev, prev:GetWidth())
	
	if self.columns_callback then
		local t = {}
		for i = 1, #self.columns - 1 do
			table.insert(t, self.columns[i]:GetWidth())
		end
		self.columns_callback(t)
	end
end

local function ListBox_AddColumn(self, label, align, width)
	local column = CreateFrame("Frame", nil, self.iframe)
	column.align = align
	column:SetResizable(true)
	column:SetMinResize(10, 1)
	
	local prev = self.columns[#self.columns]

	ListBox_PlaceColumn(self, column, prev, width)

	local fs = column:CreateFontString(nil, "OVERLAY")
	fs:SetFontObject(GameFontNormal)
	fs:SetPoint("TOPLEFT", column, "TOPLEFT", 3, 0)
	fs:SetPoint("BOTTOMRIGHT", column, "TOPRIGHT", -3, -18)
	fs:SetText(label)
	
	if prev then
		local dragger = CreateFrame("Frame", nil, self.iframe)
		dragger:SetWidth(2)
		dragger:SetPoint("TOP", prev, "TOPRIGHT")
		dragger:SetPoint("BOTTOM", prev, "BOTTOM")

		dragger.background = dragger:CreateTexture(nil, "OVERLAY")
		dragger.background:SetAllPoints()
		dragger.background:SetTexture(0.7, 0.7, 0.7, 0.8)
		
		dragger.obj = self
		dragger.prev = prev
		dragger.prevprev = self.columns[#self.columns - 1]

		dragger:EnableMouse(true)		
		dragger:SetScript("OnMouseDown", ListBox_Column_Dragger_OnMouseDown)
		dragger:SetScript("OnMouseUp", ListBox_Column_Dragger_OnMouseUp)
		dragger:SetScript("OnEnter", ListBox_Column_Dragger_OnEnter)
		dragger:SetScript("OnLeave", ListBox_Column_Dragger_OnLeave)
	end
	
	table.insert(self.columns, column)
end

function ListBox_SetMouseCallbacks(self, onmouseup, onenter, onleave)
	self.column_onmouseup = onmouseup
	self.column_onenter = onenter
	self.column_onleave = onleave
end

function ListBox_Column_OnMouseUp(frame, button)
	if frame.line.obj.column_onmouseup then
		frame.line.obj.column_onmouseup(button, frame.nline, frame.column, frame.line.userdata)
	end
end

function ListBox_Column_OnEnter(frame)
	if not frame.line.static_hili then
		frame.line.hili:Show()
	else
		frame.line.hili:SetTexture(normal_hilight.r, normal_hilight.g, normal_hilight.b, normal_hilight.a)
	end
	
	if frame.line.obj.column_onenter then
		frame.line.obj.column_onenter(frame.column, frame.line.userdata)
	end
end

function ListBox_Column_OnLeave(frame)
	if not frame.line.static_hili then
		frame.line.hili:Hide()
	else
		frame.line.hili:SetTexture(frame.line.static_hili.r, frame.line.static_hili.g, frame.line.static_hili.b, frame.line.static_hili.a)
	end
	
	if frame.line.obj.column_onleave then
		frame.line.obj.column_onleave(frame.column, frame.line.userdata)
	end
end

local function ListBox_CreateLine(self)
	local nline = #self.lines + 1
	local line = self.line_cache[nline]
	
	if not line then
		line = CreateFrame("Frame", nil, self.content)
		line:Hide()
		line:SetHeight(12)
		line.obj = self
		
		local hili = line:CreateTexture(nil, "OVERLAY")
		hili:Hide()
		hili:SetTexture(normal_hilight.r, normal_hilight.g, normal_hilight.b, normal_hilight.a)
		hili:SetAllPoints()
		hili:SetBlendMode("ADD")
		line.hili = hili
		
		line.columns = {}
		for i, c in ipairs(self.columns) do
			local f = CreateFrame("Frame", nil, line)
			f.nline = nline
			f.line = line
			f.column = i
			f:SetHeight(12)
			f:SetPoint("TOP", line, "TOP")
			--f:SetPoint("BOTTOM", line, "BOTTOM")
			f:SetPoint("LEFT", c, "LEFT", 3, 0)
			f:SetPoint("RIGHT", c, "RIGHT", -3, 0)
			f:SetScript("OnMouseUp", ListBox_Column_OnMouseUp)
			f:SetScript("OnEnter", ListBox_Column_OnEnter)
			f:SetScript("OnLeave", ListBox_Column_OnLeave)
			
			line.columns[i] = f
		end
		
		table.insert(self.line_cache, line)
	end
	
	table.insert(self.lines, line)
	
	return line
end

local function ListBox_AddLine(self, values, userdata)
	local line = self:CreateLine()
	
	line.userdata = userdata
	
	self:UpdateLine(#self.lines, values)
	
	return #self.lines
end

function ListBox_UpdateComplete(self)
	ListBox_ScrollFrame_OnSizeChanged(self.scrollframe)

	for nline = #self.lines, 1, -1 do
		local line = self.lines[nline]
		local prev = self.lines[nline + 1]

		if not prev then
			line:SetPoint("TOPLEFT", self.content, "TOPLEFT", 0, -4)
			line:SetPoint("RIGHT", self.content, "RIGHT", 0, 0)
		else
			line:SetPoint("TOPLEFT", prev, "BOTTOMLEFT")
			line:SetPoint("RIGHT", prev, "RIGHT")
		end
		
		self.lines[nline]:Show()
	end	
end

local function ListBox_Line_Column_OnSizeChanged(frame)
	if frame.bartex then
		if frame.value and frame.value > 0 then
			local width = (frame:GetWidth() - 2) * frame.value
			frame.bartex:SetWidth(width)
			frame.bartex:Show()
		else
			frame.bartex:Hide()
		end
	end
end

local function ListBox_UpdateLine(self, nline, values)
	local line = self.lines[nline]
	
	for i, c in ipairs(self.columns) do
		if type(values[i]) == "table" then
			if line.columns[i].fs then
				line.columns[i].fs:Hide()
			end

			if not line.columns[i].bartex then
				line.columns[i]:SetScript("OnSizeChanged", ListBox_Line_Column_OnSizeChanged)				
				line.columns[i].bartex = line.columns[i]:CreateTexture(nil, "BACKGROUND")
				line.columns[i].bartex:SetPoint("TOPLEFT", line.columns[i], "TOPLEFT", 1, -3)
				line.columns[i].bartex:SetPoint("BOTTOM", line.columns[i], "BOTTOM", 0, 3)
				line.columns[i].bartex:SetTexture(1, 0, 0)
			end
			
			line.columns[i].bartex:Show()
			line.columns[i].value = values[i][1]
			ListBox_Line_Column_OnSizeChanged(line.columns[i])
			line.columns[i]:SetScript("OnSizeChanged", ListBox_Line_Column_OnSizeChanged)
		else
			if line.columns[i].bartex then
				line.columns[i]:SetScript("OnSizeChanged", nil)
				line.columns[i].bartex:Hide()
				line.columns[i].value = nil
			end
			
			if not line.columns[i].fs then
				local fs = line.columns[i]:CreateFontString(nil, "OVERLAY")
				fs:SetAllPoints(line.columns[i])
				fs:SetFontObject(GameFontNormalSmall)
				fs:SetShadowColor(0, 0, 0, 0)
				fs:SetJustifyH(c.align)
				line.columns[i].fs = fs
			end
			
			line.columns[i].fs:Show()
			line.columns[i].fs:SetText(values[i])
		end
	end
end

local function ListBox_SetLineHighlight(self, nline, color)
	local line = self.lines[nline]
	
	if color then
		line.static_hili = color
		line.hili:SetTexture(color.r, color.g, color.b, color.a)
		line.hili:Show()
	elseif line.static_hili then
		line.static_hili = nil
		line.hili:SetTexture(normal_hilight.r, normal_hilight.g, normal_hilight.b, normal_hilight.a)
		line.hili:Hide()
	end
end

local function ListBox_ClearAllLines(self)
	for i = 1, #self.lines do
		self.lines[i].userdata = nil
		self.lines[i].static_hili = nil
		self.lines[i].hili:SetTexture(normal_hilight.r, normal_hilight.g, normal_hilight.b, normal_hilight.a)
		self.lines[i].hili:Hide()
		self.lines[i]:Hide()
	end
	
	wipe(self.lines)
end

function ListBox_ScrollFrame_OnSizeChanged(frame)
	local self = frame.obj
	
	-- Update Scrollbar	
	local height = self.scrollframe:GetHeight()
	local content_height = #self.lines * 12 + 8

	self.content:SetHeight(content_height)
	
	local cscale = self.content:GetScale()
	
	content_height = content_height * cscale
	
	
	if height >= content_height then
		self.content:SetPoint("TOPRIGHT")
		self.scrollbar:SetMinMaxValues(0, 0)
		self.scrollbar:Hide()
	else
		self.content:SetPoint("TOPRIGHT", -20, 0)
		self.scrollbar:SetMinMaxValues(0, content_height - height)
		self.scrollbar:Show()
	end
end

local function ListBox_SetScale(self, scale)
	DeathNote:Print(string.format("Setting scale to %i%%", floor(scale * 100 + 0.5)))
	self.content:SetScale(scale)
	
	ListBox_ScrollFrame_OnSizeChanged(self.scrollframe)
	
	if self.scale_callback then
		self.scale_callback(scale)
	end
end

local function ListBox_ScrollFrame_OnMouseWheel(frame, value)
	local self = frame.obj
	
	if IsControlKeyDown() then
		local scale = self.content:GetScale() + 0.05 * -value
		if scale >= 0.5 and scale <= 2.0 then
			ListBox_SetScale(self, scale)
		end
	else	
		local l, h = self.scrollbar:GetMinMaxValues()
		self.scrollbar:SetValue(min(max(self.scrollbar:GetValue() - value * 36 * self.content:GetScale(), l), h))
	end
end
	
local function ListBox_ScrollBar_OnValueChanged(frame, value)
	local self = frame.obj

	value = value / self.content:GetScale()
	self.content:SetPoint("TOPLEFT", 0, value)
end

local function ListBox_ScrollToBottom(self)
	if self.scrollbar:IsShown() then
		self.scrollbar:SetValue(select(2, self.scrollbar:GetMinMaxValues()))
	end
end

local function ListBox_GetLineCount(self)
	return #self.lines
end

local function ListBox_GetLineUserdata(self, line)
	return self.lines[line].userdata
end

local function ListBox_SetSettingsCallback(self, columns_callback, scale_callback)
	self.columns_callback = columns_callback
	self.scale_callback = scale_callback
end

function DeathNote:CreateListBox(parent, scale)
	local frame = CreateFrame("ScrollFrame", nil, parent)	
	
	local iframe = CreateFrame("Frame", nil, frame)
	iframe:SetBackdrop(PaneBackdrop)
	iframe:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	iframe:SetBackdropBorderColor(0.4, 0.4, 0.4)
	
	frame:SetScrollChild(iframe)
	iframe:SetAllPoints()
	
	local scrollframe = CreateFrame("ScrollFrame", nil, iframe)
	scrollframe:SetPoint("TOPLEFT", 8, -32)
	scrollframe:SetPoint("BOTTOMRIGHT", -8, 8)
	scrollframe:EnableMouseWheel(true)
	scrollframe:SetScript("OnMouseWheel", ListBox_ScrollFrame_OnMouseWheel)
	scrollframe:SetScript("OnSizeChanged", ListBox_ScrollFrame_OnSizeChanged)
		
	local scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate")
	scrollbar:SetPoint("BOTTOMRIGHT",  0, 16)
	scrollbar:SetPoint("TOPRIGHT", 0, -16)
	scrollbar:SetMinMaxValues(0, 0)
	scrollbar:SetValueStep(1)
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:SetScript("OnValueChanged", ListBox_ScrollBar_OnValueChanged)
	scrollbar:Hide()
	
	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints()
	scrollbg:SetTexture(0, 0, 0, 1)		

	local content = CreateFrame("Frame", nil, scrollframe)
	scrollframe:SetScrollChild(content)
	content:SetPoint("TOPLEFT")
	content:SetPoint("TOPRIGHT", -16, 0)
	content:SetScale(scale)
	
	local headersep = CreateFrame("Frame", nil, iframe)
	headersep:SetHeight(16)
	headersep:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -22)
	headersep:SetPoint("RIGHT")
	headersep:SetBackdrop(DraggerBackdrop)
	headersep:SetBackdropColor(1, 1, 1, 1)	
	
	local listbox = {
		AddColumn = ListBox_AddColumn,
		AddLine = ListBox_AddLine,
		ClearAllLines = ListBox_ClearAllLines,
		SetSettingsCallback = ListBox_SetSettingsCallback,
		SetMouseCallbacks = ListBox_SetMouseCallbacks,
		CreateLine = ListBox_CreateLine,
		ScrollToBottom = ListBox_ScrollToBottom,
		GetLineCount = ListBox_GetLineCount,
		GetLineUserdata = ListBox_GetLineUserdata,
		UpdateLine = ListBox_UpdateLine,
		SetLineHighlight = ListBox_SetLineHighlight,
		UpdateComplete = ListBox_UpdateComplete,

		frame = frame,
		iframe = iframe,
		content = content,
		scrollbar = scrollbar,
		scrollframe = scrollframe,

		columns = {},
		lines = {},
		line_cache = {},
	}
	
	frame.obj = listbox
	iframe.obj = listbox
	scrollbar.obj = listbox
	scrollframe.obj = listbox
	
	return listbox
end
