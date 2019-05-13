module SaveState exposing (toFile, toObject, selectFile)

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


toObject : Bool
toObject =
    True
