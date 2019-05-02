module FCCanvas exposing (Model, Msg, addNode, init, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes as A
import Node
import Types exposing (FCNode, Position)
import Utils.CmdExtra as CmdExtra
import Utils.Draggable as Draggable



-- MODEL


type alias Model =
    { nodes : List FCNode
    , viewPosition : Position
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


init : (String -> Html Msg) -> Model
init nodeMap =
    { nodes = []
    , viewPosition = Position 0 0
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
                    ( { mod | viewPosition = updatePosition mod.viewPosition deltaPos }, Cmd.none )

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
                    ( { mod | nodes = List.map updateNode mod.nodes }, Cmd.none )

        OnDragEnd ->
            ( { mod | currentlyDragging = Nothing }, Cmd.none )

        AddNode newNode ->
            ( { mod | nodes = mod.nodes ++ [ newNode ] }, Cmd.none )

        RemoveNode node ->
            ( { mod | nodes = List.filter (\n -> n.id /= node.id) mod.nodes }, Cmd.none )


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
            , A.style "left" (String.fromFloat mod.viewPosition.x ++ "px")
            , A.style "top" (String.fromFloat mod.viewPosition.y ++ "px")
            ]
            (List.map
                (\node ->
                    Node.viewNode node DragMsg (mod.nodeMap node.nodeType)
                )
                mod.nodes
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
