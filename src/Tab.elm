module Tab exposing (view)

import Browser
import Html exposing (Html)


view : (a -> msg) -> Html a -> Html msg
view toMsg details = Html.map toMsg <| details
