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

-- Pumps liquids from input pipe locations to current position.
function pump()
  if storage.inbound == nil then
    return
  end
  for targetId, targetEntity in pairs(storage.inbound) do
    local liquid = world.liquidAt(targetEntity.position)
    if liquid then
      world.destroyLiquid(targetEntity.position)
      world.spawnLiquid(entity.position(), liquid[1], liquid[2])
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
  storage.inbound = { }
  if entity.isInboundNodeConnected(1) then
    for targetId,val in pairs(entity.getInboundNodeIds(1)) do
      --TODO Check if entity is pipe
      storage.inbound[targetId] = { ["position"] = world.entityPosition(targetId) }
    end
  end
end
