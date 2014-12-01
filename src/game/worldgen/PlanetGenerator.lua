local PlanetGenerator = {}

local Planet = require("game.bodies.Planet")


function PlanetGenerator.createPlanets(rng, count)
  local planets = { Planet.new(0,0,75) }
  local rngState = rng:getState()
  
  local Cat = require("game.entities.Cat")
  for i=1,6 do
    table.insert(planets[1].entities, Cat.new(planets[1], rng:random(), 1))
  end
  rng:setState(rngState)
  
  for i=1,count do
    local newPlanet    
    repeat
      local x,y = rng:random(-12800,12800), rng:random(-7200,7200)
      local radius = rng:random(20,200)
      newPlanet = Planet.new(x,y,radius)
    until not newPlanet:closeToOtherBody(planets, 100)
    table.insert(planets, newPlanet)
  end
  
  return planets
end

return PlanetGenerator
