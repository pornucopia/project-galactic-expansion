
require "/scripts/util.lua"

function init()
  conf = root.assetJson("/scripts/player/bigballoons/bigballoons.config")

  local startContents = {}
  for _, s in ipairs(conf.substances) do
    startContents[s] = 0.0
  end

  player.setProperty("bigballoons", {substanceAmounts = startContents})

  status.addEphemeralEffect("bbjuicetint")
end

function update(dt)
  applyEffects()
end

function applyEffects()
  local playerState = player.getProperty("bigballoons")
  local playerAmounts = playerState.substanceAmounts
  local effects = conf.substanceEffects
  local totalAmount = 0.0
  local fillAmount = 0.0

  local movementParameters = mcontroller.baseParameters()

  for _, s in ipairs(conf.substances) do
    local amount = playerAmounts[s]
    totalAmount = totalAmount + amount
    fillAmount = fillAmount + amount * (conf.amountFactors[s] or 1.0)

    for _, e in ipairs(conf.additiveEffects) do
      if effects[s][e] and movementParameters[e] then
        movementParameters[e] = movementParameters[e] + util.lerp(amount, 0.0, effects[s][e])
      end
    end
    for _, e in ipairs(conf.multiplicativeEffects) do
      if effects[s][e] and movementParameters[e] then
        movementParameters[e] = movementParameters[e] * util.lerp(amount, 1.0, effects[s][e])
      end
    end
    for _, e in ipairs(conf.jumpEffects) do
      if effects[s][e] and movementParameters['airJumpProfile'][e] then
        movementParameters['airJumpProfile'][e] = movementParameters['airJumpProfile'][e] + util.lerp(amount, 0.0, effects[s][e])
      end
    end
  end

  mcontroller.controlParameters(movementParameters)

  checkPop(fillAmount)

  local tintAmount = (playerAmounts['juice'] / totalAmount) * playerAmounts['juice'] * conf.tintMultiplier
  if playerAmounts['juice'] <= 0 then
    tintAmount = 0.0
  end
  applyTint(tintAmount)

  showIndicator(fillAmount)
end

function checkPop(amount)
  if amount <= 1.0 then
    return
  end

  -- TODO: implement the different popping types, with config
  -- TODO: effects

  -- fatal pop
  --status.setResourcePercentage("health", 0.0)
  --scaleAmounts(0.0)

  -- safe pop
  scaleAmounts(0.0)

  -- no pop -> scale amounts down?
  --scaleAmounts(1 / amount)
end

function scaleAmounts(factor)
  local playerState = player.getProperty("bigballoons")
  local amounts = playerState.substanceAmounts
  for _, s in ipairs(conf.substances) do
    amounts[s] = amounts[s] * factor
  end
  player.setProperty("bigballoons", playerState)
end

function applyTint(factor)
  factor = util.clamp(factor, 0.0, 1.0)

  local r = math.floor(util.lerp(factor, 255, conf.tintColor[1]))
  local g = math.floor(util.lerp(factor, 255, conf.tintColor[2]))
  local b = math.floor(util.lerp(factor, 255, conf.tintColor[3]))
  local tintString = toHex(r)..toHex(g)..toHex(b)

  -- doesn't work, maybe because it gets overridden in stats/player_primary.lua, lines 200-208
  -- status.setPrimaryDirectives("?multiply="..tintString)

  world.sendEntityMessage(player.id(), "bigballoons_adjustTint", tintString)
end

function showIndicator(amount)
  local stage = math.min(math.floor(amount / 0.18), 5)

  sb.setLogMap("^aqua;BigBallons_FillAmount", "%s", amount)
  sb.setLogMap("^aqua;BigBallons_Stage", "%s", stage)

  world.sendEntityMessage(player.id(), "bigballoons_checkIndicator", stage)
  status.addEphemeralEffect("bbstage"..stage)
end

function toHex(b)
  return string.format('%02X', b)
end
