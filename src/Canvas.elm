module Canvas exposing (Model, Msg(..), dragEvent, init, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Attributes as A
import Node
import Types exposing (FCNode, NodeId, Position)
import Utils.Draggable as Draggable


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { nodes : List (FCNode Msg)
    , viewPosition : Position
    , numberNodes : Int
    , currentlyDragging : Maybe NodeId
    , dragState : Draggable.DragState NodeId
    }


type Msg
    = DragMsg (Draggable.Msg NodeId)
    | OnDragBy Position
    | OnDragStart NodeId
    | OnDragEnd


init : () -> ( Model, Cmd Msg )
init _ =
    ( { nodes =
            [ Node.createDefaultNode "0" (Position 10 10)
            , Node.createDefaultNode "1" (Position 500 100)
            ]
      , viewPosition = Position 0 0
      , numberNodes = 2
      , currentlyDragging = Nothing
      , dragState = Draggable.init
      }
    , Cmd.none
    )



-- SUB


dragEvent : Draggable.Event Msg NodeId
dragEvent =
    { onDragStartListener = Just << OnDragStart
    , onDragByListener = Just << OnDragBy
    , onDragEndListener = Just OnDragEnd
    }


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


view : Model -> Html Msg
view mod =
    div
        [ A.id "fc-canvas"
        , A.style "width" "97%"
        , A.style "height" "580px"
        , A.style "overflow" "hidden"
        , A.style "position" "fixed"
        , A.style "cursor" "move"
        , A.style "background-color" "lightgray"
        , Draggable.enableDragging "canvas" DragMsg
        ]
        [ div
            [ A.style "width" "0px"
            , A.style "height" "0px"
            , A.style "position" "absolute"
            , A.style "left" (String.fromFloat mod.viewPosition.x ++ "px")
            , A.style "top" (String.fromFloat mod.viewPosition.y ++ "px")
            ]
            (List.map (\node -> Node.viewNode node DragMsg) mod.nodes)
        ]



-- HELPER FUNCTIONS


updatePosition : Position -> Position -> Position
updatePosition oldPos deltaPos =
    { x = oldPos.x + deltaPos.x, y = oldPos.y + deltaPos.y }
