Usage was written to be entered into the IronCoder competition.  It demonstrates using CoreGraphics to create simple gradients and patterns.

# What it does

The theme for IC was "time" and I couldn't stop thinking about calendars and clocks.  Process CPU usage time was the first non-date thing I thought of that fit the theme so I went with it.  Usage runs `top` and then parses the results to display information about how much time each process spends utilizing the CPU and the percentage of total time that represents.

# Scripting

Usage has scripting support for no other reason other than I was bored.  I tried using `sysctl` to get information about running processes but I couldn't figure out how to get time spent on CPU (if you know, email me, I'm still curious).  I eventually gave up and found myself with several hours before the competition ended.  This little app only took a couple of hours to put together using `top` and I spent a day trying to find information on using something else so I figured I'd do something with the spare time. I added Applescript-support because, frankly, I like it and it's really easy to implement (with Suite Modeler).  I also added Lua script support just because I could.  I've been working with the LuaObjCBridge a lot lately and find that I like dropping it into everything I work with.  Since I had a few extra hours, I figured, "Why not?"

# Special thanks

Thanks to Daniel Jalkut for RSVerticallyCenteredTextFieldCell and Tom McClean for the LuaObjCBridge.

# Disclaimer

This code leaks memory and pours sugar in your gas tank.

# Author

Grayson Hansard
info@fromconcentratesoftware.com
http://www.fromconcentratesoftware.com/