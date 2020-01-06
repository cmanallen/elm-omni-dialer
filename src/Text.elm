module Text exposing (Model, Msg, init, update, view)

import Html exposing (..)
import Html.Events exposing (onInput)


type alias Model =
    { to : Maybe String
    , from : Maybe String
    , contact : Maybe String
    , textBody : Maybe String
    , textMessage : Maybe String
    , textTemplate : Maybe String
    }


type Msg
    = SetTo String
    | SetFrom String
    | SetContact String
    | SetTextBody String
    | SetTextMessage String
    | SetTextTemplate String
    | CreateTextMessage
    | SendText


init : ( Model, Cmd Msg )
init =
    ( { to = Nothing
      , from = Nothing
      , contact = Nothing
      , textBody = Nothing
      , textMessage = Nothing
      , textTemplate = Nothing
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetTo to ->
            ( { model | to = Just to }, Cmd.none )

        SetFrom from ->
            ( { model | from = Just from }, Cmd.none )

        SetContact contact ->
            ( { model | contact = Just contact }, Cmd.none )

        SetTextBody body ->
            ( { model | textBody = Just body }, Cmd.none )

        SetTextMessage textMessage ->
            ( { model | textMessage = Just textMessage }, Cmd.none )

        SetTextTemplate textTemplate ->
            ( { model | textTemplate = Just textTemplate }, Cmd.none )

        CreateTextMessage ->
            ( model, Cmd.none )

        SendText ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text (printTo model)
        , input [ onInput SetTo ] []
        ]


printTo : Model -> String
printTo model =
    case model.to of
        Just a ->
            "Your phone-number is: " ++ a

        Nothing ->
            "No phone-number!"
