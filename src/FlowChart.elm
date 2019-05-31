module FlowChart exposing
    ( Model, Msg, FCEvent, FCEventConfig
    , init, initEventConfig, defaultPortConfig, defaultLinkConfig, subscriptions
    , update, view
    , addNode, removeNode, removeLink
    , saveFlowChart, loadFlowChart
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
@docs saveFlowChart, loadFlowChart

-}

import Dict exposing (Dict)
import File exposing (File)
import FlowChart.Types exposing (FCCanvas, FCLink, FCNode, FCPort, Vector2)
import Html exposing (Html, div)
import Html.Attributes as A
import Internal exposing (DraggableTypes(..), toPx)
import Link
import Node
import Random
import SaveState
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
    , nodes : Dict String (Node.Model Msg)
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
    | StateFileSelected File
    | StateFileLoaded String


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
    , nodes = Dict.fromList (List.map (\n -> ( n.id, Node.initModel n )) canvas.nodes)
    , links = Dict.fromList (List.map (\l -> ( l.id, Link.initModel l )) canvas.links)
    , portConfig = canvas.portConfig
    , linkConfig = canvas.linkConfig
    , currentlyDragging = None
    , dragState = Draggable.init
    , targetMsg = target
    }


{-| get default port config

    portSize = Size of port in Vector2 (20, 20)
    portColor = Color of port (grey)

-}
defaultPortConfig : { portSize : Vector2, portColor : String }
defaultPortConfig =
    { portSize = { x = 20, y = 20 }, portColor = "grey" }


{-| get default link config

    linkSize = stroke width of link (2px)
    linkColor = Color of link (#6495ED)

-}
defaultLinkConfig : { linkSize : Int, linkColor : String }
defaultLinkConfig =
    { linkSize = 2, linkColor = "#6495ED" }


{-| pass list of events to subscribe to.
Currently supported are :
onCanvasClick, onNodeClick, onLinkClick
-}
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

        StateFileSelected file ->
            ( mod, Cmd.map mod.targetMsg (CmdExtra.messageTask StateFileLoaded (File.toString file)) )

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
                        Node.viewNode node DragMsg mod.portConfig nodeMap
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
-}
addNode : FCNode -> Model msg -> Model msg
addNode newNode model =
    { model | nodes = Dict.insert newNode.id (Node.initModel newNode) model.nodes }


{-| remove node from canvas

        removeNode "node-id" FlowChartModel

-}
removeNode : String -> Model msg -> Model msg
removeNode nodeId model =
    { model | nodes = Dict.remove nodeId model.nodes }


{-| remove link from canvas

        removeLink "link-id" FlowChartModel

-}
removeLink : String -> Model msg -> Model msg
removeLink linkId model =
    { model | links = Dict.remove linkId model.links }


{-| save flowchart state as json file

        saveFlowChart "<path/to/file.json>" FlowChartModel

-}
saveFlowChart : String -> Model msg -> Cmd msg
saveFlowChart filePath model =
    let
        links =
            List.map (\l -> l.fcLink) (Dict.values model.links)

        nodes =
            List.map (\n -> n.fcNode) (Dict.values model.nodes)
    in
    SaveState.toFile filePath model.position nodes links


{-| load flowchart state from a json file. Will open a file selector dialog
to select the file

        loadFlowChart FlowChartModel

-}
loadFlowChart : Model msg -> Cmd msg
loadFlowChart model =
    Cmd.map model.targetMsg (SaveState.selectFile StateFileSelected)



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
                        updateFCNode fcNode =
                            { fcNode | position = MathUtils.addVector2 fcNode.position deltaPos }

                        updateNode node =
                            { node | fcNode = updateFCNode node.fcNode }
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

        StateFileLoaded fileData ->
            case SaveState.toObject fileData of
                Nothing ->
                    ( mod, Nothing )

                Just data ->
                    ( { mod
                        | position = data.position
                        , nodes = Dict.fromList (List.map (\n -> ( n.id, Node.initModel n )) data.nodes)
                        , links = Dict.fromList (List.map (\l -> ( l.id, Link.initModel l )) data.links)
                      }
                    , Nothing
                    )

        _ ->
            ( mod, Nothing )
