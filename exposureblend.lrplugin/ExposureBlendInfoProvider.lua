local LrLogger = import 'LrLogger'
local LrPrefs = import 'LrPrefs'
local LrView = import 'LrView'

local myLogger = LrLogger('exportLogger')
myLogger:enable("print")

local function print( message )
  myLogger:trace( message )
end

local ExposureBlendInfoProvider = {}

function ExposureBlendInfoProvider.sectionsForTopOfDialog(viewFactory, propertyTable)
  local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
  local bind = LrView.bind
  return 
  {
    {
      title = LOC "$$$/ExposureBlend/Settings/Title=ExposureBlend Settings",
    }
  }
end

function ExposureBlendInfoProvider.sectionsForBottomOfDialog(viewFactory, propertyTable )
  local f = io.open(_PLUGIN:resourceId("LICENSE"), "r")
  local license = f:read("*a")
  f:close()
  return 
  {
    {
      title = LOC "$$$/ExposureBlend/License/Title=License",
      viewFactory:row 
      {
        viewFactory:static_text { title = license }
      }
    }
  }
end

return ExposureBlendInfoProvider
