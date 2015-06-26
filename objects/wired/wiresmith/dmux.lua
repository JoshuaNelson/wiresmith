function init(args)
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
  updateInboundConnections()
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

-- For all incoming connections to dmux, if they have data bits (mux), map them
-- to outbound nodes
function getParallelData()
  for node=0,self.bits-1 do
    local outboundNodeState = false
    for targetId,targetBits in pairs(storage.inboundConnections) do
      if node < targetBits and
         world.callScriptedEntity(targetId, "entity.getInboundNodeLevel", node) then
       outboundNodeState = true
       break
      end
    end
    entity.setOutboundNodeLevel(node, outboundNodeState)
  end
end

-- Check inboundNode for connections and populate storage.inboundConnections
function updateInboundConnections()
  storage.inboundConnections = { }
  if entity.isInboundNodeConnected(0) then
    for targetId,val in pairs(entity.getInboundNodeIds(0)) do
      local targetBits = nil
      targetBits = world.callScriptedEntity(targetId, "entity.configParameter", "bits")
      if targetBits ~= nil and targetBits > 0 then
        storage.inboundConnections[targetId] = targetBits
      end
    end
  end
end

function update(dt)
  storage.state = entity.getInboundNodeLevel(0)
  if storage.state then
    getParallelData()
  else
    entity.setAllOutboundNodes(false)
  end
  output(storage.state)
end

function onNodeConnectionChange()
  updateInboundConnections()
end
