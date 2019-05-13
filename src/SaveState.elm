module SaveState exposing (selectFile, toFile, toObject)

import File exposing (File)
import File.Download
import File.Select
import FlowChart.Json as FJ
import FlowChart.Types exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode


toFile : String -> Vector2 -> List FCNode -> List FCLink -> Cmd msg
toFile filePath position fcNodes fcLinks =
    let
        flowChartValue =
            Encode.object
                [ ( "position", FJ.encodeVector2 position )
                , ( "fcNodes", Encode.list FJ.encodeFCNode fcNodes )
                , ( "fcLinks", Encode.list FJ.encodeFCLink fcLinks )
                ]
    in
    File.Download.string filePath "application/json" (Encode.encode 2 flowChartValue)


selectFile : (File -> msg) -> Cmd msg
selectFile msg =
    File.Select.file [ "application/json" ] msg


type alias FCState =
    { position : Vector2
    , nodes : List FCNode
    , links : List FCLink
    }


toObject : String -> Maybe FCState
toObject jsonString =
    let
        flowChartDecoder =
            Decode.map3 FCState
                (Decode.field "position" FJ.vector2Decoder)
                (Decode.field "fcNodes" (Decode.list FJ.fcNodeDecoder))
                (Decode.field "fcLinks" (Decode.list FJ.fcLinkDecoder))
    in
    Result.toMaybe (Decode.decodeString flowChartDecoder jsonString)
