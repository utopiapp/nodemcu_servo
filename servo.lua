-- Servo module stores the servo-specific constants, conversions to and from
-- the curtain state percentages to the servo cycles
-- (the number of seconds the servo has to run in one direction to
-- open or close the curtain by a certain amount),
-- and the state of the servo / curtain

Servo = {
  CLOCKWISE = 20,
  CTR_CLOCKWISE = 120,

  timer = tmr.create()
}

local FREQUENCY = 50

function Servo.init(cfg)
  Servo.pin = cfg.pin
  gpio.mode(Servo.pin, gpio.OUTPUT)
  pwm.setup(Servo.pin, FREQUENCY, Servo.CLOCKWISE)
end

function Servo.spin(opt, done)
  print("Spinning " .. opt.direction .. " for " .. opt.duration)
  pwm.stop(Servo.pin) -- Stop whatever it was doing before
  pwm.setduty(Servo.pin, opt.direction)
  pwm.start(Servo.pin)
  Servo.timer:alarm(opt.duration, tmr.ALARM_SINGLE, function()
    done()
    pwm.stop(Servo.pin)
  end)
end

function Servo.stop()
  pwm.stop(Servo.pin)
end
