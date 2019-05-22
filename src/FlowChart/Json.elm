module FlowChart.Json exposing
    ( encodeVector2, encodeFCNode, encodeFCPort, encodeFCLink
    , vector2Decoder, fcNodeDecoder, fcPortDecoder, fcLinkDecoder
    )

{-| Encoders and decoders for flowchart data types


# Encoders

@docs encodeVector2, encodeFCNode, encodeFCPort, encodeFCLink


# Decoders

@docs vector2Decoder, fcNodeDecoder, fcPortDecoder, fcLinkDecoder

-}

import FlowChart.Types exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode



-- ENCODERS


{-| encoder for Vector2
-}
encodeVector2 : Vector2 -> Encode.Value
encodeVector2 vec =
    Encode.object
        [ ( "x", Encode.float vec.x )
        , ( "y", Encode.float vec.y )
        ]


{-| encoder for a FCPort
-}
encodeFCPort : FCPort -> Encode.Value
encodeFCPort fcPort =
    Encode.object
        [ ( "id", Encode.string fcPort.id )
        , ( "position", encodeVector2 fcPort.position )
        ]


{-| encoder for a FCNode
-}
encodeFCNode : FCNode -> Encode.Value
encodeFCNode fcNode =
    Encode.object
        [ ( "id", Encode.string fcNode.id )
        , ( "position", encodeVector2 fcNode.position )
        , ( "dim", encodeVector2 fcNode.dim )
        , ( "nodeType", Encode.string fcNode.nodeType )
        , ( "ports", Encode.list encodeFCPort fcNode.ports )
        ]


{-| encoder for a FCLink
-}
encodeFCLink : FCLink -> Encode.Value
encodeFCLink fcLink =
    Encode.object
        [ ( "id", Encode.string fcLink.id )
        , ( "from", encodeLinkPosition fcLink.from )
        , ( "to", encodeLinkPosition fcLink.to )
        ]



-- DECODERS


{-| vector2 decoder
-}
vector2Decoder : Decode.Decoder Vector2
vector2Decoder =
    Decode.map2 Vector2
        (Decode.field "x" Decode.float)
        (Decode.field "y" Decode.float)


{-| FCPort Decoder
-}
fcPortDecoder : Decode.Decoder FCPort
fcPortDecoder =
    Decode.map2 FCPort
        (Decode.field "id" Decode.string)
        (Decode.field "position" vector2Decoder)


{-| FCNode Decoder
-}
fcNodeDecoder : Decode.Decoder FCNode
fcNodeDecoder =
    Decode.map5 FCNode
        (Decode.field "id" Decode.string)
        (Decode.field "position" vector2Decoder)
        (Decode.field "dim" vector2Decoder)
        (Decode.field "nodeType" Decode.string)
        (Decode.field "ports" (Decode.list fcPortDecoder))


{-| FCLink Decoder
-}
fcLinkDecoder : Decode.Decoder FCLink
fcLinkDecoder =
    Decode.map3 FCLink
        (Decode.field "id" Decode.string)
        (Decode.field "from" linkPositionDecoder)
        (Decode.field "to" linkPositionDecoder)



-- HELPERS


encodeLinkPosition : { nodeId : String, portId : String } -> Encode.Value
encodeLinkPosition lPos =
    Encode.object
        [ ( "nodeId", Encode.string lPos.nodeId )
        , ( "portId", Encode.string lPos.portId )
        ]


linkPositionDecoder : Decode.Decoder { nodeId : String, portId : String }
linkPositionDecoder =
    Decode.map2 (\x -> \y -> { nodeId = x, portId = y })
        (Decode.field "nodeId" Decode.string)
        (Decode.field "portId" Decode.string)
