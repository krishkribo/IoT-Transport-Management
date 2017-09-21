 
cfg={}
cfg.ip="10.10.10.1";
cfg.netmask="255.255.255.0";
cfg.gateway="10.10.10.1";
wifi.ap.setip(cfg);
wifi.setmode(wifi.SOFTAP)


collectgarbage();

print("Soft AP started")
print("Heep:(bytes)"..node.heap());
print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());

print("DataBase and server activity started ")
 
local port=5014  -- port fixing --

-- variable assignment to receive value--
local id=nil
local name=nil
local count=nil
local a
local b=1

local c

--variable assignment for db upadate --

local bus_id=nil
local busnmae=nil
local count_db=nil
local status='offline'

--Variable assignment for local server ip

local IP='10.10.10.2'

--function decleration for bus_online


function database_online()
  
  bus_id = id
  station_id=name
  seats_available=count
  status='online'
  c=c+1
  conn1=net.createConnection(net.TCP) 
  print(" db server started")
  conn1:on("receive", function(conn, payload) print(payload) end)
  conn1:connect(80,IP)
  conn1:send("GET /db_update.php?bus_id="..bus_id.."&station_id="..station_id.."&seats_available="..seats_available.."&status="..status.." HTTP/1.1\r\n") 
  conn1:send("Host: IP\r\n") 
  conn1:send("Accept: */*\r\n") 
  conn1:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  conn1:send("\r\n")
  conn1:on("sent",function(conn)
  print("Data sent to database")
    conn1:close()
  end)
  conn1:on("disconnection", function(conn)
  end)
end

--function decleration for bus_offline

function database_offlie()
    
  bus_id = id
  station_id=name
  seats_available=nil
  status='offline'
  conn2=net.createConnection(net.TCP) 
  print(" db server started")
  conn2:on("receive", function(conn, payload) print(payload) end)
  conn2:connect(80,IP)
  conn2:send("GET /db_update.php?bus_id="..bus_id.."&station_id="..station_id.."&seats_available="..seats_available.."&status="..status.." HTTP/1.1\r\n") 
  conn2:send("Host: IP\r\n") 
  conn2:send("Accept: */*\r\n") 
  conn2:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
  conn2:send("\r\n")
  conn2:on("sent",function(conn)
  print("Data sent to database")
  conn2:close()
  end)
  conn2:on("disconnection", function(conn)
  end)
end


sv=net.createServer(net.TCP)

sv:listen(port, function(conn)
print('host started and connected')

conn:on("receive", function(conn, receivedData)
      
print("received: " .. receivedData)
-- offline db ---

--print("received: " .. receivedData:sub(1,1))
--print("received: " .. receivedData)

if (receivedData ~= nil)
then
  if (receivedData:sub(1,1) == '#') then
        a=2
        id=''
        name=''
        count=''
        while (receivedData:sub(a,a) ~= '*') do
        id=id..receivedData:sub(a,a)
        a=a+1
        end
        a=a+1
        while (receivedData:sub(a,a) ~= '*') do
       name=name..receivedData:sub(a,a)
        a=a+1
        end
        a=a+1
        
        while (receivedData:sub(a,a) ~= '#') do
        count=count..receivedData:sub(a,a)
        a=a+1
        end
        print('bus_id'..id)
        print('name'..name)

        print('count'..count) 
        tmr.alarm(1,500, 1, function() database_online() end)
        c=1
   end 
   b=b+1
   print('b is '..b) 
   if (b>7) then
        sv:close()
        print('server closed')
      --print("Board restart")
      --node.restart()
   end
   tmr.delay(500)
else
  tmr.alarm(1,500, 1, function() database_offline() end)
end 

 end)         
end)
