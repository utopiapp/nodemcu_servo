-- Server package is a TCP server listening for incoming connections

Server = {
  ip = nil,
  port = nil,
  srv = nil,
  callbacks = {}
}

function Server.listen(config)
  server = Server{
    ip = config.ip,
    port = config.port,
  }

  print("Creating a server...")
  srv = net.createServer(net.TCP, 30)
  if srv then
    print("Listening on the port " .. server.port)
    srv:listen(server.port, function(conn)
      conn:on("receive", server:receive)
    end)

    server.srv = srv

    return server
  else
    print("No server!")
  end
end

function Server:receive(sck, data)
  print(data)
  -- self.callbacks[data[0]](data[1])
  sck:close()
end

function Server:on(event, callback)
  self.callbacks[event] = callback
end
