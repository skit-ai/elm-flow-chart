module Link exposing (viewLink)

import FlowChart.Types exposing (FCLink, Vector2)
import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes as SA


viewLink : FCLink -> Svg msg
viewLink fcLink =
    let
        points =
            positionToString fcLink.from ++ " " ++ positionToString fcLink.to
    in
    Svg.polyline
        [ SA.points points
        , SA.stroke "cornflowerblue"
        , SA.strokeWidth "3"
        ]
        []



-- HELPER FUNCTIONS


positionToString : Vector2 -> String
positionToString pos =
    String.fromFloat pos.x ++ "," ++ String.fromFloat pos.y
