
require "/scripts/messageutil.lua"

function init()
  effect.modifyDuration(math.huge)

  message.setHandler("bigballoons_adjustTint", simpleHandler(newTint))
  self.tintCode = "FFFFFF"
end

function newTint(hexCode)
  self.tintCode = hexCode
end

function update(dt)
  effect.setParentDirectives("?multiply="..self.tintCode)
end
