#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import strfmt, tables, lexer

type Builtin* = proc(t: Token): seq[uint8]

var BUILTINS* = newTable[string, Builtin]()

proc cls(t: Token): seq[uint8] =
  if t.len() > 1:
    raise newException(Exception, "too many arguments to 'cls'")
  result = @[0xE0'u8]

proc ret(t: Token): seq[uint8] =
  if t.len() > 1:
    raise newException(Exception, "too many arguments to 'ret'")
  result = @[0xEE'u8]

proc jmp(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'jmp'")
  if t.len() > 2:
    raise newException(Exception, "too many arguments to 'jmp'")
  if t[1].kind != TokenType.ADDRESS:
    raise newException(Exception, fmt("expected ADDRESS got {:s}", $t[0].kind))
  if t[1].address > 0xFFF'u:
    raise newException(Exception, fmt("invalid ADDRESS ${:X}", t[1].address))
  let tmp = t[1].address.uint16
  result[0] = 0x10'u8 or ((tmp and 0xF00) shr 8).uint8
  result[1] = (tmp and 0x0FF).uint8

proc call(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'call'")
  if t.len() > 2:
    raise newException(Exception, "too many arguments to 'call'")
  if t[1].kind != TokenType.ADDRESS:
    raise newException(Exception, fmt("expected IDENTIFIER got {:s}", $t[0].kind))
  if t[1].address > 0xFFF'u:
    raise newException(Exception, fmt("invalid IDENTIFIER ${:X}", t[1].address))
  let tmp = t[1].address.uint16
  result[0] = 0x20'u8 or ((tmp and 0xF00) shr 8).uint8
  result[1] = (tmp and 0x0FF).uint8

proc sei(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'sei'")
  if t.len() > 3:
    raise newException(Exception, "too many arguments to 'sei'")
  if t[1].kind != TokenType.REGISTER:
    raise newException(Exception, fmt("expected REGISTER got {:s}", $t[0].kind))
  if t[1].register > 0xF'u:
    raise newException(Exception, fmt("invalid REGISTER @{:X}", t[1].address))
  if t[2].kind != TokenType.IMMEDIATE:
    raise newException(Exception, fmt("expected IMMEDIATE got {:s}", $t[0].kind))
  if t[2].value > 0xFF'u:
    raise newException(Exception, fmt("invalid IMMEDIATE {:X}", t[1].address))
  result[0] = 0x30'u8 or t[1].register.uint8
  result[1] = t[2].value.uint8

proc sni(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'sei'")
  if t.len() > 3:
    raise newException(Exception, "too many arguments to 'sei'")
  if t[1].kind != TokenType.REGISTER:
    raise newException(Exception, fmt("expected REGISTER got {:s}", $t[0].kind))
  if t[1].register > 0xF'u:
    raise newException(Exception, fmt("invalid REGISTER @{:X}", t[1].address))
  if t[2].kind != TokenType.IMMEDIATE:
    raise newException(Exception, fmt("expected IMMEDIATE got {:s}", $t[0].kind))
  if t[2].value > 0xFF'u:
    raise newException(Exception, fmt("invalid IMMEDIATE {:X}", t[1].address))
  result[0] = 0x40'u8 or t[1].register.uint8
  result[1] = t[2].value.uint8

proc ser(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'sei'")
  if t.len() > 3:
    raise newException(Exception, "too many arguments to 'sei'")
  if t[1].kind != TokenType.REGISTER:
    raise newException(Exception, fmt("expected REGISTER got {:s}", $t[0].kind))
  if t[1].register > 0xF'u:
    raise newException(Exception, fmt("invalid REGISTER @{:X}", t[1].address))
  if t[2].kind != TokenType.IMMEDIATE:
    raise newException(Exception, fmt("expected IMMEDIATE got {:s}", $t[0].kind))
  if t[2].value > 0xFF'u:
    raise newException(Exception, fmt("invalid IMMEDIATE {:X}", t[1].address))
  result[0] = 0x50'u8 or t[1].register.uint8
  result[1] = t[2].value.uint8

proc ld(t: Token): seq[uint8] =
  result = @[0'u8, 0'u8]
  if t.len() == 0:
    raise newException(Exception, "too few arguments to 'sei'")
  if t.len() > 3:
    raise newException(Exception, "too many arguments to 'sei'")
  if t[1].kind != TokenType.REGISTER:
    raise newException(Exception, fmt("expected REGISTER got {:s}", $t[0].kind))
  if t[1].register > 0xF'u:
    raise newException(Exception, fmt("invalid REGISTER @{:X}", t[1].address))
  if t[2].kind != TokenType.IMMEDIATE:
    raise newException(Exception, fmt("expected IMMEDIATE got {:s}", $t[0].kind))
  if t[2].value > 0xFF'u:
    raise newException(Exception, fmt("invalid IMMEDIATE {:X}", t[1].address))
  result[0] = 0x50'u8 or t[1].register.uint8
  result[1] = t[2].value.uint8

block initBuiltins:
  BUILTINS["cls"] = cls
  BUILTINS["ret"] = ret
  BUILTINS["jmp"] = jmp
  BUILTINS["call"] = call
  BUILTINS["sei"] = sei
  BUILTINS["sni"] = sni
  BUILTINS["ser"] = ser