local SDL = require "SDL"
local Snake = require "snake"
local Food = require "food"

local Game = {}

Game.new = function (para)
   local x = para.x or 30
   local y = para.y or 20
   local block_size = para.block_size or 25
   local brain = para.brain

   assert(SDL.init({SDL.flags.Video}))

   local win = assert(
      SDL.createWindow({
            title = "Snake",
            height = y * block_size,
            width = x * block_size
   }))

   local rdr = assert(SDL.createRenderer(win, 0, 0))
   local snake_bite_food_p = function (snake, food)
      local head = snake.get_body()[1]
      local food_position = food.get_position()
      return (head.x == food_position.x and
                 head.y == food_position.y) and true or false
   end
   local snake_bite_self_p = function (snake)
      local body = snake.get_body()
      local head = body[1]
      for i = 2, #body do
         if head.x == body[i].x and head.y == body[i].y then
            return true
         end
      end
      return false
   end
   local snake_bite_wall_p = function (x, y, snake)
      local head = snake.get_body()[1]
      return (head.x < 0 or head.y < 0 or
                 head.x > x - 1 or head.y > y - 1) and true or false
   end
   local snake_die_p = function (x, y, snake)
      return snake_bite_wall_p(x, y, snake) or
         snake_bite_self_p(snake)
   end
   local update_food = function (x, y, snake, food)
      local points = {}
      local body = snake.get_body()
      for i = 0, x - 1 do
         for j = 0, y - 1 do
            local good = true
            for _, node in pairs(body) do
               if i == node.x and j == node.y then
                  good = false
                  break
               end
            end
            if good then table.insert(points, {x = i, y = j}) end
         end
      end
      if #points > 0 then
         food.update(points)
         return true
      else
         return false
      end
   end
   local snake = Snake.new({
         x = x,
         y = y,
         block_size = block_size,
         renderer = rdr
   })
   local food = Food.new({
         block_size = block_size,
         renderer = rdr
   })
   local keys = SDL.getKeyboardState()
   local running = true
   local success = false
   update_food(x, y, snake, food)
   return {
      get_SDL_data = function ()
         return {
            window = win,
            renderer = rdr
         }
      end,
      is_running = function () return running end,
      handle_events = function ()
         for e in SDL.pollEvent() do
            if e.type == SDL.event.Quit then
               running = false
            end
         end
         if brain then brain(x, y, snake) end
         if keys[SDL.scancode.Left] then snake.set_direction("left") end
         if keys[SDL.scancode.Right] then snake.set_direction("right") end
         if keys[SDL.scancode.Up] then snake.set_direction("up") end
         if keys[SDL.scancode.Down] then snake.set_direction("down") end
      end,
      update = function ()
         if not success and snake.is_alive() then
            local tail = snake.move()
            if snake_bite_food_p(snake, food) then
               snake.grow(tail)
               if not update_food(x, y, snake, food) then
                  success = true
                  print("win")
               end
            end
            if snake_die_p(x, y, snake) then
               snake.die()
               print("die")
            end
         end
      end,
      render = function ()
         rdr:setDrawColor(0xffffff)
         rdr:clear()
         snake.draw()
         food.draw()
         rdr:present()
      end,
      delay = SDL.delay
   }
end


return Game
