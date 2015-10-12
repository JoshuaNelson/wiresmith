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
  self.encodedBits = 2^self.bits
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

function updateEncoderOutput(encoderOutputNode)
  for node=0,self.encodedBits-1 do
    entity.setOutboundNodeLevel(node, (encoderOutputNode == node))
  end
end

function update(dt)
  local state = false
  local encoderOutputNode = 0
  for bit=0,self.bits-1 do
    if entity.getInboundNodeLevel(bit) then
     encoderOutputNode = encoderOutputNode + 2^bit
     state = true
    end
  end
  updateEncoderOutput(encoderOutputNode)
  output(state)
end
