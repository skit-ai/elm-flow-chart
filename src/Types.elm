module Types exposing (Position,FCNode)

import Html

{-| Position of canvas or node

        pos = Position 10 10

-}
type alias Position =
    { x : Float
    , y : Float
    }


type alias FCNode msg =
    { id : String
    , position : Position
    , html : Html.Html msg
    }
