#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

import
  streams, sequtils, tables, strfmt,
  c8asm/[
    lexer,
    builtins
  ]



type
  Assembler* = object
    env*: Table[string, Builtin]
    code*: seq[uint8]
    lexer*: Lexer
    root*: Token
    idx*: int

proc newAssembler*(s: Stream): Assembler =
  result.lexer = s.newLexer()
  result.root = result.lexer.getTokens()
  result.code = @[]
  result.idx = 0

proc assemble*(a: var Assembler) =
  for tok in a.root.tokens:
    if tok.kind != TokenType.LIST:
      quit(fmt("expected LIST got {:s}", $tok.kind), QuitFailure)
    if tok[0].kind != TokenType.IDENTIFIER:
      quit(fmt("expected IDENTIFIER got {:s}", $tok.kind), QuitFailure)
    if not BUILTINS.hasKey(tok[0].identifier):
      quit(fmt("unknown KEYWORD '{:s}'", tok[0].identifier), QuitFailure)
    a.code = a.code.concat(BUILTINS[tok[0].identifier](tok))

proc dump*(a: var Assembler, output: Stream) =
  printfmt("@[{:X}, ", a.code[0])
  for i in 1..<(a.code.len - 1):
   printfmt("{:X}, ", a.code[i])
  printlnfmt("{:X}]", a.code[a.code.len - 1])
  # output.writeData(a.code.unsafeAddr(), a.code.len)

when isMainModule:
  import os

  proc basename(s: string): string =
    result = s
    for i in countdown(s.len - 1, 0):
      if s[i] == '.': return s[0..<i]

  if paramCount() > 0:
    var
      input, output: Stream
      
    try:
      input = open(paramStr(1), fmRead).newFileStream()
    except:
      quit(fmt("unable to open file '{:s}'", paramStr(1)), QuitFailure)

    try:
      var file =
        if paramCount() > 1:
          paramStr(2)
        else:
          paramStr(1).basename() & ".out"
      output = open(file, fmWrite).newFileStream()
    except:
      quit(fmt("unable to open file '{:s}'", paramStr(2)), QuitFailure)

    var a = input.newAssembler()
    a.assemble()
    a.dump(output)
  else:
    quit(fmt("usage: input output"), QuitSuccess)
