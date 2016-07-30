local ffi = require 'ffi'
local g= love.graphics

local gfeatures
local limits
local name, version, vendor, device 

local i1024, i2048
local count = 0

function love.load()
   print 'load()'
   gfeatures = g.getSupported()
   limits = g.getSystemLimits()

   for k,v in pairs(gfeatures) do
      print(string.format("%s: %s", k, v))
   end

   for k,v in pairs(limits) do
      print(string.format("%s: %s", k, v))
   end

   name,version,vendor,device = g.getRendererInfo()
   print("name: " .. name)
   print("ver: " .. version)
   print("vendor: " .. vendor)
   print("device: " .. device)

   love.window.setTitle('gfxtest')
end

function love.draw()
   local w,h = g.getDimensions()
   if count == 1 and i1024 then g.draw(i1024,0,0,0,w/i1024:getWidth(), h/i1024:getHeight()) end
   if count == 2 and i2048 then g.draw(i2048,0,0,0,w/i2048:getWidth(), h/i2048:getHeight()) end
   
   local y = 0
   g.setColor(0,200,0)

   g.printf(string.format("%s | %s | %s | %s",name,vendor,device,version), 20, y+20, w)
   y = y + 20
   
   for k,v in pairs(gfeatures) do
      g.printf(string.format("%s: %s",k,v), 20, y+20, w)
      y = y + 20
   end
   for k,v in pairs(limits) do
      g.printf(string.format("%s: %s",k,v), 20, y+20, w)
      y = y + 20
   end
   g.printf(string.format("saveDirs: %s",love.filesystem.getSaveDirectory()), 20, y+20, w) ; y = y + 20
   
   for k,v in pairs(sdl_get_info()) do
      g.printf(string.format("%s: %s",k,tostring(v)), 20, y+20, w)
      y = y + 20
   end

   local msg = string.format("\nPress SPACE to cycle texture sizes: (current size=%s)", ({[0]="no texture",[1]="1024", [2]="2048"})[count])
   g.setColor(250,250,250)
   g.printf(msg, 20, y+20, w)
end


function love.keypressed(key, scancode, isrepeat)
   if key == 'space' then
      if count == 0 then
         if not i1024 then i1024 = g.newImage('1024x1024.png') end
      end
      if count == 1 then
         if not i2048 then i2048 = g.newImage('2048x2048.png') end
      end
      count = (count + 1) % 3
   end
end

--
-- SDL functions
--

ffi.cdef [[
const char* SDL_GetDisplayName(int displayIndex);
const char* SDL_GetCurrentVideoDriver(void);
const char* SDL_GetVideoDriver(int index);
int SDL_GetCPUCount(void);
int SDL_GetSystemRAM(void);
int SDL_GetNumVideoDisplays(void);
int SDL_GetNumVideoDrivers(void);
]]

function sdl_get_info()
   local sdl 
   if love.system.getOS() == "Windows" then
      sdl = ffi.load('SDL2')
   else
      sdl = ffi.C
   end
   
   local t = {}
   t.CPUCount = sdl.SDL_GetCPUCount()
   t.sysRAM = sdl.SDL_GetSystemRAM()
   t.numDrivers = sdl.SDL_GetNumVideoDrivers()
   t.displayNums = sdl.SDL_GetNumVideoDisplays()

   for i=0, t.displayNums-1 do
      t["display_"..i] = ffi.string(sdl.SDL_GetDisplayName(i));
   end

   for i=0, t.numDrivers-1 do
      t["driver_"..i] = ffi.string(sdl.SDL_GetVideoDriver(i));
   end

   return t
end
