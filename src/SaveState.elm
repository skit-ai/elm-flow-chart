module SaveState exposing (toFile)

import File.Download as Download
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
    Download.string filePath "text/json" (Encode.encode 2 flowChartValue)
