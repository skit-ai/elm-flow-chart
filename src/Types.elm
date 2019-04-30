module Types exposing (Position,FCNode, FCCanvas)

{-| Position of canvas or node

        pos = Position 10 10

-}
type alias Position =
    { x : Float
    , y : Float
    }


type alias FCNode =
    { id : String
    , position : Position
    }


type alias FCCanvas =
    { nodes : List FCNode }
