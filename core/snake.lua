local SDL = require "SDL"


local Snake = {}


Snake.new = function (para)
   local x, y = para.x, para.y
   local block_size = para.block_size
   local rdr = para.renderer
   local data = {
      alive = true,
      direction = "left",
      body = {
         {x = x // 2 - 1, y = y // 2},
         {x = x // 2, y = y // 2},
         {x = x // 2 + 1, y = y // 2}}
   }
   local move = function (direction)
      local tail = table.remove(data.body)
      local head = data.body[1]
      if direction == "left" then
         table.insert(data.body, 1, {x = head.x - 1, y = head.y})
      elseif direction == "right" then
         table.insert(data.body, 1, {x = head.x + 1, y = head.y})
      elseif direction == "up" then
         table.insert(data.body, 1, {x = head.x, y = head.y - 1})
      elseif direction == "down" then
         table.insert(data.body, 1, {x = head.x, y = head.y + 1})
      else
         error("unrecognized direction")
      end
      return tail
   end
   return {
      is_alive = function () return data.alive end,
      get_direction = function () return data.direction end,
      set_direction = function (direction) data.direction = direction end,
      get_body = function ()
         local body = {}
         for k, v in pairs(data.body) do body[k] = v end
         return body
      end,
      die = function () data.alive = false end,
      move = function () return move(data.direction) end,
      grow = function (tail) table.insert(data.body, tail) end,
      draw = function ()
         rdr:setDrawColor(0x0000ff)
         rdr:fillRect({
               w = block_size, h = block_size,
               x = data.body[1].x * block_size,
               y = data.body[1].y * block_size
         })
         rdr:setDrawColor({r = 0, g = 0, b = 0, a = 255})
         for i = 2, #data.body do
            rdr:fillRect({
                  w = block_size, h = block_size,
                  x = data.body[i].x * block_size,
                  y = data.body[i].y * block_size
            })
         end
      end
   }
end


return Snake
