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
  self.decodedBits = 2^self.bits
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

function updateDecoderOutput(decoderOutputValue)
  local carry = 0
  if decoderOutputValue == nil then
    entity.setAllOutboundNodes(false)
    return
  end
  for node=0,self.bits-1 do
    carry = decoderOutputValue % 2
    value = math.floor(decoderOutputValue / 2)
    decoderOutputValue = value
    entity.setOutboundNodeLevel(node, (carry >= 1))
  end
end

function update(dt)
  local state = false
  for bit=1,self.decodedBits do
    if entity.getInboundNodeLevel(self.decodedBits-bit) then
     updateDecoderOutput(self.decodedBits-bit)
     state = true
     return
    end
  end
  updateDecoderOutput(decoderOutputNode)
  output(state)
end
