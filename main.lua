package.path = package.path .. ";core/?.lua"
local Game = require "game"


local parse_arg = function (arg)
   local para = {}
   local key = true
   for i = 1, #arg, 2 do
      if key then
         if arg[i] == "-b" then
            para.brain = loadfile(arg[i+1])()
         elseif arg[i] == "-x" then
            para.x = tonumber(arg[i+1])
         elseif arg[i] == "-y" then
            para.y = tonumber(arg[i+1])
         end
      end
   end
   return para
end


local main = function ()
   local para = parse_arg(arg)
   local game = Game.new(para)
   while game.is_running() do
      game.handle_events()
      game.update()
      game.render()
      game.delay(50)
   end
end

main()
