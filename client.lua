-- port assignment --

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
    id = "6"
    name = "112"
    count = "80"
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
    print("no connectoin")   
end  
end

tmr.alarm(1,1000, 1, function() clint_cnnct() end)
 


    
    

