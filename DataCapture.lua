local tinsert, tremove = table.insert, table.remove
local floor = math.floor

local log
local deaths

local event_handler_table = {
	["SPELL_DAMAGE"] 			= true,
	["SPELL_PERIODIC_DAMAGE"] 	= true,
	["SPELL_BUILDING_DAMAGE"] 	= true,
	["RANGE_DAMAGE"] 			= true,
	["DAMAGE_SHIELD"] 			= true,
	["DAMAGE_SPLIT"] 			= true,

	["SPELL_MISSED"] 			= true,
	["SPELL_PERIODIC_MISSED"] 	= true,
	["SPELL_BUILDING_MISSED"] 	= true,
	["DAMAGE_SHIELD_MISSED"] 	= true,

	["SWING_DAMAGE"] 			= true,
	
	["SWING_MISSED"] 			= true,

	["ENVIRONMENTAL_DAMAGE"] 	= true,

	["SPELL_HEAL"] 				= true,
	["SPELL_PERIODIC_HEAL"] 	= true,
	["SPELL_BUILDING_HEAL"] 	= true,
	
	["SPELL_AURA_APPLIED"]		= true,
	["SPELL_AURA_REMOVED"]		= true,
	["SPELL_AURA_APPLIED_DOSE"]	= true,
	["SPELL_AURA_REMOVED_DOSE"]	= true,
	["SPELL_AURA_REFRESH"]		= true,
	["SPELL_AURA_BROKEN"]		= true,
	["SPELL_AURA_BROKEN_SPELL"]	= true,
	
	["SPELL_CAST_START"]		= true,
	["SPELL_CAST_FAILED"]		= true,
	["SPELL_CAST_SUCCESS"]		= true,	
	
	["SPELL_DISPEL"]			= true,
	["SPELL_DISPEL_FAILED"]		= true,
	["SPELL_STOLEN"]			= true,
	
	["SPELL_INTERRUPT"] 		= true,

	["UNIT_DIED"] 				= true,
}

function DeathNote:DataCapture_Initialize()
	if not DeathNoteData then
		DeathNoteData = { log = {}, deaths = {} }
	end
	
	log = DeathNoteData.log
	deaths = DeathNoteData.deaths	
	self.captured_events = 0
end

function DeathNote:ResetData()
	wipe(log)
	wipe(deaths)
	self:UpdateNameList()
	print("Data reset")
end

function DeathNote:CanEraseTimestamp(timestamp)
	for i, d in ipairs(deaths) do
		local diff = d[1] - timestamp
		
		if diff >= 0 and diff <= self.settings.death_time then
			return false
		end
	end
	
	return true
end

function DeathNote:CleanData()
	while #deaths > self.settings.max_deaths do
		tremove(deaths, 1)
	end
	self:UpdateNameList()

	local min_time = deaths[1] and (deaths[1][1] - self.settings.death_time) or 0
	local max_time = time() - self.settings.death_time
	
	local num_cleared = 0
	
	debugprofilestart()
	
	for t, v in pairs(log) do
		if t < max_time then
			if t < min_time or self:CanEraseTimestamp(t) then
				num_cleared = num_cleared + #log[t]
				log[t] = nil
			end
		end
	end
	
	print(string.format("DeathNote: %i entries freed in %.02f ms", num_cleared, debugprofilestop()))
end

function DeathNote:PLAYER_REGEN_DISABLED()
	self:CancelTimer(self.clean_timer, true)
end

function DeathNote:PLAYER_REGEN_ENABLED()
	self.clean_timer = self:ScheduleTimer("CleanData", 5)
end

function DeathNote:PLAYER_LOGOUT()
end

function DeathNote:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	if event_handler_table[event] then
		local hp = destName and UnitHealth(destName) or 0
		local hpmax = destName and UnitHealthMax(destName) or 0
		local entry = { hp, hpmax, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ... }
		
		local t = floor(timestamp)
		
		if not log[t] then
			log[t] = {}
		end
		
		tinsert(log[t], entry)
		
		self.captured_events = self.captured_events + 1
	end
	
	if event == "UNIT_DIED" then
		if destName and not UnitIsFeignDeath(destName) then
			tinsert(deaths, { timestamp, destGUID, destName, destFlags })
			
			-- UpdateNameList does nothing when the frame is hidden
			self:UpdateNameList()
		end
	end
end
