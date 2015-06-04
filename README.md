What Is it?
==================
This project implements a wireless intercom system using the RFM12B radio
module and the Atmega 328P microcontroller running the Arduino environment.

Why Does it Exist?
===================
I wanted a wireless intercom so I could stop shouting up the stairs at the kids.

The consensus on the web was that the RFM12B is not suitable for speech: challenge!

What Does It Do?
===================
Implements a five-station intercom with the following features:

  - Call each station individually (station to station)
  - Call all stations together (broadcast)
  - LED indicates which station is calling
  - Uses low power sleep modes when not in use giving up to 3 months life on a PP3 battery
  
How Does It Do It?
===================

  - Atmega 328P running at 16MHz
  - Microphone AGC circuit
  - 8-bit audio sampled at 8kHz
  - RFM12B running at 115kBaud
  - Range in excess of 20m (depends on length of aerial)

What's Wrong With It?
======================
The circuit design is fine and works well, but:

  - Battery life could be better - the RFM12B is a bit of a hog. Use a 9V wall-wart if you're bothered.
  - The PCB layout sucks. Sorry. If I had time I'd do it again using SMD parts, and I'd probably 
  use a more modern, lower power replacement for the RFM12B.
  
Dependencies
=================
Relies on my RFM12B library - a non-blocking, event-driven implementation. Get it here:

https://github.com/ukmaker/RFM12BE

