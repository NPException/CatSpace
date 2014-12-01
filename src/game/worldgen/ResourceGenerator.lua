local ResourceGenerator = {}

local Resource = require("game.bodies.Resource")


function ResourceGenerator.createResources(body, rng, count)
  local chance = rng:random()
  
  if not count then
    count = 0
    -- only two thirds of planets have resources
    if chance < 2.0/3.0 then
      count = rng:random(1,10)
    end
  end
  
  if count > 0 then
    for i=1,count do
      local steps = 0
      repeat
        local min, max = math.min(3, body.radius*(2/3.0)-10), math.min(25, body.radius*(2/3.0)-10)
        if rng:random() < 0.25 then -- 25% are extra large resource
          min, max = math.min(25, body.radius*(2/3.0)-10), math.min(100, body.radius*(2/3.0)-10)
        end
        local radius = rng:random(min, max)
        local success = body:addResource(radius, rng:random())
        steps = steps + 1
      until success or (steps == 100) -- only try 100 times per resource
    end
  end
end

return ResourceGenerator