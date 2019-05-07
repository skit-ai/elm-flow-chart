module Node exposing (viewNode)

import Internal exposing (DraggableTypes(..), toPx)
import FlowChart.Types exposing (FCNode, FCPort, Vector2)
import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Utils.Draggable as Draggable


viewNode : FCNode -> (Draggable.Msg DraggableTypes -> msg) -> Html msg -> Html msg
viewNode fcNode dragListener children =
    div
        [ A.id fcNode.id
        , A.style "position" "absolute"
        , A.style "width" (toPx fcNode.dim.x)
        , A.style "height" (toPx fcNode.dim.y)
        , A.style "left" (toPx fcNode.position.x)
        , A.style "top" (toPx fcNode.position.y)
        , Draggable.enableDragging (DNode fcNode) dragListener
        ]
        ([ children ]
            ++ List.map (\p-> viewPort fcNode.id p dragListener) fcNode.ports
        )


viewPort : String -> FCPort -> (Draggable.Msg DraggableTypes -> msg) -> Html msg
viewPort nodeId fcPort dragListener =
    div
        [ A.id fcPort.id
        , A.style "background" "grey"
        , A.style "width" "20px"
        , A.style "height" "20px"
        , A.style "position" "absolute"
        , A.style "cursor" "pointer"
        , A.style "top" (String.fromFloat (fcPort.position.y * 100) ++ "%")
        , A.style "left" (String.fromFloat (fcPort.position.x * 100) ++ "%")
        , Draggable.enableDragging (DPort nodeId fcPort.id "") dragListener
        ]
        []
