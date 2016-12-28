-- It works only if x is even and y > 2.

local brain = function (x, y, snake, food, synaptic_vesicle)
   local body = snake.get_body()
   local head = body[1]
   if synaptic_vesicle.neurotransmmitter == nil then
      synaptic_vesicle.neurotransmmitter = "left"
   end
   if synaptic_vesicle.neurotransmmitter == "left" then
      if head.x == 0 then
         synaptic_vesicle.neurotransmmitter = "up"
         snake.set_direction("up")
      end
   elseif synaptic_vesicle.neurotransmmitter == "up" then
      if head.y == 0 then
         synaptic_vesicle.neurotransmmitter = "right1"
         snake.set_direction("right")
      end
   elseif synaptic_vesicle.neurotransmmitter == "right1" then
      synaptic_vesicle.neurotransmmitter = "down"
      snake.set_direction("down")
   elseif synaptic_vesicle.neurotransmmitter == "right2" then
      synaptic_vesicle.neurotransmmitter = "up"
      snake.set_direction("up")
   elseif synaptic_vesicle.neurotransmmitter == "down" then
      if head.x ~= x - 1 and head.y == y - 2 then
         synaptic_vesicle.neurotransmmitter = "right2"
         snake.set_direction("right")
      elseif head.x == x - 1 and head.y == y - 1 then
         synaptic_vesicle.neurotransmmitter = "left"
         snake.set_direction("left")
      end
   end
   return synaptic_vesicle
end


return brain
