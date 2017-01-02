local Graph = function (V, E)
   local get_vertices = function (graph)
      local vertices = {}
      for v in pairs(graph) do table.insert(vertices, v) end
      return vertices
   end
   local get_edges = function (graph)
      local edges = {}
      for v_from in pairs(graph) do
         for _, v_to in pairs(graph[v_from].to) do
            table.insert(edges, {v_from, v_to})
         end
      end
      return edges
   end
   local add_vertex = function (graph, vertex)
      if graph[vertex] ~= nil then
         error("vertex " .. vertex .. " has already in graph.")
      end
      graph[vertex] = {to = {}}
   end
   local add_edge = function (graph, edge)
      table.insert(graph[edge[1]].to, edge[2])
      table.insert(graph[edge[2]].to, edge[1])
   end
   local remove_edge = function (graph, edge)
      for i = 1, #graph[edge[1]].to do
         if graph[edge[1]].to[i] == edge[2] then
            table.remove(graph[edge[1]].to, i)
            break
         end
      end
   end
   local remove_vertex = function (graph, vertex)
      for i = 1, #graph[vertex].to do
         local to_vertex = graph[vertex].to[i]
         for j = 1, #graph[to_vertex].to do
            if graph[to_vertex].to[j] == vertex then
               table.remove(graph[to_vertex].to, j)
            end
         end
      end
      graph[vertex] = nil
   end
   local dfs = function (graph)
      local inner_dfs
      inner_dfs = function (graph, vertex, res)
         graph[vertex].d = true
         res[#res + 1] = vertex
         for _, v in pairs(graph[vertex].to) do
            if graph[v].d == nil then inner_dfs(graph, v, res) end
         end
      end
      local connect = {}
      local vertices = get_vertices(graph)
      for _, v in pairs(vertices) do
         if graph[v].d == nil then
            local res = {}
            inner_dfs(graph, v, res)
            table.insert(connect, res)
         end
      end
      for _, v in pairs(vertices) do graph[v].d = nil end
      return connect
   end
   local plot = function (graph)
      local vertices = get_vertices(graph)
      local edges = get_edges(graph)
      local src = "graph {\n"
         ..        "  node [shape=circle]\n"
      for _, v in pairs(vertices) do
         src = src .. "  " .. v .. ";\n"
      end
      for _, v in pairs(edges) do
         src = src .. "  " .. v[1] .. " -- " .. v[2] .. ";\n"
      end
      src = src .. "}\n"
      return {
         show = function ()
            local dot, pdf = os.tmpname(), os.tmpname()
            local fdot = assert(io.open(dot, "w"))
            fdot:write(src)
            fdot:close()
            os.execute("dot -Tpdf " .. dot .. " -o " .. pdf)
            os.execute("xdg-open " .. pdf)
         end,
         save = function (name)
            local dot = os.tmpname()
            local fdot = assert(io.open(dot, "w"))
            fdot:write(src)
            fdot:close()
            os.execute("dot -Tpdf " .. dot .. " -o " .. name)
         end
      }
   end
   local graph = {}
   for _, vertex in pairs(V) do add_vertex(graph, vertex) end
   for _, edge in pairs(E) do
      assert(graph[edge[1]], edge[1] .. " not in V.")
      assert(graph[edge[2]], edge[2] .. " not in V.")
      add_edge(graph, edge)
   end
   return {
      raw = graph,
      V = function () return get_vertices(graph) end,
      E = function () return get_edges(graph) end,
      add_vertex = function (vertex) add_vertex(graph, vertex) end,
      add_edge = function (edge) add_edge(graph, edge) end,
      remove_vertex = function (vertex) remove_vertex(graph, vertex) end,
      remove_edge = function (edge) remove_edge(graph, edge) end,
      plot = function () return plot(graph) end,
      dfs = function () return dfs(graph) end
   }
end

local brain = function (x, y, snake, food, synaptic_vesicle)
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
   local point2vertex = function (point, x, y)
      return point.y * x + point.x
   end
   local vertex2point = function (vertex, x, y)
      return {x = vertex % x, y = vertex // x}
   end
   local make_vertices = function (x, y)
      local vertices = {}
      for i = 0, x - 1 do
         for j = 0, y - 1 do
            table.insert(vertices, point2vertex({x = i, y = j}, x, y))
         end
      end
      return vertices
   end
   local make_edges = function (x, y)
      local edges = {}
      for i = 0, x - 2 do
         for j = 0, y - 2 do
            table.insert(edges, {point2vertex({x = i, y = j}, x, y),
                                 point2vertex({x = i + 1, y = j}, x, y)})
            table.insert(edges, {point2vertex({x = i, y = j}, x, y),
                                 point2vertex({x = i, y = j + 1}, x, y)})
         end
      end
      for j = 0, y - 2 do
         table.insert(edges, {point2vertex({x = x - 1, y = j}, x, y),
                              point2vertex({x = x - 1, y = j + 1}, x, y)})
      end
      for i = 0, x - 2 do
         table.insert(edges, {point2vertex({x = i, y = y - 1}, x, y),
                              point2vertex({x = i + 1, y = y - 1}, x, y)})
      end
      return edges
   end
   local count_connect = function (vertex, connect)
      for _, vertices in pairs(connect) do
         for _, v in pairs(vertices) do
            if vertex == v then return #vertices end
         end
      end
      return 0
   end
   local body = snake.get_body()
   local head = body[1]
   local food_position = food.get_position()
   local good = false
   if synaptic_vesicle.graph == nil then
      synaptic_vesicle.graph = Graph(make_vertices(x, y), make_edges(x, y))
      for _, v in pairs(body) do
         synaptic_vesicle.graph.remove_vertex(point2vertex(v, x, y))
      end
      synaptic_vesicle.connect = synaptic_vesicle.graph.dfs()
      synaptic_vesicle.get_food = false
      synaptic_vesicle.food = food.get_position()
      synaptic_vesicle.remove_head = false
      synaptic_vesicle.add_tail = false
      synaptic_vesicle.tail = body[#body]
   end
   if head.x == synaptic_vesicle.food.x and
   head.y == synaptic_vesicle.food.y then
      synaptic_vesicle.get_food = true
      synaptic_vesicle.add_tail = false
   else
      synaptic_vesicle.add_tail = true
      synaptic_vesicle.tail = body[#body]
   end
   if synaptic_vesicle.get_food then
      synaptic_vesicle.food = food.get_position()
      synaptic_vesicle.get_food = false
   end
   if not synaptic_vesicle.remove_head then
      synaptic_vesicle.remove_head = true
   else
      synaptic_vesicle.graph.remove_vertex(point2vertex(head, x, y))
   end
   if synaptic_vesicle.add_tail then
      local tail = synaptic_vesicle.tail
      synaptic_vesicle.graph.add_vertex(point2vertex(tail, x, y))
      local vertices_set = {}
      for _, v in pairs(synaptic_vesicle.graph.V()) do
         vertices_set[v] = true
      end
      local point = {x = tail.x - 1, y = tail.y}
      if vertices_set[point2vertex(point, x, y)] then
         synaptic_vesicle.graph.add_edge({point2vertex(point, x, y),
                                          point2vertex(tail, x, y)})
      end
      point = {x = tail.x + 1, y = tail.y}
      if vertices_set[point2vertex(point, x, y)] then
         synaptic_vesicle.graph.add_edge({point2vertex(point, x, y),
                                          point2vertex(tail, x, y)})
      end
      point = {x = tail.x, y = tail.y - 1}
      if vertices_set[point2vertex(point, x, y)] then
         synaptic_vesicle.graph.add_edge({point2vertex(point, x, y),
                                          point2vertex(tail, x, y)})
      end
      point = {x = tail.x, y = tail.y + 1}
      if vertices_set[point2vertex(point, x, y)] then
         synaptic_vesicle.graph.add_edge({point2vertex(point, x, y),
                                          point2vertex(tail, x, y)})
      end
   end
   if food_position.x < head.x then
      if not will_die("left", x, y, snake) then
         snake.set_direction("left")
         good = true
      end
   elseif food_position.x > head.x then
      if not will_die("right", x, y, snake) then
         snake.set_direction("right")
         good = true
      end
   else
      if (snake.get_direction() == "up" and food_position.y > head.y) or
      (snake.get_direction() == "down" and food_position.y < head.y) then
         if not will_die("left", x, y, snake) then
            snake.set_direction("left")
            good = true
         else
            snake.set_direction("right")
            good = true
         end
      end
   end
   if not good then
      if food_position.y < head.y then
         if not will_die("up", x, y, snake) then
            snake.set_direction("up")
         end
      elseif food_position.y > head.y then
         if not will_die("down", x, y, snake) then
            snake.set_direction("down")
         end
      else
         if (snake.get_direction() == "left" and food_position.x > head.y) or
         (snake.get_direction() == "right" and food_position.x < head.x) then
            if not will_die("up", x, y, snake) then
               snake.set_direction("up")
            else
               snake.set_direction("down")
            end
         end
      end
   end
   local connect = synaptic_vesicle.graph.dfs()
   if #connect > #synaptic_vesicle.connect then
      -- print("snake length " .. #body)
      local tmp = {}
      local direction, count = snake.get_direction(), 0
      for _, v in pairs({"left", "right", "up", "down"}) do
         if not will_die(v, x, y, snake) then
            tmp[v] = count_connect(point2vertex(get_new_head(v, snake), x, y),
                                   connect)
         end
      end
      for d, c in pairs(tmp) do
         -- print(d, c)
         if c > count then
            direction = d
            count = c
         end
      end
      -- print("choose " .. direction)
      snake.set_direction(direction)
   end
   synaptic_vesicle.connect = connect
   if will_die(snake.get_direction(), x, y, snake) then
      local directions = {"left", "right", "up", "down"}
      while #directions > 0 do
         local direction = table.remove(directions, math.random(#directions))
         if not will_die(direction, x, y, snake) then
            snake.set_direction(direction)
            return synaptic_vesicle
         end
      end
      synaptic_vesicle.remove_head = false
      synaptic_vesicle.add_tail = false
   end
   return synaptic_vesicle
end


return brain
