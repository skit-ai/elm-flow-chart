module Node exposing (Model, initModel, viewNode)

import FlowChart.Types exposing (FCNode, FCPort, Vector2)
import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Internal exposing (DraggableTypes(..), toPx)
import Utils.Draggable as Draggable


type alias Model msg =
    { fcNode : FCNode, html : Maybe (Html msg) }


initModel : FCNode -> Model msg
initModel fcNode =
    { fcNode = fcNode, html = Nothing }


viewNode :
    Model msg
    -> (Draggable.Msg DraggableTypes -> msg)
    -> { portSize : Vector2, portColor : String }
    -> (String -> Html msg)
    -> Html msg
viewNode node dragListener portConfig nodeMap =
    let
        fcNode =
            node.fcNode

        children =
            nodeMap node.fcNode.nodeType
    in
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
            ++ List.map (\p -> viewPort fcNode.id p dragListener portConfig) fcNode.ports
        )


viewPort :
    String
    -> FCPort
    -> (Draggable.Msg DraggableTypes -> msg)
    -> { portSize : Vector2, portColor : String }
    -> Html msg
viewPort nodeId fcPort dragListener portConfig =
    div
        [ A.id fcPort.id
        , A.class "fcport"
        , A.style "background-color" portConfig.portColor
        , A.style "width" (toPx portConfig.portSize.x)
        , A.style "height" (toPx portConfig.portSize.y)
        , A.style "position" "absolute"
        , A.style "cursor" "pointer"
        , A.style "top" (String.fromFloat (fcPort.position.y * 100) ++ "%")
        , A.style "left" (String.fromFloat (fcPort.position.x * 100) ++ "%")
        , Draggable.enableDragging (DPort nodeId fcPort.id "") dragListener
        ]
        []
