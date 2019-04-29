module Utils.Draggable exposing (DragState, Event, Msg, enableDragging, init, subscriptions, update)

import Browser.Events
import Html
import Html.Events
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (Position)
import Utils.CmdExtra as CmdExtra


type DragState
    = NotDragging
    | TentativeDrag Position
    | Dragging Position


type Msg
    = DragStart Position
    | DragBy Position
    | DragEnd Position


type alias Event msg =
    { onDragStart : Maybe msg
    , onDragBy : Position -> Maybe msg
    , onDragEnd : Maybe msg
    }


init : DragState
init =
    NotDragging


subscriptions : (Msg -> msg) -> DragState -> Sub msg
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


enableDragging : (Msg -> msg) -> Html.Attribute msg
enableDragging target =
    Html.Events.custom "mousedown"
        (Decode.map (alwaysPreventDefaultAndStopPropagation << target) baseDecoder)


update :
    Event msg
    -> Msg
    -> { m | dragState : DragState }
    -> ( { m | dragState : DragState }, Cmd msg )
update event msg model =
    let
        ( newDrag, newMsgMaybe ) =
            updateInternal event msg model.dragState
    in
    ( { model | dragState = newDrag }, CmdExtra.optionalMessage newMsgMaybe )



-- HELPER FUNCS


alwaysPreventDefaultAndStopPropagation : msg -> { message : msg, stopPropagation : Bool, preventDefault : Bool }
alwaysPreventDefaultAndStopPropagation msg =
    { message = msg, stopPropagation = True, preventDefault = True }


updateInternal : Event msg -> Msg -> DragState -> ( DragState, Maybe msg )
updateInternal event msg dragState =
    case msg of
        DragStart pos ->
            ( TentativeDrag pos, event.onDragStart )

        DragEnd pos ->
            ( NotDragging, event.onDragEnd )

        DragBy newPos ->
            case dragState of
                NotDragging ->
                    ( dragState, Nothing )

                TentativeDrag oldPos ->
                    ( Dragging newPos, event.onDragBy (calcDelta newPos oldPos) )

                Dragging oldPos ->
                    ( Dragging newPos, event.onDragBy (calcDelta newPos oldPos) )


positionDecoder : Decoder Position
positionDecoder =
    Decode.map2 Position
        (field "pageX" Decode.float)
        (field "pageY" Decode.float)


baseDecoder : Decoder Msg
baseDecoder =
    Decode.map DragStart positionDecoder


calcDelta : Position -> Position -> Position
calcDelta end start =
    { x = end.x - start.x
    , y = end.y - start.y
    }
