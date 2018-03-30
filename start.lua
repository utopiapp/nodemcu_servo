dofile("config.lua")
dofile("srv.lua")
dofile("curtain.lua")

-- WiFi setup
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})

function startup()
  curtain = Curtain.init({pin = SERVO_PIN})

  srv = Server.listen({ip = wifi.sta.getip(), port = 80})
  -- srv passes a number to servo:set_curtain
  -- representing the percentage by which the curtain should be open
  -- from 0 to 100
  srv:on("set_state", curtain:set_state)
  -- servo returns a number representing the percentage by which curtain is open
  -- from 0 to 100
  srv:on("get_state", curtain:get_state)
end

-- This code will be executed on start
-- ALARM_AUTO will keep running with the set frequency until stopped manually
tmr.alarm(1, 1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("Waiting...")
        tmr.alarm(0, 1000, tmr.ALARM_SINGLE, startup)
    end
end)
