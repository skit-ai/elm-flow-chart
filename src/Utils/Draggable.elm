module Utils.Draggable exposing (DragState, Event, Msg, enableDragging, init, subscriptions, update, move)

import Browser.Events
import Html
import Html.Events
import Json.Decode as Decode
import Types exposing (Position)
import Utils.CmdExtra as CmdExtra


type DragState id
    = NotDragging
    | TentativeDrag Position
    | Dragging Position


type Msg id
    = DragStart id Position
    | DragBy Position
    | DragEnd Position


type alias Event msg id =
    { onDragStartListener : id -> Maybe msg
    , onDragByListener : Position -> Maybe msg
    , onDragEndListener : Maybe msg
    }


init : DragState id
init =
    NotDragging


subscriptions : (Msg id -> msg) -> DragState id -> Sub msg
subscriptions envelope dragState =
    case dragState of
        NotDragging ->
            Sub.none

        _ ->
            [ Browser.Events.onMouseMove (Decode.map DragBy positionDecoder)
            , Browser.Events.onMouseUp (Decode.map DragEnd positionDecoder)
            ]
                |> Sub.batch
                |> Sub.map envelope


enableDragging : id -> (Msg id -> msg) -> Html.Attribute msg
enableDragging key target =
    Html.Events.custom "mousedown"
        (Decode.map (alwaysPreventDefaultAndStopPropagation << target) (baseDecoder key))


update :
    Event msg id
    -> Msg id
    -> { m | dragState : DragState id }
    -> ( { m | dragState : DragState id }, Cmd msg )
update event msg model =
    let
        ( newDrag, newMsgMaybe ) =
            updateInternal event msg model.dragState
    in
    ( { model | dragState = newDrag }, CmdExtra.optionalMessage newMsgMaybe )


move : Position -> String
move pos =
    "translate(" ++ String.fromFloat pos.x ++ "px, " ++ String.fromFloat pos.y ++ "px)"


-- HELPER FUNCS


alwaysPreventDefaultAndStopPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
alwaysPreventDefaultAndStopPropagation msg =
    { message = msg, stopPropagation = True, preventDefault = True }


updateInternal : Event msg id -> Msg id -> DragState id -> ( DragState id, Maybe msg )
updateInternal event msg dragState =
    case msg of
        DragStart id pos ->
            ( TentativeDrag pos, event.onDragStartListener id )

        DragEnd pos ->
            ( NotDragging, event.onDragEndListener )

        DragBy newPos ->
            case dragState of
                NotDragging ->
                    ( dragState, Nothing )

                TentativeDrag oldPos ->
                    ( Dragging newPos, event.onDragByListener (calcDelta newPos oldPos) )

                Dragging oldPos ->
                    ( Dragging newPos, event.onDragByListener (calcDelta newPos oldPos) )


positionDecoder : Decode.Decoder Position
positionDecoder =
    Decode.map2 Position
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


baseDecoder : id -> Decode.Decoder (Msg id)
baseDecoder key =
    Decode.map (DragStart key) positionDecoder


calcDelta : Position -> Position -> Position
calcDelta end start =
    { x = end.x - start.x
    , y = end.y - start.y
    }
