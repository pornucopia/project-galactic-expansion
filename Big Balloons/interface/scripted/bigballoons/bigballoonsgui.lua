
function init()
  conf = root.assetJson("/scripts/player/bigballoons/bigballoons.config")
  stat = player.getProperty("bigballoons", {})
  sliderSteps = config.getParameter("sliderSteps", 10)

  for _, s in ipairs(conf.substances) do
    widget.setSliderRange(s.."Slider", 0, sliderSteps)
    widget.setSliderValue(s.."Slider", (stat.substanceAmounts[s] or 0) * sliderSteps)
  end
end

function update(dt)
  sb.logInfo("update()")
end

function updateSubstances()
  local amounts = {}

  for _, s in ipairs(conf.substances) do
    amounts[s] = widget.getSliderValue(s.."Slider") / sliderSteps
  end

  player.setProperty("bigballoons", {substanceAmounts = amounts})
end
