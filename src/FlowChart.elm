module FlowChart exposing
    ( Model, Msg, FCEvent
    , init, initEventConfig, subscriptions, FCEventConfig
    , update, view
    , addNode
    )

{-| This library aims to provide a flow chart builder in Elm.


# Definition

@docs Model, Msg, FCEvent


# Subscriptions

@docs init, initEventConfig, subscriptions, FCEventConfig


# Update

@docs update, view


# Functionalities

@docs addNode

-}

import Browser
import Dict exposing (Dict)
import FlowChart.Types exposing (FCCanvas, FCLink, FCNode, FCPort, Vector2)
import Html exposing (Html, div)
import Html.Attributes as A
import Internal exposing (DraggableTypes(..), toPx)
import Link
import Node
import Random
import Svg exposing (Svg, svg)
import Svg.Attributes as SA
import Utils.CmdExtra as CmdExtra
import Utils.Draggable as Draggable
import Utils.MathUtils as MathUtils
import Utils.RandomExtra as RandomExtra



-- MODEL


{-| flowchart model
-}
type alias Model msg =
    { position : Vector2
    , nodes : Dict String FCNode
    , links : Dict String Link.Model
    , currentlyDragging : DraggableTypes
    , dragState : Draggable.DragState
    , targetMsg : Msg -> msg
    }


{-| flowchart message
-}
type Msg
    = DragMsg (Draggable.Msg DraggableTypes)
    | OnDragBy Vector2
    | OnDragStart DraggableTypes
    | OnDragEnd String String
    | OnClick
    | AddLink FCLink String
    | RemoveLink String
    | LinkClick FCLink


{-| Config for subscribing to events

        onCanvasClick -> when canvas is clicked
        onNodeClick FCNode -> when any node is clicked
        onLinkClick FCLink -> when any link is clicked

-}
type alias FCEventConfig msg =
    Internal.FCEventConfig msg


{-| Event declaration for event config
-}
type alias FCEvent msg =
    FCEventConfig msg -> FCEventConfig msg


{-| init flowchart

    init fcCanvas nodeMap

-}
init : FCCanvas -> (Msg -> msg) -> Model msg
init canvas target =
    { position = canvas.position
    , nodes = Dict.fromList (List.map (\n -> ( n.id, n )) canvas.nodes)
    , links = Dict.empty
    , currentlyDragging = None
    , dragState = Draggable.init
    , targetMsg = target
    }


initEventConfig : List (FCEvent msg) -> FCEventConfig msg
initEventConfig events =
    List.foldl (<|) Internal.defaultEventConfig events


{-| subscriptions
-}
subscriptions : Model msg -> Sub msg
subscriptions model =
    Sub.map model.targetMsg (Draggable.subscriptions DragMsg model.dragState)


{-| call to update the canvas
-}
update : FCEventConfig msg -> Msg -> Model msg -> ( Model msg, Cmd msg )
update event msg mod =
    case msg of
        DragMsg dragMsg ->
            let
                ( updatedMod, cmdMsg ) =
                    Draggable.update dragEvent dragMsg mod
            in
            ( updatedMod, Cmd.map mod.targetMsg cmdMsg )

        OnDragStart currentlyDragging ->
            let
                cCmd =
                    case currentlyDragging of
                        DPort nodeId portId linkId ->
                            let
                                p =
                                    { nodeId = nodeId, portId = portId }

                                newLink =
                                    { id = "", from = p, to = p }
                            in
                            Random.generate (AddLink newLink) (RandomExtra.randomString 6)

                        _ ->
                            Cmd.none
            in
            ( { mod | currentlyDragging = currentlyDragging }, Cmd.map mod.targetMsg cCmd )

        _ ->
            let
                ( updatedModel, maybeMsg ) =
                    updateInternal event msg mod
            in
            ( updatedModel, CmdExtra.optionalMessage maybeMsg )


{-| display the canvas
-}
view : Model msg -> (String -> Html Msg) -> List (Html.Attribute Msg) -> Html msg
view mod nodeMap canvasStyle =
    Html.map mod.targetMsg
        (div
            ([ A.style "width" "700px"
             , A.style "height" "580px"
             , A.style "overflow" "hidden"
             , A.style "position" "fixed"
             , A.style "cursor" "move"
             , A.style "background-color" "lightgrey"
             , Draggable.enableDragging DCanvas DragMsg
             ]
                ++ canvasStyle
            )
            [ div
                [ A.style "width" "0px"
                , A.style "height" "0px"
                , A.style "position" "absolute"
                , A.style "left" (toPx mod.position.x)
                , A.style "top" (toPx mod.position.y)
                ]
                (List.map
                    (\node ->
                        Node.viewNode node DragMsg (nodeMap node.nodeType)
                    )
                    (Dict.values mod.nodes)
                    ++ [ svg
                            [ SA.overflow "visible" ]
                            (Internal.getArrowHead
                                ++ List.map (\l -> Link.viewLink mod.nodes (LinkClick l.fcLink) l)
                                    (Dict.values mod.links)
                            )
                       ]
                )
            ]
        )


{-| call to add node to canvas
-}
addNode : FCNode -> Model msg -> Model msg
addNode newNode model =
    { model | nodes = Dict.insert newNode.id newNode model.nodes }


removeNode : String -> Model msg -> Model msg
removeNode nodeId model =
    { model | nodes = Dict.remove nodeId model.nodes }



-- HELPER FUNCTIONS


dragEvent : Draggable.Event Msg DraggableTypes
dragEvent =
    { onDragStartListener = OnDragStart >> Just
    , onDragByListener = OnDragBy >> Just
    , onDragEndListener = \x -> \y -> Just (OnDragEnd x y)
    , onClickListener = Just OnClick
    }


updateInternal : FCEventConfig msg -> Msg -> Model msg -> ( Model msg, Maybe msg )
updateInternal event msg mod =
    case msg of
        OnDragBy deltaPos ->
            case mod.currentlyDragging of
                DCanvas ->
                    ( { mod | position = MathUtils.addVector2 mod.position deltaPos }, Nothing )

                DNode node ->
                    let
                        updateNode fcNode =
                            { fcNode | position = MathUtils.addVector2 fcNode.position deltaPos }
                    in
                    ( { mod | nodes = Dict.update node.id (Maybe.map updateNode) mod.nodes }, Nothing )

                DPort nodeId portId linkId ->
                    let
                        updateLink link =
                            { link
                                | tempPosition =
                                    Just
                                        (MathUtils.addVector2
                                            (Maybe.withDefault (Vector2 0 0) link.tempPosition)
                                            deltaPos
                                        )
                            }
                    in
                    ( { mod | links = Dict.update linkId (Maybe.map updateLink) mod.links }, Nothing )

                None ->
                    ( mod, Nothing )

        OnDragEnd elementId parentId ->
            case mod.currentlyDragging of
                DPort nodeId portId linkId ->
                    if Dict.member parentId mod.nodes then
                        let
                            updateFcLink fcLink =
                                { fcLink | to = { nodeId = parentId, portId = elementId } }

                            updateLink link =
                                { link | tempPosition = Nothing, fcLink = updateFcLink link.fcLink }
                        in
                        ( { mod
                            | currentlyDragging = None
                            , links = Dict.update linkId (Maybe.map updateLink) mod.links
                          }
                        , Nothing
                        )

                    else
                        ( { mod
                            | currentlyDragging = None
                            , links = Dict.remove linkId mod.links
                          }
                        , Nothing
                        )

                _ ->
                    ( { mod | currentlyDragging = None }, Nothing )

        OnClick ->
            case mod.currentlyDragging of
                DCanvas ->
                    ( { mod | currentlyDragging = None }, event.onCanvasClick )

                DNode node ->
                    ( { mod | currentlyDragging = None }, event.onNodeClick node )

                DPort nodeId portId linkId ->
                    ( { mod | links = Dict.remove linkId mod.links }, Nothing )

                None ->
                    ( mod, Nothing )

        AddLink fcLink linkId ->
            let
                newLink =
                    { fcLink = { fcLink | id = linkId }, tempPosition = Nothing }
            in
            ( { mod
                | links = Dict.insert linkId newLink mod.links
                , currentlyDragging = DPort fcLink.from.nodeId fcLink.from.portId linkId
              }
            , Nothing
            )

        RemoveLink linkId ->
            ( { mod | links = Dict.remove linkId mod.links }, Nothing )

        LinkClick fcLink ->
            ( mod, event.onLinkClick fcLink )

        _ ->
            ( mod, Nothing )
