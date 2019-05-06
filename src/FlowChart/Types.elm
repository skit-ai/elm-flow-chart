module FlowChart.Types exposing (Vector2, FCNode, FCPort, FCLink, FCCanvas)

{-|


# Defination

@docs Vector2, FCNode, FCPort, FCLink, FCCanvas

-}


{-| Vector2 which can represent position or dimension of node, canvas, etc.

        pos = Vector2 10 10

-}
type alias Vector2 =
    { x : Float
    , y : Float
    }


{-| Represent the data of a single node in flowchart
-}
type alias FCNode =
    { id : String
    , position : Vector2
    , dim : Vector2
    , nodeType : String
    , ports : List FCPort
    }


{-| Nodes are connected through links at Port position
-}
type alias FCPort =
    { id : String
    , position : Vector2
    }


{-| Link data to connect nodes through ports

id -> Id of the link, should be unique
from -> NodeId, portId of the start of link
to -> NodeId, portId of the end of link

-}
type alias FCLink =
    { id : String
    , from : { nodeId : String, portId : String }
    , to : { nodeId : String, portId : String }
    }


{-| Canvas data to initialize the flowchart
-}
type alias FCCanvas =
    { nodes : List FCNode
    , position : Vector2
    , links : List FCLink
    }
