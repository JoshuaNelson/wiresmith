function init(args)
  entity.setInteractive(false)
  if storage.state == nil then
    output(false)
  else
    output(storage.state)
  end
  self.bits = entity.configParameter("bits")
end

-- Change Animation
function output(state)
  if state ~= storage.state then
    storage.state = state
    if state then
      entity.setAnimationState("switchState", "on")
    else
      entity.setAnimationState("switchState", "off")
    end
  end
end

function update(dt)
  local state = false
  for bit=0,self.bits-1 do
    if entity.getInboundNodeLevel(bit) then
      state = true
      break
    end
  end
  entity.setAllOutboundNodes(state)
  output(state)
end
