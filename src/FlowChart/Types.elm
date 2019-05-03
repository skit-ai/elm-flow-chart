module FlowChart.Types exposing (FCCanvas, FCLink, FCNode, FCPort, Position)

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
    , nodeType : String
    , ports : List FCPort
    }


type alias FCPort =
    { id : String
    , position : Position
    }


type alias FCLink =
    { id : String
    , from : Position
    , to : Position
    }


type alias FCCanvas =
    { nodes : List FCNode
    , position : Position
    }
