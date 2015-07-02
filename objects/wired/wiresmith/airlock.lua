function init(args)
  self.inputs = enum{
    'sensor_init',
    'sensor_ready',
    'liquid_low',
    'liquid_high',
    'inner_door',
    'outer_door'
  }
  self.outputs = enum{
    'pump_in',
    'pump_out',
    'inner_door',
    'outer_door'
  }
  self.airlockStates = enum{
    'idle',
    'pressurize',
    'ready',
    'open',
    'recover'
  }
  entity.setInteractive(false)
  if storage.state == nil then
    storage.state = self.airlockStates.idle
  end
  output(storage.state)
end

-- Change Animation
function output(state)
  if state ~= storage.state then
    if storage.state > self.airlockStates.idle then
      entity.setAnimationState("switchState", "on")
    else
      entity.setAnimationState("switchState", "off")
    end
  end
end

function update(dt)
  if storage.state == self.airlockStates.idle then
    --[[ State: idle
         Active outbound nodes: nil
         Transitions: ready
    --]]
    if entity.getInboundNodeLevel(self.inputs.sensor_init) then
      -- Transition pressurize
      storage.state = self.airlockStates.ready
      entity.setOutboundNodeLevel(self.outputs.inner_door, true)
    end
  elseif storage.state == self.airlockStates.ready then
    --[[ State: ready
         Active outbound nodes: inner_door
         Transitions: pressurize, recover
    --]]
    if entity.getInboundNodeLevel(self.inputs.sensor_ready) and
        not entity.getInboundNodeLevel(self.inputs.sensor_init) then
      -- Transition to pressurize state
      storage.state = self.airlockStates.pressurize
      entity.setOutboundNodeLevel(self.outputs.inner_door, false)
      entity.setOutboundNodeLevel(self.outputs.pump_in, true)
    elseif not entity.getInboundNodeLevel(self.inputs.sensor_init) then
      -- Transition to recover state
      storage.state = self.airlockStates.recover
      entity.setOutboundNodeLevel(self.outputs.inner_door, false)
      entity.setOutboundNodeLevel(self.outputs.pump_out, true)
    end
  elseif storage.state == self.airlockStates.pressurize then
    --[[ State: pressurize
         Active outbound nodes: pump_in
         Transitions: open
    --]]
    -- XXX Possible to get someone stuck here if no liquid is being pumped
    if entity.getInboundNodeLevel(self.inputs.liquid_high) then
      -- Transition to open state
      storage.state = self.airlockStates.open
      entity.setOutboundNodeLevel(self.outputs.pump_in, false)
      entity.setOutboundNodeLevel(self.outputs.outer_door, true)
    end
  elseif storage.state == self.airlockStates.open then
    --[[ State: open
         Active outbound nodes: outer_door
         Transitions: recover
    --]]
    if not entity.getInboundNodeLevel(self.inputs.sensor_ready) then
      -- Transition to recover state
      storage.state = self.airlockStates.recover
      entity.setOutboundNodeLevel(self.outputs.outer_door, false)
      entity.setOutboundNodeLevel(self.outputs.pump_out, true)
    end
  elseif storage.state == self.airlockStates.recover then
    --[[ State: recover
         Active outbound nodes: pump_out
         Transitions: idle, pressurize
    --]]
    if not entity.getInboundNodeLevel(self.inputs.liquid_low) then
      -- Transition to idle state
      storage.state = self.airlockStates.idle
      entity.setOutboundNodeLevel(self.outputs.pump_out, false)
    end
  end
  output(state)
end

function enum(values)
  local enumID = 0
  local enumerated = {}
  for _,enum in ipairs(values) do
    enumerated[enum] = enumID
    enumID = enumID+1
  end
  return enumerated
end
