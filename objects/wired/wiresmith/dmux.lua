function init()
  entity.setInteractive(false)
  if storage.state == nil then
    output(false)
  else
    if storage.state then
      entity.setAnimationState("switchState", "on")
    else
      entity.setAnimationState("switchState", "off")
    end
  end
  self.bits = entity.configParameter("bits")
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    if state then
      entity.setAnimationState("switchState", "on")
    else
      entity.setAnimationState("switchState", "off")
    end
  end
end

function controlSwitch()
  local state = false
  local muxChannel = 0
  for bit=0,self.bits/2-1 do
    if entity.getInboundNodeLevel(bit+1) then
      muxChannel = muxChannel + 2^bit
    end
    state = true
  end
  output(state)
  return muxChannel
end

function update(dt)
  local muxChannel = controlSwitch()
  for bit=0,self.bits-1 do
    if bit == muxChannel then
      entity.setOutboundNodeLevel(bit, entity.getInboundNodeLevel(0))
    else
      entity.setOutboundNodeLevel(bit, false)
    end
  end
end
