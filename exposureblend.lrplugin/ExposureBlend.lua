local LrApplication = import 'LrApplication'
local LrApplicationView = import 'LrApplicationView'
local LrDevelopController = import 'LrDevelopController'
local LrDialogs = import 'LrDialogs'
local LrErrors = import 'LrErrors'
local LrFunctionContext = import 'LrFunctionContext'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LrProgressScope = import 'LrProgressScope'
local LrTasks = import 'LrTasks'

local max_iterations = 20
local evCurveCoefficent = 2 / math.log(2)

local log = LrLogger('exportLogger')
log:enable("print")

--replace the default assert behavior to use LrErrors.throwUserError
local assertOriginal = assert
local function assert(condition, message)
  if condition ~= true then
    if message == nil then 
      assertOriginal(condition)
    else
      LrErrors.throwUserError(message)
    end
  end
end

local function convertToEV(value)
    return evCurveCoefficent * math.log(value);
end






local function work_on_range(range, catalog, progress, startIndex, totalCount)
  local count = #range

  
  photo = range[1] 
  currentFilename = photo:getFormattedMetadata("fileName")
  catalog:setSelectedPhotos(photo,{})
  local sel_photo = catalog:getTargetPhoto()
  while currentFilename ~= sel_photo:getFormattedMetadata("fileName") do
     sel_photo = catalog:getTargetPhoto()
  end
  local startValue = LrDevelopController.getValue("Exposure") 


  photo = range[count]
  currentFilename = photo:getFormattedMetadata("fileName")
  catalog:setSelectedPhotos(photo,{})
  local sel_photo = catalog:getTargetPhoto()
  while currentFilename ~= sel_photo:getFormattedMetadata("fileName") do
     sel_photo = catalog:getTargetPhoto()
  end
  local endValue = LrDevelopController.getValue("Exposure") 

  progress:setPortionComplete(startIndex, totalCount)
  log:trace("ExposureBlendRange called", count)
  
  for i,photo in ipairs(range) do

      currentFilename = photo:getFormattedMetadata("fileName")

      catalog:setSelectedPhotos(photo,{})

      -- ugly workaround to wait for the correct image to be selected.
      sel_photo = catalog:getTargetPhoto()
      while currentFilename ~= sel_photo:getFormattedMetadata("fileName") do
        sel_photo = catalog:getTargetPhoto()
      end

      local target = startValue + (endValue - startValue) * ((i-1) / (count-1))
      local ev = convertToEV(target)

      log:tracef("Picture: %s %f %f %f", currentFilename, startValue, endValue, target)
      --offset = LrDevelopController.getValue("Exposure")

      LrDevelopController.startTracking()
      LrDevelopController.setValue("Exposure", target)
      LrDevelopController.stopTracking()

      if progress:isCanceled() then LrErrors.throwCanceled() end

      progress:setPortionComplete(startIndex + i, totalCount)
  end
end

local function ExposureBlend(context)
  log:trace("ExposureBlend started")
  LrDialogs.attachErrorDialogToFunctionContext(context)
  local catalog = LrApplication.activeCatalog();
  local selection = catalog:getTargetPhotos();
  local count = #selection
  assert(count > 2, "Not enough photos selected")
  
  local progress = LrProgressScope { title="ExposureBlend", functionContext = context }
  
  LrApplicationView.switchToModule("develop")
  
  local range = {}
  local lastStartIndex = 1
  
  for i,photo in ipairs(selection) do
    if i == count then
      range[#range + 1] = photo
      work_on_range(range, catalog, progress, lastStartIndex, count)
      lastStartIndex = i
      range = {}
    end
    range[#range + 1] = photo
  end
  
  catalog:setSelectedPhotos(selection[1],selection)
  progress:done()
  log:trace("exposureblend finished")

end

LrFunctionContext.postAsyncTaskWithContext("ExposureBlend", ExposureBlend)


