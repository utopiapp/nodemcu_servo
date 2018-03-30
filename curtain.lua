-- Curtain module converts the percentage by which the curtain
-- should be open to and from servo cycles
-- and stores the current state of the curtain

Curtain = {
  state = 0,
  pin = nil,
}

function Curtain.init(config)
    curtain = Curtain{state = 0, pin = config.pin}
    return curtain
end

function Curtain:set_state(percentage)
  print("Setting the state " .. percentage)
end

function Curtain:get_state()
  print("Getting state " .. self.state)
  return self.state
end
