local PlanetGenerator = {}

local Planet = require("game.bodies.Planet")


local function tooCloseToOtherPlanet(planet, planets) 
  local result = false
  local minDist = 100.0
  for _,p in ipairs(planets) do
    if planet:surfaceDistance(p) < minDist then
      result = true
      break
    end
  end
  return result
end

function PlanetGenerator.createPlanets(rng, count)
  local planets = { Planet.new(0,0,50) }
  
  for i=1,count do
    local newPlanet    
    repeat
      local x,y = rng:random(-12800,12800), rng:random(-7200,7200)
      local radius = rng:random(10,200)
      newPlanet = Planet.new(x,y,radius)
    until not tooCloseToOtherPlanet(newPlanet, planets)
    table.insert(planets, newPlanet)
  end
  
  return planets
end

return PlanetGenerator
