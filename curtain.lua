-- Curtain module converts the percentage by which the curtain
-- should be open to and from servo cycles
-- and stores the current state of the curtain

dofile("servo.lua")

Curtain = {
  STOPPED = "stopped",
  OPENING = "opening",
  CLOSING = "closing",

  position = 0, -- fully open
  -- How long should the servo spin to change the curtain position by 1%
  duration_per_percent = 1000,
  direction_open = Servo.CLOCKWISE,
  direction_close = Servo.CTR_CLOCKWISE,
  upd_timer = tmr.create()
}

function Curtain.init(config)
  Servo.init({pin = config.pin})
end

function Curtain.set_position(percent)
  if percent < 0 or percent > 100 then
    return "error"
  end

  print("Setting the state " .. percent)
  local duration
  local percent_to_change = percent - Curtain.position
  print("Percent to change " .. percent_to_change)

  if percent_to_change > 0 then
    print("Closing the curtain")
    Curtain.current_direction = Curtain.direction_close
    duration = percent_to_change * Curtain.duration_per_percent
  elseif percent_to_change < 0 then
    print("Opening the curtain")
    Curtain.current_direction = Curtain.direction_open
    duration = -1 * percent_to_change * Curtain.duration_per_percent
  else
    return
  end

  Curtain.upd_timer:alarm(Curtain.duration_per_percent, tmr.ALARM_AUTO, function(t)
    Curtain:update_state(t)
  end)
  Servo.spin({direction = Curtain.current_direction, duration = duration}, function()
    Curtain.current_direction = nil
  end)
  return
end

function Curtain.get_state()
  print("Getting state " .. Curtain.position)
  return Curtain.position .. "\n" .. Curtain.get_action()
end

function Curtain.stop()
  print("Stopping...")
  Servo.stop()
  Curtain.current_direction = nil
end

function Curtain.reset(pos)
  if pos ~= nil then
    Curtain.position = pos
  end
end

function Curtain.get_action()
  if Curtain.current_direction == nil then
    return Curtain.STOPPED
  elseif Curtain.current_direction == Curtain.direction_open then
    return Curtain.OPENING
  elseif Curtain.current_direction == Curtain.direction_close then
    return Curtain.CLOSING
  else
    return "unkown action"
  end
end

function Curtain.get_pos()
  return tostring(Curtain.position)
end

-- Private

function Curtain:update_state(timer)
  if self.current_direction == nil then
    timer:stop()
  elseif self.current_direction == self.direction_open then
    if self.position == 0 then
      timer:stop()
    else
      self.position = self.position - 1
    end
  elseif self.current_direction == self.direction_close then
    if self.position == 100 then
      timer:stop()
    else
      self.position = self.position + 1
    end
  end
end
