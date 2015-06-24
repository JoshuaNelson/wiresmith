function init(args)
  if not virtual then
    self.drainPos = entity.position()
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
      pump()
    else
      entity.setAnimationState("drainState", "off")
    end
  end
end

-- Pumps liquids from input pipes to current position.
function pump()
  for pipeEntityId, pipeEntity in pairs(storage.pipe_in) do
    local liquid = world.liquidAt(pipeEntity.position)
    if liquid then
      world.destroyLiquid(pipeEntity.position)
      world.spawnLiquid(entity.position(), liquid[1], 1)
    end
  end
end

function update(dt)
  if not entity.isInboundNodeConnected(0) or entity.getInboundNodeLevel(0) then
    output(true)
  else
    output(false)
  end
end

function onNodeConnectionChange()
  storage.pipe_in = { }
  for pipeId in entity.getInboundNodeIds(1) do
    if world.entityName(pipeId) == "pipe_in" then
      storage.pipe_in[pipeId] = { ["position"] = world.entityPosition(pipeId) }
    end
  end
end
