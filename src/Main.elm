module Main exposing (Model, Msg(..), dragEvent, init, main, subscriptions, update, view)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Types exposing (Position)
import Utils.Draggable as Draggable


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { position : Position, dragState : Draggable.DragState }


type Msg
    = DragMsg Draggable.Msg
    | OnDragBy Position


init : () -> ( Model, Cmd Msg )
init _ =
    ( { position = Position 20 20, dragState = Draggable.init }
    , Cmd.none
    )



-- SUB


dragEvent : Draggable.Event Msg
dragEvent =
    { onDragStart = Nothing
    , onDragBy = Just << OnDragBy
    , onDragEnd = Nothing
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

        OnDragBy pos ->
            let
                newPos =
                    { x = mod.position.x + pos.x, y = mod.position.y + pos.y }
            in
            ( { mod | position = newPos }, Cmd.none )


view : Model -> Html Msg
view mod =
    let
        translate =
            "translate(" ++ String.fromFloat mod.position.x ++ "px, " ++ String.fromFloat mod.position.y ++ "px)"
    in
    div
        [ A.style "transform" translate
        , A.style "padding" "16px"
        , A.style "background-color" "lightgray"
        , A.style "width" "64px"
        , A.style "cursor" "move"
        , Draggable.enableDragging DragMsg
        ]
        [ Html.text "Drag me" ]