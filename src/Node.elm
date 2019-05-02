module Node exposing (createNode, viewNode)

import Html exposing (Html, div, button, text)
import Html.Attributes as A
import Utils.Draggable as Draggable
import FlowChart.Types exposing (FCNode, Position)


createNode : String -> Position -> String -> FCNode
createNode id startPos nodeType =
    { position = startPos, id = id, nodeType = nodeType }


viewNode : FCNode -> (Draggable.Msg String -> msg) -> Html msg -> Html msg
viewNode fcNode dragListener children =
    div
        [ A.style "position" "absolute"
        , A.style "left" (String.fromFloat fcNode.position.x ++ "px")
        , A.style "top" (String.fromFloat fcNode.position.y ++ "px")
        , Draggable.enableDragging fcNode.id dragListener
        ]
        [ children ]
