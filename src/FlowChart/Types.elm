module FlowChart.Types exposing (FCCanvas, FCLink, FCNode, FCPort, Vector2)

{-| Vector2 of canvas or node

        pos = Vector2 10 10
-}
type alias Vector2 =
    { x : Float
    , y : Float
    }


type alias FCNode =
    { id : String
    , position : Vector2
    , dim : Vector2
    , nodeType : String
    , ports : List FCPort
    }


type alias FCPort =
    { id : String
    , position : Vector2
    }


type alias FCLink =
    { id : String
    , from : { nodeId : String, portId : String }
    , to : { nodeId : String, portId : String }
    }


type alias FCCanvas =
    { nodes : List FCNode
    , position : Vector2
    , links : List FCLink
    }
