#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

type
  KeyPad {.pure.} = enum
    KEY_1 = "", KEY_2 = "", KEY_3 = "", KEY_C = "",
    KEY_4 = "", KEY_5 = "", KEY_6 = "", KEY_D = "",
    KEY_7 = "", KEY_8 = "", KEY_9 = "", KEY_E = "",
    KEY_A = "", KEY_0 = "", KEY_B = "", KEY_F = "",

  KeyBoard* = array[16, uint8]

when defined(EMULATOR):
  import syrup/keyboard

  proc update*(kb: var KeyBoard) = discard
else:
  proc update*(kb: var KeyBoard) = discard
