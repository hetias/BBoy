# BBoy
Small Gameboy Emulator writen from sratch using SDL2 and Zig

## Why?
This project mix two things that i enjoy, videogames and computer systems.
Understading how everythings plays out for a game to work in such a limited
system seems interesting to me.
Tho, theres no special reason why the gameboy. Could've been the NES or Chip-8,
the gameboy seemed interesting enough and well documented* to try it out.

## How
I will be using SDL2 and Zig for this project. I'm really used to SDL2, Zig
on the other hand it's a language still in development (at the moment of writting this,
its on version 0.13). But i'm tired of having to do basic stuff in C for the eleventh time
and C++ feels like using a shovel for spoon. Zig it's simpler than C++ but not limited like
C is. For good or bad, i've been using it a lot and it gaves me te impression of being a good
step forward from C whitout stepping on the complexities of C++ (let's not talk about rust, i 
procastinate a lot, and Rust it's gonna worse that part of me).

## Objectives
As said, the objective it's mostly learning purposes but in more practical terms the emulator
should be capable of some basic things:
* Running The legends of Zelda: Link's awakening
* Making save states
* Use of controllers
* Implementing audio and graphics
* Being playable (code execution and emulation being accuarate enough for playability)

## Resources
Clearly if you're here you maybe interested on writting something similar, or to understand it
here i leave some resources for your journey:
[Opcodes tables](https://meganesu.github.io/generate-gb-opcodes/)
[Opcodes Reference](https://rgbds.gbdev.io/docs/v0.7.0/gbz80.7)
[Boot ROM](https://gbdev.gg8.se/wiki/articles/Gameboy_Bootstrap_ROM#Contents_of_the_ROM)
[Boot ROM overview](https://realboyemulator.wordpress.com/2013/01/03/a-look-at-the-game-boy-bootstrap-let-the-fun-begin/)
[Pan Docs](https://gbdev.io/pandocs/About.html)
[Gameboy Technical Reference](https://gekkio.fi/files/gb-docs/gbctr.pdf)
[Gameboy CPU manual](http://marc.rawer.de/Gameboy/Docs/GBCPUman.pdf)
[Cycle Accuarate Gameboy Docs](https://raw.githubusercontent.com/geaz/emu-gameboy/master/docs/The%20Cycle-Accurate%20Game%20Boy%20Docs.pdf)
[Emulation Programming](http://www.xsim.com/papers/Bario.2001.emubook.pdf)
With this i whish to save you some headhaches, besides of whatever my code does.
