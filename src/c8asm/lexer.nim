#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import streams, strutils, strfmt

type
  TokenType* {.pure.} = enum
    LIST,
    IMMEDIATE,
    REGISTER,
    ADDRESS,
    IDENTIFIER,
    PARSE_END

  Token* = object
    case kind*: TokenType
    of TokenType.IMMEDIATE:
      value*: uint
    of TokenType.REGISTER:
      register*: uint
    of TokenType.ADDRESS:
      address*: uint
    of TokenType.IDENTIFIER:
      identifier*: string
    of TokenType.LIST:
      tokens*: seq[Token]
    of TokenType.PARSE_END:
      discard
  
  Lexer* = object
    source*: Stream
    line*, col*: int
    pcount: int

proc `$`*(t: Token): string =
  case t.kind:
  of TokenType.IMMEDIATE:
    return $t.value
  of TokenType.REGISTER:
    return $t.register
  of TokenType.ADDRESS:
    return $t.address
  of TokenType.IDENTIFIER:
    return t.identifier
  of TokenType.LIST:
    result = "("
    for t in t.tokens:
      result &= $t & " "
    result[result.len - 1] = ')'
  of TokenType.PARSE_END:
    return ""

proc `[]`*(t: Token, idx: SomeInteger): Token =
  return t.tokens[idx]

proc len*(t: Token): int =
  return t.tokens.len

proc newLexer*(s: Stream): Lexer =
  result.source = s
  result.pcount = 0
  result.line = 0
  result.col = 0

proc skipWhiteSpace(l: var Lexer) =
  while true:
    var c = l.source.peekChar()
    while c in Whitespace:
      if c in NewLines:
        l.line += 1
        l.col = 0
      discard l.source.readChar()
      c = l.source.peekChar()
    return

proc peekChar(s: Stream, offset: int): char =
  let p = s.getPosition()
  s.setPosition(p + offset)
  result = s.peekChar()
  s.setPosition(p)

template isImmediateHex(l: Lexer, c: char): untyped =
  c == '0' and l.source.peekChar(1) == 'x'

proc getImmediateHex(l: var Lexer): Token =
  result.kind = TokenType.IMMEDIATE
  discard l.source.readChar()
  discard l.source.readChar()
  var
    buf = ""
    c = l.source.peekChar()
  while c in HexDigits:
    buf &= $l.source.readChar()
    c = l.source.peekChar()
  result.value = parseHexInt(buf).uint

template isImmediateDec(l: Lexer, c: char): untyped =
  c in Digits and l.source.peekChar(1) != 'x'

proc getImmediateDec(l: var Lexer): Token =
  result.kind = TokenType.IMMEDIATE
  var
    buf = ""
    c = l.source.peekChar()
  while c in Digits:
    buf &= $l.source.readChar()
    c = l.source.peekChar()
  result.value = parseUint(buf)

template isImmediate(l: Lexer, c: char): untyped =
  l.isImmediateDec(c) or l.isImmediateHex(c)

proc getImmediate(l: var Lexer, c: char): Token =
  if l.isImmediateDec(c):
    result = l.getImmediateDec()
  elif l.isImmediateHex(c):
    result = l.getImmediateHex()

template isRegister(l: Lexer, c: char): untyped =
  c == '@'

proc getRegister(l: var Lexer): Token =
  result.kind = TokenType.REGISTER
  discard l.source.readChar()
  result.register = parseHexInt($l.source.readChar()).uint

template isAddress(l: Lexer, c: char): untyped =
  c == '$' 

proc getAddress(l: var Lexer): Token =
  result.kind = TokenType.ADDRESS
  discard l.source.readChar()
  let
    c = l.source.peekChar()
    a = l.getImmediate(c)
  result.address = a.value

template isIdentifier(l: Lexer, c: char): untyped =
  c in IdentStartChars

proc getIdentifier(l: var Lexer): Token =
  result.kind = TokenType.IDENTIFIER
  var c = l.source.peekChar()
  result.identifier = ""
  while c in IdentChars:
    result.identifier &= $l.source.readChar()
    c = l.source.peekChar()

proc getTokens*(l: var Lexer): Token =
  let start = l.source.getPosition()
  l.skipWhiteSpace()
  var c = l.source.peekChar()

  if l.source.getPosition() == 0 and c != '(':
    raise newException(Exception, fmt("expected '(' at ({:d}, {:d})", l.line, l.col))

  if c == '\0':
    return Token(kind: TokenType.PARSE_END)
  elif c == '(':
    l.pcount += 1
    discard l.source.readChar()
    var val = l.getTokens()
    c = l.source.peekChar()
    result.tokens = @[]
    while val.kind != TokenType.PARSE_END:
      result.tokens.add(val)
      val = l.getTokens()    
  elif c == ')':
    l.pcount -= 1
    discard l.source.readChar()
    return Token(kind: TokenType.PARSE_END)
  elif l.isImmediate(c):
    result = l.getImmediate(c)
  elif l.isRegister(c):
    result = l.getRegister()
  elif l.isAddress(c):
    result = l.getAddress()
  elif l.isIdentifier(c):
    result = l.getIdentifier()
  else:
    raise newException(Exception, "invalid token: '" & $c)

  l.col += (l.source.getPosition() - start)

