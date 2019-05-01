module Node exposing (createNode, viewNode, createDefaultNode)

import Html exposing (Html, div, button, text)
import Html.Attributes as A
import Utils.Draggable as Draggable
import Types exposing (FCNode, Position)


createNode : String -> Position -> Html msg -> FCNode msg
createNode id startPos html =
    { position = startPos, id = id, html = html }


createDefaultNode : String -> Position -> FCNode msg
createDefaultNode id startPos =
    createNode id startPos (
        div [
                A.style "width" "40px"
                , A.style "height" "25px"
                , A.style "background-color" "white"
                , A.style "padding" "35px 45px"
            ]
        [ text id])


viewNode : FCNode msg -> (Draggable.Msg String -> msg) -> Html msg
viewNode fcNode dragListener =
    div
        [ A.style "position" "absolute"
        , A.style "left" (String.fromFloat fcNode.position.x ++ "px")
        , A.style "top" (String.fromFloat fcNode.position.y ++ "px")
        , Draggable.enableDragging fcNode.id dragListener
        ]
        [ fcNode.html ]
