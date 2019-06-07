module FlowChart exposing
    ( Model, Msg, FCEvent, FCEventConfig
    , init, initEventConfig, defaultPortConfig, defaultLinkConfig, subscriptions
    , update, view
    , addNode, removeNode, removeLink
    , getFCState, setFCState
    )

{-| This library aims to provide a flow chart builder in Elm.


# Definition

@docs Model, Msg, FCEvent, FCEventConfig


# Subscriptions

@docs init, initEventConfig, defaultPortConfig, defaultLinkConfig, subscriptions


# Update

@docs update, view


# Functionalities

@docs addNode, removeNode, removeLink
@docs getFCState, setFCState

-}

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
    , portConfig : { portSize : Vector2, portColor : String }
    , linkConfig : { linkSize : Int, linkColor : String }
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
    | LinkClick FCLink String


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


{-|

    ** Initiaze the flowchart **

        init fcCanvas targetMsg

-}
init : FCCanvas -> (Msg -> msg) -> Model msg
init canvas targetMsg =
    { position = canvas.position
    , nodes = Dict.fromList (List.map (\n -> ( n.id, n )) canvas.nodes)
    , links = Dict.fromList (List.map (\l -> ( l.id, Link.initModel l )) canvas.links)
    , portConfig = canvas.portConfig
    , linkConfig = canvas.linkConfig
    , currentlyDragging = None
    , dragState = Draggable.init
    , targetMsg = targetMsg
    }


{-| Get default port config

    portSize = Size of port in Vector2 (20, 20)
    portColor = Color of port (grey)

-}
defaultPortConfig : { portSize : Vector2, portColor : String }
defaultPortConfig =
    { portSize = { x = 20, y = 20 }, portColor = "grey" }


{-| Get default link config

    linkSize = stroke width of link (2px)
    linkColor = Color of link (#6495ED)

-}
defaultLinkConfig : { linkSize : Int, linkColor : String }
defaultLinkConfig =
    { linkSize = 2, linkColor = "#6495ED" }


{-| List of events to subscribe

    Currently supported are :
    onCanvasClick, onNodeClick, onLinkClick

-}
initEventConfig : List (FCEvent msg) -> FCEventConfig msg
initEventConfig events =
    List.foldl (<|) Internal.defaultEventConfig events


{-| subscriptions
-}
subscriptions : { m | fcModel : Model msg } -> Sub msg
subscriptions model =
    let
        fcModel =
            model.fcModel
    in
    Sub.map fcModel.targetMsg (Draggable.subscriptions DragMsg fcModel.dragState)


{-|

    ** Update the flowchart **

-}
update :
    FCEventConfig msg
    -> Msg
    -> { m | fcModel : Model msg }
    -> ( { m | fcModel : Model msg }, Cmd msg )
update event msg model =
    let
        fcModel =
            model.fcModel
    in
    case msg of
        DragMsg dragMsg ->
            let
                ( updatedMod, cmdMsg ) =
                    Draggable.update dragEvent dragMsg fcModel
            in
            ( { model | fcModel = updatedMod }, Cmd.map fcModel.targetMsg cmdMsg )

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

                updatedMod =
                    { fcModel | currentlyDragging = currentlyDragging }
            in
            ( { model | fcModel = updatedMod }, Cmd.map fcModel.targetMsg cCmd )

        _ ->
            let
                ( updatedMod, maybeMsg ) =
                    updateInternal event msg fcModel
            in
            ( { model | fcModel = updatedMod }, CmdExtra.optionalMessage maybeMsg )


{-|

    ** Display the flowchart **

    - model -> Model holding flowchart Model
    - nodeMap -> function which gives node's html. For example:

        nodeMap : FCNode -> Model -> Html FlowChart.Msg
        nodeMap fcNode model =
            div
                [ A.style "width" "100%"
                , A.style "height" "100%"
                , A.style "background-color" "white"
                ]
                [ text fcNode.id ]

    - fcChartStyle -> css attributes for flowchart

-}
view :
    { m | fcModel : Model msg }
    -> (FCNode -> { m | fcModel : Model msg } -> Html Msg)
    -> List (Html.Attribute Msg)
    -> Html msg
view model nodeMap fcChartStyle =
    let
        mod =
            model.fcModel
    in
    Html.map mod.targetMsg
        (div
            ([ A.style "overflow" "hidden"
             , A.style "position" "fixed"
             , A.style "cursor" "move"
             , Draggable.enableDragging DCanvas DragMsg
             ]
                ++ fcChartStyle
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
                        Node.viewNode node DragMsg mod.portConfig (nodeMap node model)
                    )
                    (Dict.values mod.nodes)
                    ++ [ svg
                            [ SA.overflow "visible" ]
                            (Internal.getArrowHead mod.linkConfig.linkColor
                                ++ List.map (\l -> Link.viewLink mod.nodes LinkClick l mod.linkConfig)
                                    (Dict.values mod.links)
                            )
                       ]
                )
            ]
        )


{-| add node to canvas

        addNode fcNode Model

-}
addNode : FCNode -> { m | fcModel : Model msg } -> { m | fcModel : Model msg }
addNode newNode model =
    let
        fcModel =
            model.fcModel
    in
    { model | fcModel = { fcModel | nodes = Dict.insert newNode.id newNode fcModel.nodes } }


{-| remove node from canvas

        removeNode "node-id" Model

-}
removeNode : String -> { m | fcModel : Model msg } -> { m | fcModel : Model msg }
removeNode nodeId model =
    let
        fcModel =
            model.fcModel
    in
    { model | fcModel = { fcModel | nodes = Dict.remove nodeId fcModel.nodes } }


{-| remove link from canvas

        removeLink "link-id" FlowChartModel

-}
removeLink : String -> { m | fcModel : Model msg } -> { m | fcModel : Model msg }
removeLink linkId model =
    let
        fcModel =
            model.fcModel
    in
    { model | fcModel = { fcModel | links = Dict.remove linkId fcModel.links } }


{-| Get current flowchart state i.e position of canvas, nodes and links

        getFCState FlowChart.Model

-}
getFCState :
    Model msg
    ->
        { position : Vector2
        , nodes : List FCNode
        , links : List FCLink
        }
getFCState model =
    { position = model.position
    , nodes = Dict.values model.nodes
    , links = List.map (\l -> l.fcLink) (Dict.values model.links)
    }

{-|

    Set flowchart state i.e will override position of canvas, nodes and links
-}
setFCState :
    { position : Vector2
    , nodes : List FCNode
    , links : List FCLink
    }
    -> Model msg
    -> Model msg
setFCState data model =
    { model
        | position = data.position
        , nodes = Dict.fromList (List.map (\n -> ( n.id, n )) data.nodes)
        , links = Dict.fromList (List.map (\l -> ( l.id, Link.initModel l )) data.links)
    }



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

                DNode clickedNode ->
                    let
                        updateNode fcNode =
                            { fcNode | position = MathUtils.addVector2 fcNode.position deltaPos }
                    in
                    ( { mod | nodes = Dict.update clickedNode.id (Maybe.map updateNode) mod.nodes }, Nothing )

                DPort nodeId portId linkId ->
                    let
                        updateLink link =
                            Link.updateLinkTempPosition link deltaPos
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
                                Link.updateLink link (updateFcLink link.fcLink) Nothing
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
                    Link.initModel { fcLink | id = linkId }
            in
            ( { mod
                | links = Dict.insert linkId newLink mod.links
                , currentlyDragging = DPort fcLink.from.nodeId fcLink.from.portId linkId
              }
            , Nothing
            )

        LinkClick fcLink eventName ->
            if eventName == "click" then
                ( mod, event.onLinkClick fcLink )

            else
                ( mod, Nothing )

        _ ->
            ( mod, Nothing )
