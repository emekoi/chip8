#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import chip8/cpu, strfmt

proc dissassemble(c8: var Chip8) =
  {.computedGoto.}
  while (c8.pc - PROGRAM_START) < c8.size:
    # fetch opcode
    let
      hi = c8.mem[c8.pc].uint16 shl 8
      lo = c8.mem[c8.pc + 1].uint16
    c8.opcode = hi or lo
    
    printfmt "{:04X} {:02X} {:02X} ", c8.pc, hi shr 8, lo

    let opNibble = c8.opcode and 0xf000
    case opNibble:
      of 0x0000:
        case c8.opcode and 0x0fff:
          of 0x00e0:
            printlnfmt "{:<10s}", "CLS"
          of 0x00ee:
            printlnfmt "{:<10s}", "RET"
          else:
            if (c8.opcode and 0x0fff) != 0x0000:
              printlnfmt "{:<10s} ${:03X}", "RCA", c8.opcode and 0x0fff
              discard newException(Exception, fmt("opcode {:04X} not supported", c8.opcode))
            else:
              printlnfmt ""
      of 0x1000:
        printlnfmt "{:<10s} ${:03X}", "JMP", c8.opcode and 0x0fff
      of 0x2000:
        printlnfmt "{:<10s} ${:03X}", "CSB", c8.opcode and 0x0fff
      of 0x3000:
        let reg = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} V{:01X}, #${:02X}", "JEQ", reg, c8.mem[c8.pc + 1]
      of 0x4000:
        let reg = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} V{:01X}, #${:02X}", "JNE", reg, c8.mem[c8.pc + 1]
      of 0x5000:
        let reg = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} V{:01X}, V{:01X}", "JEQ", reg, c8.mem[c8.pc + 1] shr 4
      of 0x6000:
        let reg = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} V{:01X}, #${:02X}", "MVI", reg, c8.mem[c8.pc + 1]
      of 0x7000:
        printlnfmt "{:X} not implemented", opNibble
      of 0x8000:
        printlnfmt "{:X} not implemented", opNibble
      of 0x9000:
        let reg = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} V{:01X}, V{:01X}", "JNE", reg, c8.mem[c8.pc + 1] shr 4
      of 0xa000:
        let addresshi = c8.mem[c8.pc] and 0x0f
        printlnfmt "{:<10s} I, #${:01X}{:02X}", "MVI", addresshi, c8.mem[c8.pc + 1]
      of 0xb000:
        printlnfmt "{:<10s} {:03X}(V0)", "JMP", c8.opcode and 0x0fff
      of 0xc000:
        printlnfmt "{:X} not implemented", opNibble
      of 0xd000:
        printlnfmt "{:X} not implemented", opNibble
      of 0xe000:
        printlnfmt "{:X} not implemented", opNibble
      of 0xf000:
        printlnfmt "{:X} not implemented", opNibble
      else: raise newException(Exception, fmt("invalid opcode {:04X}", opNibble))

    c8.pc += 2
    c8.opcode = 0
  
  c8.pc = PROGRAM_START
  c8.opcode = 0

when isMainModule:
  import os

  if paramCount() > 0:
    var c8 = newChip8(paramStr(1))
    c8.dissassemble()
  else:
    echo "Usage: c8dasm file.c8asm"