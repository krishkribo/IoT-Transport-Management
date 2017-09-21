

--  server  station--
-- *** station init configuration *** --

print("Ready to start soft ap")
   
cfg={}
cfg.ssid="ESP8266";
cfg.pwd="12345678"
wifi.ap.config(cfg)
 
dofile("server_online_offline_db.lua")
