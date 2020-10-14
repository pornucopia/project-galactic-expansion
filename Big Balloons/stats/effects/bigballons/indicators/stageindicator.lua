
require "/scripts/messageutil.lua"

function init()
  effect.modifyDuration(math.huge)

  stage = config.getParameter("stage", -1)

  message.setHandler("bigballoons_checkIndicator", simpleHandler(checkIndicator))
end

function checkIndicator(newStage)
  if newStage ~= stage then
    effect.expire()
  end
end
