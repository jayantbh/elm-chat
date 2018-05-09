module Types exposing (..)

type alias Model = {
    ready : Bool,
    text : String,
    messages : List Message,
    user : Maybe String,
    color : String,
    updateCount_ : Int  -- ELM WORKAROUND FOR: http://package.elm-lang.org/packages/mdgriffith/style-elements/4.3.0/Element-Input#textKey
}

type alias Message = {
    time : Float,
    text : String,
    author : String,
    color : String
}

type alias Response = {
    type_ : String,
    data : String
}

type Msg
    = NoOp
    | SocketResponse String
    | UpdateInput String
    | TriggerEcho
    | UnexpectedPayload String
    | HistoryReceived ( List Message )
    | UserInit String
    | MessageReceived Message
