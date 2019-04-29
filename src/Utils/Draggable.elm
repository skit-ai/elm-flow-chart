module Utils.Draggable exposing (DragState, Event, Msg, enableDragging, init, subscriptions, update)

import Browser.Events
import Html
import Html.Events
import Json.Decode as Decode exposing (Decoder, field)
import Types exposing (Position)
import Utils.CmdExtra as CmdExtra


type DragState
    = NotDragging
    | TentativeDrag
    | Dragging


type Msg
    = DragStart
    | DragAt Position
    | DragEnd Position


type alias Event msg =
    { onDragStart : Maybe msg
    , onDragAt : Position -> Maybe msg
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
            [ Browser.Events.onMouseMove (Decode.map DragAt positionDecoder)
            , Browser.Events.onMouseUp (Decode.map DragEnd positionDecoder)
            ]
                |> Sub.batch
                |> Sub.map envelope


enableDragging : (Msg -> msg) -> Html.Attribute msg
enableDragging target =
    Html.Events.custom "mousedown" <|
        Decode.succeed (alwaysPreventDefaultAndStopPropagation (target DragStart))


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
        DragStart ->
            ( TentativeDrag, event.onDragStart )

        DragEnd pos ->
            ( NotDragging, event.onDragEnd )

        DragAt pos ->
            if dragState == TentativeDrag || dragState == Dragging then
                ( Dragging, event.onDragAt pos )

            else
                ( dragState, Nothing )


positionDecoder : Decoder Position
positionDecoder =
    Decode.map2 Position
        (field "pageX" Decode.float)
        (field "pageY" Decode.float)
