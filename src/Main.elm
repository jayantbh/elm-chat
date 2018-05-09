module Main exposing (..)

import Html exposing (Html, img, form, div, li, ul, small, strong)
import WebSocket
import Date.Format as DF
import Date
import Dom
import Dom.Scroll
import Task
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Element.Input as Input exposing (placeholder)

import Types exposing (..)
import Stylesheet exposing (..)
import Decoders exposing (..)

initModel : Model
initModel = {
    ready = False,
    text = "",
    messages = [],
    user = Nothing,
    color = "white",
    updateCount_ = 0 }

focusReplyBox : Cmd Msg
focusReplyBox = Task.attempt (always NoOp) (Dom.focus "reply-field")

scrollChatsToBottom : Cmd Msg
scrollChatsToBottom = Task.attempt (always NoOp) (Dom.Scroll.toBottom "chat-history")


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.batch [focusReplyBox, scrollChatsToBottom] )



---- UPDATE ----




update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
        SocketResponse json ->
            let
                nextMsg = decodePayload json
            in
                update nextMsg model
        UpdateInput str ->       
            ( { model | text = str }, Cmd.none )
        TriggerEcho ->
            let
                message = model.text
                msg = ( WebSocket.send "ws://localhost:1337" message )
            in
                ( { model | text = "", updateCount_ = model.updateCount_ + 1 }, Cmd.batch [msg, focusReplyBox])
        UnexpectedPayload err ->
            Debug.crash ("ERROR " ++ err)
            ( model, Cmd.none )
        HistoryReceived messages ->
                ( { model | messages = messages }, scrollChatsToBottom )
        UserInit color ->
            ( { model | color = color, ready = True }, Cmd.none )
        MessageReceived message ->
            let
                updatedMessages = List.concat [model.messages, [message]]
            in
                ( { model | messages = updatedMessages }, scrollChatsToBottom )


---- VIEW ----

view : Model -> Html Msg
view model =
    viewport stylesheet <|
        column Body [ padding 9, height fill ]
            [ full Header [ padding 9 ] <| row None [] [
                image None [ height (px 30), width (px 30), verticalCenter ] { src = "/logo.svg", caption = "Logo" },
                h1 Title [ paddingLeft 9, verticalCenter ] ( text "Websocket Experiment" ),
                h2 Bold [ paddingLeft 9, alignBottom ] ( text "Experimental Elm Chat App" )
            ],
            el None [ id "chat-history", height fill, yScrollbar, paddingXY 0 9 ] (
                if List.length model.messages > 0 then
                    viewMessage model.messages
                else
                    text "No messages yet..."
            ),
            full ReplyArea [ padding 9 ] <| node "form" <| row None [ onSubmit TriggerEcho ] [
                Input.text None [ id "reply-field", padding 9 ] {
                        onChange = UpdateInput,
                        value = model.text,
                        label = Input.placeholder {
                                label = Input.labelLeft (el ReplyLabel [ vary Heavy model.ready, verticalCenter, paddingRight 9, inlineStyle [ ( "color", model.color ) ] ] (text (if model.ready then "Enter text" else "Enter username"))),
                                text = "Type here and send..."
                            },
                        options = [ Input.textKey (toString model.updateCount_) ]
                    }
                ]
            ]


viewMessage : List Message -> Element AppStyles variation msg
viewMessage messages =
    messages
    |> List.map (\message -> row None [] [
            el None [ paddingRight 9 ] ( text (DF.format "%H:%M:%S" (Date.fromTime message.time)) ),
            el Bold [ paddingRight 9, inlineStyle [ ( "color", message.color ) ] ] ( text message.author ),
            el None [ paddingRight 9 ] ( text message.text )
        ])
    |> column None []


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:1337" SocketResponse


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
