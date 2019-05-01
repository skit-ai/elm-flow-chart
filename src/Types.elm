module Types exposing (FCNode, NodeId, Position)

import Html


{-| Position of canvas or node

        pos = Position 10 10

-}
type alias Position =
    { x : Float
    , y : Float
    }


type alias NodeId =
    String


type alias FCNode msg =
    { id : NodeId
    , position : Position
    , html : Html.Html msg
    }
