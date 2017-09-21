Tstart  = tmr.now()

local port=5014

--varaiable declaratoin --

local id=nil
local name=nil
local count=nil
local message=nil
local b=1


function clint_cnnct()

if (wifi.sta.getip() ~= nil) then       
    sk = net.createConnection(net.TCP) 
    sk:connect(port, "10.10.10.1")
    print(wifi.sta.getip())
    print("connection created")
    --tmr.delay(1000)
    b=b+1
    sk:on("connection", function(sk) 
    id = "11"
    name = "1"
    count = "35"
    message= '#'..id..'*'..name..'*'..count..'#'
    sk:send(message)   
     
    print("b is"..b)    
    while (b>5) do
            b=1
            sk:close()
            print("server closed")
            break
            
    end 
    print("message send")  
    end)
   
else
    print("no connection")   
end  
end



ConnStatus = nil
function ConnStatus(n)
   status = wifi.sta.status()
   uart.write(0,' '..status)
   local x = n+1
   if (x < 50) and ( status < 5 ) then
      tmr.alarm(0,100,0,function() ConnStatus(x) end)
   else
      if status == 5 then
      print('\nConnected as '..wifi.sta.getip())
          if (wifi.sta.getip()~='10.10.10.2') then
            tmr.alarm(1,1000, 1, function() clint_cnnct() end)
          else
          print("Id doesnot match")
          end
      --dofile('httpget.lua')
      else
      print("\nConnection failed")
      end
   end
end
   
best_ssid = nil
function best_ssid(ap_db)
   local min = 100
   ssid = nil
   for k,v in pairs(ap_db) do
       if tonumber(v) < min then 
          min = tonumber(v)
          ssid = k
          end
       end
       
   --gpio.write(red,gpio.LOW)
   --gpio.write(blue,gpio.HIGH)
   return min
end


strongest = nil
function strongest(aplist)
   ssid="ESP8266"
   
   print("\nAvailable Open Access Points:\n")
   for k,v in pairs(aplist) do print(k..' '..v) end
   
   ap_db = {}
   if next(aplist) then
      for k,v in pairs(aplist) do 
         if '4' == string.sub(v,1,1) then 
            ap_db[k] = string.match(v, '-(%d+),') 
            end 
          end
      signal = -best_ssid(ap_db)
      end
   if ssid then
      print("\nBest SSID.: ".. ssid)
      wifi.sta.config(ssid,"12345678")
      print("\nConnecting to "..ssid)
      ConnStatus(4)
   else
      print("\nNo available open APs")
      ssid = ''
      end
end
wifi.setmode(wifi.STATION)
wifi.sta.getap(function(t) strongest(t)  end)
