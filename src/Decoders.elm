module Decoders exposing (..)

import Types exposing (..)
import Json.Decode as JD exposing (Decoder, field, map, map4, int, float, string, list)
import Element exposing (Attribute)
import Element.Events exposing (keyCode, on)

payloadDecoder : Decoder Msg
payloadDecoder =
    field "kind" string
    |>  JD.andThen ( \kind ->
        case kind of
            "history" -> JD.map HistoryReceived (field "data" historyDecoder)
            "color" -> JD.map UserInit (field "data" string)
            "message" -> JD.map MessageReceived (field "data" messageDecoder)
            _ -> JD.fail ("Unexpected kind " ++ kind)
    )

decodePayload : String -> Msg
decodePayload payload =
  case JD.decodeString payloadDecoder payload of
    Err err ->
        UnexpectedPayload err
    Ok msg ->
        msg

messageDecoder : Decoder Message
messageDecoder =
    map4 Message
        ( field "time" float )
        ( field "text" string )
        ( field "author" string )
        ( field "color" string )

historyDecoder : Decoder ( List Message )
historyDecoder = list messageDecoder

onKeyDown : (Int -> msg) -> Attribute variation msg
onKeyDown tagger =
    on "keyup" (JD.map tagger keyCode)
