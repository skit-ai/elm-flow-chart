module FlowChart exposing (Model, Msg, addNode, init, subscriptions, update, view)

import Browser
import FlowChart.Types exposing (FCCanvas, FCNode, Position)
import Html exposing (..)
import Html.Attributes as A
import Node
import Utils.CmdExtra as CmdExtra
import Utils.Draggable as Draggable



-- MODEL


type alias Model =
    { canvas : FCCanvas
    , currentlyDragging : Maybe String
    , dragState : Draggable.DragState
    , nodeMap : String -> Html Msg
    }


type Msg
    = DragMsg (Draggable.Msg String)
    | OnDragBy Position
    | OnDragStart String
    | OnDragEnd
    | AddNode FCNode
    | RemoveNode FCNode


init : FCCanvas -> (String -> Html Msg) -> Model
init canvas nodeMap =
    { canvas = canvas
    , currentlyDragging = Nothing
    , dragState = Draggable.init
    , nodeMap = nodeMap
    }


addNode : FCNode -> Cmd Msg
addNode newNode =
    CmdExtra.message (AddNode newNode)



-- SUB


subscriptions : Model -> Sub Msg
subscriptions model =
    Draggable.subscriptions DragMsg model.dragState



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg mod =
    case msg of
        DragMsg dragMsg ->
            Draggable.update dragEvent dragMsg mod

        OnDragStart id ->
            ( { mod | currentlyDragging = Just id }, Cmd.none )

        OnDragBy deltaPos ->
            case mod.currentlyDragging of
                Just "canvas" ->
                    let
                        canvas =
                            mod.canvas
                    in
                    ( { mod
                        | canvas =
                            { canvas
                                | position = updatePosition canvas.position deltaPos
                            }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( mod, Cmd.none )

                _ ->
                    let
                        updateNode node =
                            if Just node.id == mod.currentlyDragging then
                                { node | position = updatePosition node.position deltaPos }

                            else
                                node
                    in
                    ( { mod | canvas = updateCanvasNodes mod.canvas (List.map updateNode mod.canvas.nodes) }, Cmd.none )

        OnDragEnd ->
            ( { mod | currentlyDragging = Nothing }, Cmd.none )

        AddNode newNode ->
            ( { mod | canvas = updateCanvasNodes mod.canvas (mod.canvas.nodes ++ [ newNode ]) }, Cmd.none )

        RemoveNode node ->
            ( { mod
                | canvas =
                    updateCanvasNodes mod.canvas
                        (List.filter (.id >> (/=) node.id) mod.canvas.nodes)
              }
            , Cmd.none
            )


view : Model -> List (Html.Attribute Msg) -> Html Msg
view mod canvasStyle =
    div
        ([ A.style "width" "700px"
         , A.style "height" "580px"
         , A.style "overflow" "hidden"
         , A.style "position" "fixed"
         , A.style "cursor" "move"
         , A.style "background-color" "lightgrey"
         , Draggable.enableDragging "canvas" DragMsg
         ]
            ++ canvasStyle
        )
        [ div
            [ A.style "width" "0px"
            , A.style "height" "0px"
            , A.style "position" "absolute"
            , A.style "left" (String.fromFloat mod.canvas.position.x ++ "px")
            , A.style "top" (String.fromFloat mod.canvas.position.y ++ "px")
            ]
            (List.map
                (\node ->
                    Node.viewNode node DragMsg (mod.nodeMap node.nodeType)
                )
                mod.canvas.nodes
            )
        ]



-- HELPER FUNCTIONS


dragEvent : Draggable.Event Msg String
dragEvent =
    { onDragStartListener = Just << OnDragStart
    , onDragByListener = Just << OnDragBy
    , onDragEndListener = Just OnDragEnd
    }


updatePosition : Position -> Position -> Position
updatePosition oldPos deltaPos =
    { x = oldPos.x + deltaPos.x, y = oldPos.y + deltaPos.y }


updateCanvasNodes : FCCanvas -> List FCNode -> FCCanvas
updateCanvasNodes canvas nodes =
    { canvas | nodes = nodes }
