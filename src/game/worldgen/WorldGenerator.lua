local globals = GLOBALS
local WorldGenerator = {}

local planetGen = require("game.worldgen.PlanetGenerator")

function WorldGenerator.createUniverseFromSeed(seed)
  local rng = love.math.newRandomGenerator(love.timer.getTime()*1000)
  if seed then
    local seedhash = seed:hash()
    rng:setSeed(seedhash)
  end
  
  local universe = {
    planets = planetGen.createPlanets(rng,100)
  }
  
  return universe
end

return WorldGenerator
