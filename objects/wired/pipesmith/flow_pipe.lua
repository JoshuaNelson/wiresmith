function init(args)
  if not virtual then
    if storage.state == nil then
      output(false)
    else
      output(storage.state)
    end
    updateInboundPipes()
  end
end

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

-- Pumps liquids from input pipe locations to current position.
function pump()
  if storage.inboundPipes == nil then
    return
  end
  for targetId,targetPos in pairs(storage.inboundPipes) do
    local liquid = world.liquidAt(targetPos)
    if liquid then
      world.destroyLiquid(targetPos)
      world.spawnLiquid(entity.position(), liquid[1], liquid[2])
    end
  end
end

function updateInboundPipes()
  storage.inboundPipes = { }
  if entity.isInboundNodeConnected(1) then
    for targetId,val in pairs(entity.getInboundNodeIds(1)) do
      if world.entityName(targetId) == "flow_pipe" then
        storage.inboundPipes[targetId] = world.entityPosition(targetId)
      end
    end
  end
end

function update(dt)
  if entity.getInboundNodeLevel(0) then
    output(true)
    pump()
  else
    output(false)
  end
end

function onNodeConnectionChange()
  updateInboundPipes()
end
