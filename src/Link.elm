module Link exposing (Model, viewLink)

import Dict exposing (Dict)
import FlowChart.Types exposing (FCLink, FCNode, FCPort, Vector2)
import Html exposing (Html)
import Json.Decode as Decode
import Svg exposing (Svg, svg)
import Svg.Attributes as SA
import Svg.Events as SvgEvents
import Utils.MathUtils as MathUtils


type alias Model =
    { fcLink : FCLink, tempPosition : Maybe Vector2 }


viewLink :
    Dict String FCNode
    -> (FCLink -> String -> msg)
    -> Model
    -> { linkSize : Int, linkColor : String }
    -> Svg msg
viewLink nodes targetMsg link linkConfig =
    case calcPositions link nodes of
        Nothing ->
            Svg.line [] []

        Just ( startPos, endPos ) ->
            let
                pathString =
                    generatePath startPos endPos
            in
            Svg.g [ SA.fill "none", SA.stroke linkConfig.linkColor ]
                [ Svg.path
                    [ SA.d pathString
                    , SA.strokeWidth (String.fromInt linkConfig.linkSize)
                    , SA.markerEnd "url(#arrow)"
                    ]
                    []
                , Svg.path
                    [ SA.d pathString
                    , SA.strokeWidth "20"
                    , SA.opacity "0"
                    , SvgEvents.onClick (targetMsg link.fcLink "click")
                    , SvgEvents.custom "mousedown"
                        (Decode.map preventPropagation
                            (Decode.succeed (targetMsg link.fcLink "mousedown"))
                        )
                    ]
                    []
                ]



-- HELPER FUNCTIONS


calcPositions : Model -> Dict String FCNode -> Maybe ( Vector2, Vector2 )
calcPositions link nodes =
    let
        fcLink =
            link.fcLink

        finalPositions : Vector2 -> Vector2 -> ( Vector2, Vector2 )
        finalPositions fromPos toPos =
            if fcLink.from.portId == fcLink.to.portId then
                ( fromPos
                , updatePosition fromPos (Maybe.withDefault (Vector2 0 0) link.tempPosition)
                )

            else
                ( fromPos, toPos )
    in
    Maybe.map2 finalPositions
        (getPortPosition fcLink.from.portId (Dict.get fcLink.from.nodeId nodes))
        (getPortPosition fcLink.to.portId (Dict.get fcLink.to.nodeId nodes))


getPortPosition : String -> Maybe FCNode -> Maybe Vector2
getPortPosition portId node =
    let
        addRelativePosition pos1 pos2 dim =
            { x = pos1.x + pos2.x * dim.x, y = pos1.y + pos2.y * dim.y + 10 }

        toPos : FCPort -> FCNode -> Vector2
        toPos fcPort fcNode =
            addRelativePosition fcNode.position fcPort.position fcNode.dim

        getPort : FCNode -> Maybe FCPort
        getPort fcNode =
            List.head (List.filter (.id >> (==) portId) fcNode.ports)
    in
    Maybe.map2 toPos (Maybe.andThen getPort node) node


updatePosition : Vector2 -> Vector2 -> Vector2
updatePosition oldPos deltaPos =
    { x = oldPos.x + deltaPos.x, y = oldPos.y + deltaPos.y }


generatePath : Vector2 -> Vector2 -> String
generatePath startPos endPos =
    let
        positionToString pos =
            String.fromFloat pos.x ++ "," ++ String.fromFloat pos.y

        offsetX =
            min (max 100 (abs (startPos.x - endPos.x) * 1.5)) 350

        offset =
            Vector2 offsetX 0
    in
    "M"
        ++ positionToString startPos
        ++ " C "
        ++ positionToString (MathUtils.addVector2 startPos offset)
        ++ " "
        ++ positionToString (MathUtils.subVector2 endPos offset)
        ++ " "
        ++ positionToString endPos


preventPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
preventPropagation msg =
    { message = msg, stopPropagation = True, preventDefault = True }
