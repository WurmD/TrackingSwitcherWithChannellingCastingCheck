TrackingSwitcher = LibStub("AceAddon-3.0"):NewAddon("TrackingSwitcher", "AceTimer-3.0", "AceConsole-3.0")
TrackingSwitcher.lastCastEndTime = 0 -- Initialize a variable to store the last cast end time

local trackingValues = {
    minerals = 'Find Minerals',
    herbs = 'Find Herbs',
}

local hunterValues = {
    minerals = 'Find Minerals',
    herbs = 'Find Herbs',
    hidden = 'Track Hidden',
    beasts = 'Track Beasts',
    dragonkin = 'Track Dragonkin',
    elementals = 'Track Elementals',
    undead = 'Track Undead',
    giants = 'Track Giants',
    humanoids = 'Track Humanoids',
}

local druidValues = {
    minerals = 'Find Minerals',
    herbs = 'Find Herbs',
    humanoids_druid = 'Track Humanoids'
}

local classTrackingValues = trackingValues;

local playerClass, englishClass = UnitClass("player");

if englishClass == 'DRUID' then
    classTrackingValues = druidValues
elseif englishClass == 'HUNTER' then
    classTrackingValues = hunterValues
end

race, raceEn = UnitRace("player");

if raceEn == 'Dwarf' then
    classTrackingValues['treasure'] = 'Find Treasure'
end

local options = {
    name = 'TrackingSwitcher',
    handler = TrackingSwitcher,
    type = 'group',
    args = {
        type1 = {
            name = "First Type",
            desc = "First type to swap between",
            type = "select",
            values = classTrackingValues,
            get = 'GetType1',
            set = 'SetType1',
        },
        type2 = {
            name = "Second Type",
            desc = "Second type to swap between",
            type = "select",
            values = classTrackingValues,
            get = 'GetType2',
            set = 'SetType2',
        },
        castInterval = {
            name = "Toggle Interval",
            desc = "Time in seconds between toggle casts",
            type = "range",
            min = 2,
            max = 45,
            step = 1,
            get = 'GetCastInterval',
            set = 'SetCastInterval',
            width = "full"
        }
    }
}


local defaults = {
    profile  = {
        type1 = "minerals",
        type2 = "herbs",
    }
}

function TrackingSwitcher:OnInitialize()
    print('Thank you for using TrackingSwitcher, write /ts to enable. To change tracking types use /ts opt')

    self.db = LibStub("AceDB-3.0"):New("TrackingSwitcherCharDB", defaults, true)

    LibStub('AceConfig-3.0'):RegisterOptionsTable('TrackingSwitcher', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('TrackingSwitcher', 'TrackingSwitcher')
    self:RegisterChatCommand('ts', 'ChatCommand')
    self:RegisterChatCommand('trackingswitcher', 'ChatCommand')

    -- Set default values
    TrackingSwitcher.type1 = "minerals";
    TrackingSwitcher.type2 = "herbs";
    TrackingSwitcher.castInterval = "2";
    TrackingSwitcher.IS_RUNNING = false;
end

function TrackingSwitcher:ChatCommand(input)
    --print('ChatCommand(' .. tostring(input) .. ')');
    if not input or input:trim() == "" then
        TrackingSwitcher:ToggleTracking();
    else
        if(input:trim() == 'opt') then
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
        else
            print('Did you mean "/ts opt"? To start simply type "/ts"');
        end
    end
end

function TrackingSwitcher:ToggleTracking(input)
    if TrackingSwitcher.IS_RUNNING then TrackingSwitcher:StopTimer(); TrackingSwitcher.IS_RUNNING = false else TrackingSwitcher:StartTimer() TrackingSwitcher.IS_RUNNING = true end
end

function TrackingSwitcher:StartTimer()
    print('Starting TrackingSwitcher, to stop type /ts again');

    self.trackingTimer = self:ScheduleRepeatingTimer('TimerFeedback', TrackingSwitcher:GetCastInterval())
end

function TrackingSwitcher:StopTimer()
    print('Stopping TrackingSwitcher, to start type /ts again');

    self:CancelTimer(self.trackingTimer);
end

function TrackingSwitcher:TimerFeedback()
    -- Find Minerals - 136025
    -- Find Herbs  - 133939
    -- Track Hidden  - 132320
    -- Track Beasts  - 132328
    -- Track Dragonkin  - 134153
    -- Track Elementals  - 135861
    -- Track Undead  - 136142
    -- Track Demons  - 136217
    -- Track Giants  - 132275
    -- Track Humanoids  - 135942
    -- Track Humanoids (Druid)  - 132328
    -- Find Treasure (Dwarf) - 135725
    local trackingIDs = {
        minerals = {
            id = 136025,
            spellName = "Find Minerals"
        },
        herbs = {
            id = 133939,
            spellName = "Find Herbs"
        },
        hidden = {
            id = 132320,
            spellName = "Track Hidden"
        },
        beasts = {
            id = 132328,
            spellName = "Track Beasts"
        },
        dragonkin = {
            id = 134153,
            spellName = "Track Dragonkin"
        },
        elementals = {
            id = 135861,
            spellName = "Track Elementals"
        },
        undead = {
            id = 136142,
            spellName = "Track Undead"
        },
        demons = {
            id = 136217,
            spellName = "Track Demons"
        },
        giants = {
            id = 132275,
            spellName = "Track Giants"
        },
        humanoids = {
            id = 135942,
            spellName = "Track Humanoids"
        },
        humanoids_druid = {
            id = 132328,
            spellName = "Track Humanoids"
        },
        treasure = {
            id = 135725,
            spellName = "Find Treasure"
        }
    }

    local currentTrackingIcon = GetTrackingTexture();
    local currentTime = GetTime() -- Get the current time

    spell_channeling_name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo("player")
    spell_casting_name, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("player")
    should_not_switch = spell_channeling_name ~= nil or spell_casting_name ~= nil or IsFalling() or UnitAffectingCombat("player")
    --print("spell_channeling_name " .. tostring(spell_channeling_name) .. ", spell_casting_name "
    --    .. tostring(spell_casting_name) .. ", IsFalling " .. tostring(IsFalling()) .. ", UnitAffectingCombat "
    --    .. tostring(UnitAffectingCombat("player")) .. ": should_not_switch " .. tostring(should_not_switch))
    if should_not_switch then
        TrackingSwitcher.lastCastEndTime = currentTime + 5 -- Store the end time plus 5 seconds delay
    end

    if not should_not_switch and currentTime >= TrackingSwitcher.lastCastEndTime then
        if currentTrackingIcon ~= trackingIDs[TrackingSwitcher:GetType1()].id then
            CastSpellByName(trackingIDs[TrackingSwitcher:GetType1()].spellName);
        else
            CastSpellByName(trackingIDs[TrackingSwitcher:GetType2()].spellName);
        end
    end
end



function TrackingSwitcher:GetCastInterval(info)
    if self.db.profile.castInterval == nil or self.db.profile.castInterval == '' then
        return tonumber(TrackingSwitcher.castInterval)
    end

    return tonumber(self.db.profile.castInterval)
end

function TrackingSwitcher:SetCastInterval(info, newValue)
    self.db.profile.castInterval = newValue
end

function TrackingSwitcher:GetType1(info)
    if self.db.profile.type1 == nil or self.db.profile.type1 == '' then
        return TrackingSwitcher.type1
    end

    return self.db.profile.type1
end

function TrackingSwitcher:SetType1(info, newValue)
    self.db.profile.type1 = newValue
end

function TrackingSwitcher:GetType2(info)
    if self.db.profile.type2 == nil or self.db.profile.type2 == '' then
        return TrackingSwitcher.type2
    end

    return self.db.profile.type2
end

function TrackingSwitcher:SetType2(info, newValue)
    self.db.profile.type2 = newValue
end

-- Fix to get options page to open correct
do
    local function get_panel_name(panel)
        local tp = type(panel)
        local cat = INTERFACEOPTIONS_ADDONCATEGORIES
        if tp == "string" then
            for i = 1, #cat do
                local p = cat[i]
                if p.name == panel then
                    if p.parent then
                        return get_panel_name(p.parent)
                    else
                        return panel
                    end
                end
            end
        elseif tp == "table" then
            for i = 1, #cat do
                local p = cat[i]
                if p == panel then
                    if p.parent then
                        return get_panel_name(p.parent)
                    else
                        return panel.name
                    end
                end
            end
        end
    end

    local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
        if doNotRun or InCombatLockdown() then return end
        local panelName = get_panel_name(panel)
        if not panelName then return end -- if its not part of our list return early
        local noncollapsedHeaders = {}
        local shownpanels = 0
        local mypanel
        local t = {}
        local cat = INTERFACEOPTIONS_ADDONCATEGORIES
        for i = 1, #cat do
            local panel = cat[i]
            if not panel.parent or noncollapsedHeaders[panel.parent] then
                if panel.name == panelName then
                    panel.collapsed = true
                    t.element = panel
                    InterfaceOptionsListButton_ToggleSubCategories(t)
                    noncollapsedHeaders[panel.name] = true
                    mypanel = shownpanels + 1
                end
                if not panel.collapsed then
                    noncollapsedHeaders[panel.name] = true
                end
                shownpanels = shownpanels + 1
            end
        end
        local Smin, Smax = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
        if shownpanels > 15 and Smin < Smax then
            local val = (Smax/(shownpanels-15))*(mypanel-2)
            InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
        end
        doNotRun = true
        InterfaceOptionsFrame_OpenToCategory(panel)
        doNotRun = false
    end

    hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", InterfaceOptionsFrame_OpenToCategory_Fix)
end

function TrackingSwitcher:UnitChannelInfo(unit)
    if UnitIsUnit(unit, "player") then return ChannelInfo() end
        local guid = UnitGUID(unit)
        local cast = casters[guid]
        if cast then
            local castType, name, icon, startTimeMS, endTimeMS, spellID = unpack(cast)
            -- Curse of Tongues doesn't matter that much for channels, skipping
            if castType == "CHANNEL" and endTimeMS > GetTime()*1000 then
                return name, nil, icon, startTimeMS, endTimeMS, nil, false, spellID
            end
    end
end
