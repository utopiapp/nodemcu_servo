-- Servo module stores the servo-specific constants, conversions to and from
-- the curtain state percentages to the servo cycles
-- (the number of seconds the servo has to run in one direction to
-- open or close the curtain by a certain amount),
-- and the state of the servo / curtain

local servo_frequency = 50
local clockwise = 20
local ctr_clockwise = 120

gpio.mode(pin, gpio.OUTPUT)
pwm.setup(pin, servo_frequency, ctr_clockwise)

function spin(direction)
   print("Spinning " .. direction)
   pwm.setduty(pin, direction)
   pwm.start(pin)
end

function startup()
   spin(ctr_clockwise)
   tmr.alarm(2, 3000, tmr.ALARM_SINGLE, function() spin(clockwise) end)
end
