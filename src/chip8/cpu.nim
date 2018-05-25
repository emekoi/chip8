#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import display, keyboard

const
  PROGRAM_START* = 0x200

type
  Chip8* = object
    opcode*: uint16
    mem*: array[4096, uint8]
    V*: array[16, uint8]
    I*: uint16
    pc*:uint16
    gfx*: Display
    delay_timer*: uint8
    sound_timer*: uint8
    stack*: array[16, uint16]
    sp*: uint16
    keys*: KeyBoard
    size*: uint16

proc newChip8*(filename: string): Chip8 =
  let
    file = filename.open()
    size = file.getFileSize()
  if file.readBytes(result.mem, 0x200, size) != size:
    raise newException(Exception, "error reading rom")
  result.size = size.uint16
  result.pc = PROGRAM_START


proc runCycle(c8: var Chip8) =
  # fetch opcode
  c8.opcode = c8.mem[c8.pc] shl 8
  c8.opcode = c8.opcode or c8.mem[c8.pc + 1]
  c8.pc += 2

  case c8.opcode shr 4:
  of 0x0: echo $c8.opcode & " not implemented"
  of 0x1: echo $c8.opcode & " not implemented"
  of 0x2: echo $c8.opcode & " not implemented"
  of 0x3: echo $c8.opcode & " not implemented"
  of 0x4: echo $c8.opcode & " not implemented"
  of 0x5: echo $c8.opcode & " not implemented"
  of 0x6: echo $c8.opcode & " not implemented"
  of 0x7: echo $c8.opcode & " not implemented"
  of 0x8: echo $c8.opcode & " not implemented"
  of 0x9: echo $c8.opcode & " not implemented"
  of 0xa: echo $c8.opcode & " not implemented"
  of 0xb: echo $c8.opcode & " not implemented"
  of 0xc: echo $c8.opcode & " not implemented"
  of 0xd: echo $c8.opcode & " not implemented"
  of 0xe: echo $c8.opcode & " not implemented"
  of 0xf: echo $c8.opcode & " not implemented"
  else: raise newException(Exception, "internal error")
  
proc run*(c8: var Chip8) = 
  while true:
    c8.runCycle()

    # if c8.drawFlag:
    #   c8.gfx.render()
