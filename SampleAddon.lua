------------------------------------------------------------------------------------------------
-- SampleAddon.lua
------------------------------------------------------------------------------------------------
require "Window"

-----------------------------------------------------------------------------------------------
-- SampleAddon Definition
-----------------------------------------------------------------------------------------------
local SampleAddon= {}
local Utils = Apollo.GetPackage("SimpleUtils-1.0").tPackage

-----------------------------------------------------------------------------------------------
-- SampleAddon constants
-----------------------------------------------------------------------------------------------
local Major, Minor, Patch, Suffix = 1, 1, 0, 0
local AddonName = "SampleAddon"
local SAMPLEADDON_CURRENT_VERSION = string.format("%d.%d.%d%s", Major, Minor, Patch)

local tDefaultSettings = {
  version = SAMPLEADDON_CURRENT_VERSION,
  user = {
    debug = false
  },
  positions = {
    main = nil
  }
}

local tDefaultState = {
  isOpen = false,
  windows = {           -- These store windows for lists
    main = nil
  }
}

-----------------------------------------------------------------------------------------------
-- SampleAddon Constructor
-----------------------------------------------------------------------------------------------
function SampleAddon:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- Saved and Restored values are stored here.
  o.settings = shallowcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermanent and not saved between sessions
  o.state = shallowcopy(tDefaultState)

  return o
end


-----------------------------------------------------------------------------------------------
-- SampleAddon Init
-----------------------------------------------------------------------------------------------
function SampleAddon:Init()
  local bHasConfigureFunction = true
  local strConfigureButtonText = AddonName
  local tDependencies = {
    -- "UnitOrPackageName",
  }
  Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)

  self.settings = shallowcopy(tDefaultSettings)
  -- Volatile values are stored here. These are impermanent and not saved between sessions
  self.state = shallowcopy(tDefaultState)
end

-----------------------------------------------------------------------------------------------
-- SampleAddon OnLoad
-----------------------------------------------------------------------------------------------
function SampleAddon:OnLoad()
  self.xmlDoc = XmlDoc.CreateFromFile("SampleAddon.xml")
  self.xmlDoc:RegisterCallback("OnDocLoaded", self)

  Apollo.RegisterEventHandler("Generic_SampleAddon", "OnToggleSampleAddon", self)
  Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)

  Apollo.RegisterSlashCommand("sample", "OnSlashCommand", self)
end

-----------------------------------------------------------------------------------------------
-- SampleAddon OnDocLoaded
-----------------------------------------------------------------------------------------------
function SampleAddon:OnDocLoaded()
  if self.xmlDoc == nil then
    return
  end

  self.state.windows.main = Apollo.LoadForm(self.xmlDoc, "MainWindow", nil, self)
  self.state.windows.main:Show(false)

  -- Restore positions and junk
  self:RefreshUI()
end

-----------------------------------------------------------------------------------------------
-- SampleAddon OnInterfaceMenuListHasLoaded
-----------------------------------------------------------------------------------------------
function SampleAddon:OnInterfaceMenuListHasLoaded()
  Event_FireGenericEvent("InterfaceMenuList_NewAddOn", AddonName, {"Generic_ToggleAddon", "", nil})

  -- Report Addon to OneVersion
  Event_FireGenericEvent("OneVersion_ReportAddonInfo", AddonName, Major, Minor, Patch, Suffix, false)
end

-----------------------------------------------------------------------------------------------
-- SampleAddon OnSlashCommand
-----------------------------------------------------------------------------------------------
-- Handle slash commands
function SampleAddon:OnSlashCommand(cmd, params)
  args = params:lower():split("[ ]+")

  if args[1] == "debug" then
    self:ToggleDebug()
  elseif args[1] == "show" then
    self:OnToggleSampleAddon()
  elseif args[1] == "defaults" then
    self:LoadDefaults()
  else
    Utils:cprint("SampleAddon v" .. self.settings.version)
    Utils:cprint("Usage:  /sample <command>")
    Utils:cprint("====================================")
    Utils:cprint("   show           Open Rules Window")
    Utils:cprint("   debug          Toggle Debug")
    Utils:cprint("   defaults       Loads defaults")
  end
end

-----------------------------------------------------------------------------------------------
-- Save/Restore functionality
-----------------------------------------------------------------------------------------------
function SampleAddon:OnSave(eType)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  return deepcopy(self.settings)
end

function SampleAddon:OnRestore(eType, tSavedData)
  if eType ~= GameLib.CodeEnumAddonSaveLevel.Character then return end

  if tSavedData and tSavedData.user then
    -- Copy the settings wholesale
    self.settings = deepcopy(tSavedData)

    -- Fill in any missing values from the default options
    -- This Protects us from configuration additions in the future versions
    for key, value in pairs(tDefaultSettings) do
      if self.settings[key] == nil then
        self.settings[key] = deepcopy(tDefaultSettings[key])
      end
    end

    -- This section is for converting between versions that saved data differently

    -- Now that we've turned the save data into the most recent version, set it
    self.settings.version = SAMPLEADDON_CURRENT_VERSION

  else
    self.tConfig = deepcopy(tDefaultOptions)
  end
end

-----------------------------------------------------------------------------------------------
-- Utility functionality
-----------------------------------------------------------------------------------------------
function SampleAddon:ToggleDebug()
  if self.settings.user.debug then
    self:PrintDB("Debug turned off")
    self.settings.user.debug = false
  else
    self.settings.user.debug = true
    self:PrintDB("Debug turned on")
  end
end

function SampleAddon:PrintDB(str)
  if self.settings.user.debug then
    Utils:debug(string.format("[%s]: %s", AddonName, str))
  end
end

---------------------------------------------------------------------------------------------------
-- SampleAddon General UI Functions
---------------------------------------------------------------------------------------------------
function SampleAddon:OnToggleSampleAddon()
  if self.state.isOpen == true then
    self.state.isOpen = false
    self:SaveLocation()
    self:CloseMain()
  else
    self.state.isOpen = true
    self.state.windows.main:Invoke() -- show the window
  end
end

function SampleAddon:SaveLocation()
  self.settings.positions.main = self.state.windows.main:GetLocation():ToTable()
end

function SampleAddon:CloseMain()
  self.state.windows.main:Close()
end

function SampleAddon:OnSampleAddonClose( wndHandler, wndControl, eMouseButton )
  self.state.isOpen = false
  self:SaveLocation()
  self:CloseMain()
end

function SampleAddon:OnSampleAddonClosed( wndHandler, wndControl )
  self:SaveLocation()
  self.state.isOpen = false
end

---------------------------------------------------------------------------------------------------
-- SampleAddon RefreshUI
---------------------------------------------------------------------------------------------------
function SampleAddon:RefreshUI()
  -- Location Restore
  if self.settings.positions.main ~= nil and self.settings.positions.main ~= {} then
    locSavedLoc = WindowLocation.new(self.settings.positions.main)
    self.state.windows.main:MoveToLocation(locSavedLoc)
  end
end

function SampleAddon:LoadDefaults()
  -- Load Defaults here
  self:RefreshUI()
end
-----------------------------------------------------------------------------------------------
-- SampleAddonInstance
-----------------------------------------------------------------------------------------------
local SampleAddonInst = SampleAddon:new()
SampleAddonInst:Init()
