function init(args)
  if not virtual then
    if storage.state == nil then
      output(false)
    else
      output(storage.state)
    end
  end
end

-- Change Animation
function output(state)
  if state ~= storage.state then
    storage.state = state
    if state then
      entity.setAnimationState("drainState", "on")
    else
      entity.setAnimationState("drainState", "off")
    end
  end
end

function update(dt)
  if entity.isOutboundNodeConnected(0) then
    output(true)
  else
    output(false)
  end
end
