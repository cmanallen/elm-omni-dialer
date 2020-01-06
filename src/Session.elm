module Session exposing (Model, Msg, init, update, view)

import Endpoint
import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Model =
    { session : Maybe Token
    , problems : List String
    , form : Form
    }


type alias Form =
    { username : String
    , password : String
    }


init : Maybe Token -> ( Model, Cmd Msg )
init token =
    ( { session = token
      , problems = []
      , form =
            { username = ""
            , password = ""
            }
      }
    , Cmd.none
    )


type Msg
    = EnteredUsername String
    | EnteredPassword String
    | RequestedTokenAccess
    | RequestedTokenRefresh
    | RequestedTokenRevoke
    | Authorized (Result Http.Error Token)
    | Refreshed (Result Http.Error Token)
    | Revoked (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredPassword password ->
            updateForm (\form -> { form | password = password }) model

        RequestedTokenAccess ->
            ( model, authorize model.form )

        RequestedTokenRefresh ->
            ( model, refresh model )

        RequestedTokenRevoke ->
            ( model, revoke model )

        Authorized result ->
            case result of
                Ok token ->
                    ( model, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        Refreshed result ->
            case result of
                Ok token ->
                    ( model, Cmd.none )

                Err err ->
                    ( model, Cmd.none )

        Revoked result ->
            case result of
                Ok _ ->
                    ( model, Cmd.none )

                Err err ->
                    ( model, Cmd.none )


updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm fn model =
    ( { model | form = fn model.form }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ span [] [ text "Username: " ]
        , input [ onInput EnteredUsername ] []
        , br [] []
        , span [] [ text "Password: " ]
        , input [ onInput EnteredUsername ] []
        , br [] []
        , button [ onClick RequestedTokenAccess ] [ text "Login" ]
        ]



-- HTTP


authorize : Form -> Cmd Msg
authorize form =
    let
        body =
            Encode.object
                [ ( "grant_type", Encode.string "password" )
                , ( "username", Encode.string form.username )
                , ( "password", Encode.string form.password )
                ]
                |> Http.jsonBody
    in
    Http.post
        { url = Endpoint.tokens
        , body = body
        , expect = Http.expectJson Authorized tokenDecoder
        }


refresh : Model -> Cmd Msg
refresh model =
    let
        body =
            Encode.object
                [ ( "grant_type", Encode.string "refresh_token" )
                , ( "refresh_token", Encode.string ( getRefreshToken model.session ) )
                ]
                |> Http.jsonBody
    in
    Http.post
        { url = Endpoint.tokens
        , body = body
        , expect = Http.expectJson Refreshed tokenDecoder
        }


getRefreshToken : Maybe Token -> String
getRefreshToken token =
    case token of
        Just tok ->
            tok.refreshToken
        Nothing ->
            ""


revoke : Model -> Cmd Msg
revoke model =
    Http.get
        { url = Endpoint.revoke
        , expect = Http.expectString Revoked
        }



-- Decoders


type alias Token =
    { tokenType : String
    , accessToken : String
    , refreshToken : String
    , expiresIn : Int
    }


tokenDecoder : Decode.Decoder Token
tokenDecoder =
    Decode.map4
        Token
        (Decode.field "token_type" Decode.string)
        (Decode.field "access_token" Decode.string)
        (Decode.field "refresh_token" Decode.string)
        (Decode.field "expires_in" Decode.int)
