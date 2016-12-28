local brain = function (x, y, snake, food)
   if not snake.is_alive() then return end
   math.randomseed(os.time())
   local get_new_head = function (direction, snake)
      local body = snake.get_body()
      local head = body[1]
      local new_head = {x = head.x, y = head.y}
      if direction == "left" then
         new_head.x = new_head.x - 1
      elseif direction == "right" then
         new_head.x = new_head.x + 1
      elseif direction == "up" then
         new_head.y = new_head.y - 1
      elseif direction == "down" then
         new_head.y = new_head.y + 1
      else
         error("unbelievable")
      end
      return new_head
   end
   local will_bite_self = function (new_head, snake)
      local body = snake.get_body()
      for i = 1, #body - 1  do
         if new_head.x == body[i].x and new_head.y == body[i].y then
            return true
         end
      end
      return false
   end
   local will_bite_wall = function (new_head, x, y)
      return (new_head.x < 0 or new_head.y < 0 or
                 new_head.x > x - 1 or new_head.y > y - 1) and true or false
   end
   local will_die = function (direction, x, y, snake)
      local new_head = get_new_head(direction, snake)
      return will_bite_self(new_head, snake) or will_bite_wall(new_head, x, y)
   end
   local directions = {"left", "right", "up", "down"}
   while #directions > 0 do
      local direction = table.remove(directions, math.random(#directions))
      if not will_die(direction, x, y, snake) then
         snake.set_direction(direction)
         return
      end
   end
end


return brain
