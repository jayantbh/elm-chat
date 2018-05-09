module Stylesheet exposing (..)

import Style exposing (..)
import Style.Color as Color exposing (..)
import Style.Font as Font exposing (typeface, font, size, weight, lineHeight)
import Color exposing (..)

type AppStyles
  = None
  | Header
  | Body
  | Title
  | Logo
  | Bold
  | ChatItem
  | ReplyArea
  | ReplyLabel

type Variations
  = Heavy

stylesheet = styleSheet [
    style None [ ],
    style Header [
      background black
    ],
    style Body [
      text (Color.rgb 107 107 107),
      background white,
      typeface [
        font "Source Sans Pro",
        font "Trebuchet MS", 
        font "Lucida Grande", 
        font "Bitstream Vera Sans", 
        font "Helvetica Neue",
        font "sans-serif"
      ]
    ],
    style Title [
      size 30,
      lineHeight 1,
      weight 700,
      text grey
    ],
    style Bold [
      weight 700
    ],
    style ReplyArea [
      background black
    ],
    style ReplyLabel [
      text grey,
      variation Heavy [
        weight 700
      ]
    ]
  ] 
