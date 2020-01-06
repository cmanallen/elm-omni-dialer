module Main exposing (Model, Msg, init, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)

import Session
import Tab
import Text



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { tab : Tab }


type Tab
    = Call
    | Text Text.Model
    | Email



-- INIT


init : () -> ( Model, Cmd Msg )
init _ =
    ( { tab = Call }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- UPDATE


type Msg
    = CallTabClicked
    | TextTabClicked
    | EmailTabClicked
    | TextMsg Text.Msg
    | SessionMsg Session.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CallTabClicked ->
            ( { model | tab = Call }, Cmd.none )

        TextTabClicked ->
            stepText model ( Text.init )

        EmailTabClicked ->
            ( { model | tab = Email }, Cmd.none )

        TextMsg textMsg ->
            case model.tab of
                Text textModel ->
                    stepText model ( Text.update textMsg textModel )

                _ ->
                    ( model, Cmd.none )


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ renderTabs model
        , renderTabContent model
        ]


renderTabs : Model -> Html Msg
renderTabs model =
    ul []
        [ li [ onClick CallTabClicked ] [ text "Call" ]
        , li [ onClick TextTabClicked ] [ text "Text" ]
        , li [ onClick EmailTabClicked ] [ text "Email" ]
        ]


renderTabContent : Model -> Html Msg
renderTabContent model =
    case model.tab of
        Call ->
            div [] [ text "Call" ]

        Text textModel ->
            Tab.view TextMsg ( Text.view textModel )

        Email ->
            div [] [ text "Email" ]


-- NAVIGATION


stepText : Model -> ( Text.Model, Cmd Text.Msg ) -> ( Model, Cmd Msg )
stepText model (textModel, textMsg) =
    ( { model | tab = Text textModel }
    , Cmd.map TextMsg textMsg
    )
