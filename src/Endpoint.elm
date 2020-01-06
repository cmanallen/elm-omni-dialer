module Endpoint exposing (..)


root : String
root = "https://localhost:5000/api/v1"


tokens : String
tokens = root ++ "/oauth2/tokens"


revoke : String
revoke = root ++ "/oauth2/revoke"