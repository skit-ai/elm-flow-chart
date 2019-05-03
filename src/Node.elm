module Node exposing (viewNode)

import DraggableTypes exposing (DraggableTypes(..))
import FlowChart.Types exposing (FCNode, FCPort, Position)
import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Utils.Draggable as Draggable


viewNode : FCNode -> (Draggable.Msg DraggableTypes -> msg) -> Html msg -> Html msg
viewNode fcNode dragListener children =
    div
        [ A.style "position" "absolute"
        , A.style "left" (String.fromFloat fcNode.position.x ++ "px")
        , A.style "top" (String.fromFloat fcNode.position.y ++ "px")
        , Draggable.enableDragging (DNode fcNode) dragListener
        ]
        ([ children ]
            ++ List.map (\p-> viewPort fcNode.id p dragListener) fcNode.ports
        )


viewPort : String -> FCPort -> (Draggable.Msg DraggableTypes -> msg) -> Html msg
viewPort nodeId fcPort dragListener =
    div
        [ A.style "background" "grey"
        , A.style "width" "20px"
        , A.style "height" "20px"
        , A.style "position" "absolute"
        , A.style "cursor" "pointer"
        , A.style "top" (String.fromFloat (fcPort.position.y * 100) ++ "%")
        , A.style "left" (String.fromFloat (fcPort.position.x * 100) ++ "%")
        , Draggable.enableDragging (DPort nodeId fcPort Nothing) dragListener
        ]
        []
