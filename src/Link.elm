module Link exposing (viewLink)

import Dict exposing (Dict)
import FlowChart.Types exposing (FCLink, FCNode, FCPort, Position)
import Html exposing (Html, div)
import Svg exposing (Svg, svg)
import Svg.Attributes as SA


viewLink : Dict String FCNode -> FCLink -> Html msg
viewLink nodes fcLink =
    let
        positions =
            calcPositions fcLink nodes
    in
    case positions of
        Just ( startPos, endPos ) ->
            let
                points =
                    positionToString startPos ++ " " ++ positionToString endPos
            in
            svg
                [ SA.overflow "visible" ]
                [ Svg.polyline
                    [ SA.points points
                    , SA.stroke "cornflowerblue"
                    , SA.strokeWidth "3"
                    ]
                    []
                ]

        _ ->
            div [] []


calcPositions : FCLink -> Dict String FCNode -> Maybe ( Position, Position )
calcPositions fcLink nodes =
    let
        fromPortPosition =
            getPortPosition fcLink.from.portId (Dict.get fcLink.from.nodeId nodes)

        toPortPosition =
            getPortPosition fcLink.to.portId (Dict.get fcLink.to.nodeId nodes)
    in
    case ( fromPortPosition, toPortPosition ) of
        ( Just fromP, Just toP ) ->
            Just ( fromP, toP )

        _ ->
            Nothing



-- HELPER FUNCTIONS


positionToString : Position -> String
positionToString pos =
    String.fromFloat pos.x ++ "," ++ String.fromFloat pos.y


getPortPosition : String -> Maybe FCNode -> Maybe Position
getPortPosition portId node =
    case node of
        Nothing ->
            Nothing

        Just fcNode ->
            let
                fcPort =
                    List.head (List.filter (.id >> (==) portId) fcNode.ports)
            in
            case fcPort of
                Nothing ->
                    Nothing

                Just tPort ->
                    Just (addRelativePosition fcNode.position tPort.position)


addRelativePosition : Position -> Position -> Position
addRelativePosition pos1 pos2 =
    { x = pos1.x + pos2.x * 100, y = pos1.y + pos2.y * 100 }
