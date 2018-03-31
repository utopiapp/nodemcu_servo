dofile("config.lua")
dofile("server.lua")
dofile("curtain.lua")

-- WiFi setup
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})

Curtain.init({pin = SERVO_PIN})

function startup()
  Server:listen({
    ip = wifi.sta.getip(),
    port = SERVER_PORT,
    poll_frequency = Curtain.duration_per_percent,
    action_stopped = Curtain.STOPPED,
  })
  -- Register handlers for commands a server can receive
  Server:on(Server.SETPOS, Curtain.set_position) -- Position from 0% (open) to 100% (closed)
  Server:on(Server.GETSTATE, Curtain.get_state) -- E.g. "10 opening"
  Server:on(Server.STOP, Curtain.stop) -- Stops current action
  Server:on(Server.RESET, Curtain.reset) -- Resets curtain to a position
  Server:on(Server.GETACTION, Curtain.get_action) -- Get current action e.g. "closing"
  Server:on(Server.GETPOS, Curtain.get_pos) -- Get current position e.g. "10"
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
