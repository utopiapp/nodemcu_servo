# 🏡 A curtain automation with NodeMCU and a servo motor

This repo contains a Lua program for a [NodeMCU](http://nodemcu.com/index_cn.html) board with a 360º servo motor connected to it. The board connects to the WiFi network with the provided credentials and listens to incoming TCP connections. Once a connection is established, it listens to a set of commands to spin the servo clockwise or counter-clockwise. To automate the curtains in your flat attach the servo to a curtain pulling system, set up how long does it need to spin in either direction to open / close the curtain by 1% and what spin direction is closing / opening.

# 🔧 Hardware

NodeMCU is an open source board layout and firmware. I've used [this](https://www.amazon.co.uk/gp/product/B01N5D3MV8/ref=oh_aui_detailpage_o04_s00?ie=UTF8&psc=1) board.

I've used a 360º continuous rotation servo motor from [Kookye](https://www.amazon.co.uk/gp/product/B071DW6F7K/ref=oh_aui_detailpage_o06_s00?ie=UTF8&psc=1). It has enough torque to pull the curtain and can draw power from the board rather than having a separate power source.

I've also used three male-female jumper cables to connect the board to the motor.

## 🔌 Connecting the motor to the board

The motor has three wires - power, ground and signal. Connect the power wire to the `3V3` pin on the board, ground to the `GND` pin and signal to any of the GPIO pins supporting PWM (Pulse Width Modulation). I used `D5`.

# 💾 Programming NodeMCU on Mac OS

To upload firmware or code to the NodeMCU board you need to install a USB to UART driver. You can download it from [here](https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers).

Connect the board to your computer with a microUSB cable.

:warning: Be careful not to use a power-only USB cable! These cables are missing the data line and can't transmit signal.

Install the driver and check if it works by running `ls /dev/cu.*`. You should see a `/dev/cu.SLAB_USBtoUART` device.

If the installer didn't work, install the driver manually (TODO: finish a blog post about it).

# 📟 Firmware

You need to build and upload the firmware to the NodeMCU board before you can run any Lua code on it.

To build the firmware use the [cloud build service](https://nodemcu-build.com/index.php).

:heavy_exclamation_mark: Make sure to include the `PWM` module.

To flash the firmware to the board download and install [ESPtool](https://github.com/espressif/esptool).

`cd` into the `esptool` directory and run : `python esptool.py --port=/dev/cu.SLAB_USBtoUART  write_flash  -fm=dio -fs=32m 0x00000 path_to_your_firmware_build.bin`.

# 📋 Uploading code

To upload and run code on the NodeMCU board install [NodeMCU-Tool](https://github.com/andidittrich/NodeMCU-Tool).

To upload the project run `nodemcu-tool -p /dev/cu.SLAB_USBtoUART upload your_file.lua`

To run the code on the board run `nodemcu-tool -p /dev/cu.SLAB_USBtoUART run your_file.lua`

A file named `init.lua` will run automatically when board restarts. To restart the board press the `RST` button.

# 🏃‍ Running the project

First, copy `config_example.lua` to `config.lua` and replace the WiFi credentials.

Then upload all files of the project on the board: `nodemcu-tool -p /dev/cu.SLAB_USBtoUART upload curtain.lua servo.lua config.lua server.lua init.lua`

Press the `RST` button on the board, the init file should be running.

You can open the terminal connecting to the board with `nodemcu-tool -p /dev/cu.SLAB_USBtoUART terminal` to see the IP address of the board.

Once you've got the IP, you can connect to it with `telnet` and run commands!

# 🤖 The API

- `getstate`: Returns the current state of the curtain - position in % and the current action (`opening`, `closing`, `stopped`) separated by a newline.
- `setpos N`: Sets a new position for the curtain. Immediately after receiving this command the board will return the current action (`opening`, `closing` or `stopped`) and will start writing the current position every 1% until it reaches the new set position.
- `stop`: Stops the current action.
- `reset N`: Should be used to recalibrate the curtain position. Resets the current state of the curtain without actually moving it.
- `getaction`: Returns the current action - `opening`, `closing` or `stopped`.
- `getpos`: Returns the current position in %
