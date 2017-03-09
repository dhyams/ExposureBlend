local LrPrefs = import 'LrPrefs'

local defaultPrefValues = 
{
  dummyvar1 = 1,
  dummyvar2 = 1
}

local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
for k,v in pairs(defaultPrefValues) do
  if prefs[k] == nil then prefs[k] = v end
end
