-- Server package is a TCP server listening for incoming connections

Server = {
  GETSTATE = "getstate",
  SETPOS = "setpos",
  STOP = "stop",
  RESET = "reset",
  GETACTION = "getaction",
  GETPOS = "getpos",

  srv = net.createServer(net.TCP, 30),
  callbacks = {},
  timer = tmr.create()
}

function Server:listen(config)
  self.ip = config.ip
  self.port = config.port
  self.poll_frequency = config.poll_frequency
  self.action_stopped = config.action_stopped

  if self.srv then
    print("Listening on the port " .. self.port)
    self.srv:listen(self.port, function(conn)
      -- Persist current connection so it can be passed to callbacks.
      -- This allows for the new connection to start receiving the updates
      -- the old connection requested
      Server.socket = conn
      conn:on("receive", function(sck, data) Server:receive(sck, data) end)
      -- On disconnect set the persisted socket to nil so that Server
      -- doesn't attempt to write into a disconnected socket
      conn:on("disconnection", function(sck, data) Server.socket = nil end)
    end)
  else
    print("No server!")
  end
end

function Server:on(event, callback)
  print("Registering a callback for event " .. event)
  self.callbacks[event] = callback
end

-- Private

-- Polls Curtain for the position
function Server.send_state_update(timer)
  local position = Server.callbacks[Server.GETPOS]()
  local action = Server.callbacks[Server.GETACTION]()

  if Server.socket == nil then
    return
  end

  Server.socket:send(position .. "\n")

  if action == Server.action_stopped then
    Server.socket:send(action .. "\n")
    timer:stop()
  end
end

function Server:receive(sck, data)
  print("Received data " .. data)
  local rsp = "error" -- default response

  local req = string.match(data, "%a+")
  local num = string.match(data, "%d+")

  if num ~= nil then
    num = tonumber(num)
  end

  if req == nil then
    sck:send("error\n")
    return
  end

  local callback = self.callbacks[req]
  if callback == nil then
    sck:send("error\n")
    return
  end

  rsp = callback(num)

  if req == self.SETPOS then
    self.socket:send(Server.callbacks[Server.GETACTION]() .. "\n")
    self.timer:alarm(Server.poll_frequency, tmr.ALARM_AUTO, Server.send_state_update)
  end

  if rsp ~= nil and rsp ~= "" then
    sck:send(tostring(rsp) .. "\n")
  end
end
