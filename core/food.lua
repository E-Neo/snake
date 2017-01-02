local SDL = require "SDL"


local Food = {}


Food.new = function (para)
   local block_size = para.block_size
   local rdr = para.renderer
   local position = {}
   return {
      get_position = function () return {x = position.x, y = position.y} end,
      draw = function ()
         rdr:setDrawColor(0xff0000)
         rdr:fillRect({
               w = block_size, h = block_size,
               x = position.x * block_size,
               y = position.y * block_size
         })
      end,
      update = function (points)
         local chosen = points[math.random(#points)]
         position.x, position.y = chosen.x, chosen.y
      end
   }
end


return Food
