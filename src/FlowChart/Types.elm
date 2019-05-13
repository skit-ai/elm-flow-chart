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


{-| Nodes are connected through links via Ports. Use a value between [0, 1] for port position

        port = FCPort "port-1" Vector2 0 0.42

-}
type alias FCPort =
    { id : String
    , position : Vector2
    }


{-| Represent the data of a single node in flowchart

    id = unique identifier for node
    position = position of node wrt to position of canvas
    dim = width and height of node
    nodeType = string identifier used to render html from node map
    port = List of ports

        node = FCNode "node-1" (Vector2 20 20) (Vector2 100 100) "default" [
            FCPort "port-1" Vector2 0 0.42
            ,FCPort "port-2" Vector2 0.85 0.42
        ]

-}
type alias FCNode =
    { id : String
    , position : Vector2
    , dim : Vector2
    , nodeType : String
    , ports : List FCPort
    }


{-| Link data to connect nodes through ports

    id = Id of the link, should be unique
    from = NodeId, portId of the start of link
    to = NodeId, portId of the end of link

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
    , portConfig : { portSize : Vector2, portColor : String }
    , linkConfig : { linkSize : Int, linkColor : String }
    }
