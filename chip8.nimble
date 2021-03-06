# Package

version       = "0.1.0"
author        = "emekoi"
description   = "a chip 8 emulator toolkit"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
skipExt       = @["nim"]
bin           = @["chip8", "c8asm", "c8dasm"]

# Dependencies

requires "nim >= 0.18.0"
requires "strfmt >= 0.8.5"
requires "syrup#head"

task run, "builds and runs the emulator":
  # pass extra params to build cmd
  var cmd = "nimble build "
  for p in 2..paramCount():
    cmd &= paramStr(p) & " "

  exec cmd

  # run binaries
  # for binary in bin:
  #   exec binDir & "/" & binary 

task chip8, "builds the emulator":
  exec "nimble c src/chip8 -o:bin/chip8"

task c8dasm, "builds the decompiler":
  exec "nimble c src/c8dasm -o:bin/c8dasm"

task c8asm, "builds the compiler":
  exec "nimble c src/c8asm -o:bin/c8asm"