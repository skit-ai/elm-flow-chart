module Types exposing (Position, FCNode, FCChart)

{-| Position of canvas or node

        pos = Position 10 10
-}
type alias Position =
    {
        x : Float
        , y: Float
    }

type alias FCNode = 
    {
        id : String
        , position: Position
    }

type alias FCChart = 
    {
        id : String
        , position: Position
        , nodes: List FCNode
    }