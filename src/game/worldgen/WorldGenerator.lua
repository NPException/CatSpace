local globals = GLOBALS
local WorldGenerator = {}

local planetGen = require("game.worldgen.PlanetGenerator")
local resourceGen = require("game.worldgen.ResourceGenerator")

function WorldGenerator.createUniverseFromSeed(seed)
  local rng = love.math.newRandomGenerator(love.timer.getTime()*1000)
  if seed then
    local seedhash = seed:hash()
    rng:setSeed(seedhash)
  end
  
  local universe = {
    planets = planetGen.createPlanets(rng,100)
  }
  
  for i,planet in ipairs(universe.planets) do
    local resCount = nil
    if i==1 then
      resCount = 5
    end
    resourceGen.createResources(planet, rng, resCount)
  end
  
  return universe
end

return WorldGenerator
