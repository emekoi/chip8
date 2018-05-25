#  Copyright (c) 2018 emekoi
#
#  This library is free software; you can redistribute it and/or modify it
#  under the terms of the MIT license. See LICENSE for details.
#

const
  WIDTH* = 64
  HEIGHT* = 32

type
  Display* = array[WIDTH * HEIGHT, uint8]

when defined(EMULATOR):
  import
    syrup,
    syrup/graphics

  let
    SCALEX = WIDTH / syrup.getWidth()
    SCALEY = HEIGHT / syrup.getHeight()

  var DISPLAY_BUFFER = newBuffer(WIDTH, HEIGHT)

  proc render*(d: Display) =
    DISPLAY_BUFFER.loadPixels8(d)
    graphics.copyPixels(DISPLAY_BUFFER, 0, 0, SCALEX, SCALEY)
    DISPLAY_BUFFER.clear(color(0, 0, 0))
else:
  proc render*(d: Display) = discard
