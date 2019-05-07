module Internal exposing (DraggableTypes(..), getArrowHead, toPx)

import FlowChart.Types exposing (..)
import Svg exposing (Svg)
import Svg.Attributes as SA

type DraggableTypes
    = DCanvas
    | DNode FCNode
    | DPort String String String
    | None


getArrowHead : List (Svg msg)
getArrowHead =
    [ Svg.defs []
        [ Svg.marker
            [ SA.id "arrow"
            , SA.orient "auto"
            , SA.refX "4"
            , SA.refY "4"
            , SA.markerWidth "8"
            , SA.markerHeight "8"
            ]
            [ Svg.path [ SA.d "M0,0 V8 L5,4 Z", SA.fill "cornflowerblue" ] []
            ]
        ]
    ]


toPx : Float -> String
toPx a =
    String.fromFloat a ++ "px"