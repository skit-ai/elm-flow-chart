module SaveLoadFlowChartExample exposing (main)

import Browser
import File exposing (File)
import File.Download
import File.Select
import FlowChart
import FlowChart.Json as FJ
import FlowChart.Types as FCTypes
import Html exposing (..)
import Html.Attributes as A
import Html.Events
import Json.Decode as Decode
import Json.Encode as Encode
import Task


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model =
    { fcModel : FlowChart.Model Msg
    }


type Msg
    = CanvasMsg FlowChart.Msg
    | SaveFlowChart
    | LoadFlowChart
    | StateFileSelected File
    | StateFileLoaded String


flowChartEvent : FlowChart.FCEventConfig Msg
flowChartEvent =
    FlowChart.initEventConfig []


init : () -> ( Model, Cmd Msg )
init _ =
    ( { fcModel =
            FlowChart.init
                { nodes =
                    [ createNode "0" (FCTypes.Vector2 100 200)
                    , createNode "1" (FCTypes.Vector2 400 300)
                    , createNode "2" (FCTypes.Vector2 500 600)
                    ]
                , position = FCTypes.Vector2 0 0
                , links = []
                , portConfig = FlowChart.defaultPortConfig
                , linkConfig = FlowChart.defaultLinkConfig
                }
                CanvasMsg
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    FlowChart.subscriptions model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            FlowChart.update flowChartEvent cMsg model

        SaveFlowChart ->
            ( model, saveFlowChart model.fcModel )

        LoadFlowChart ->
            ( model, File.Select.file [ "application/json" ] StateFileSelected )

        StateFileSelected file ->
            ( model, Task.perform StateFileLoaded (File.toString file) )

        StateFileLoaded fileData ->
            ( { model | fcModel = loadFlowChart model.fcModel fileData }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ Html.Events.onClick SaveFlowChart ] [ text "Save Flow Chart" ]
        , button [ Html.Events.onClick LoadFlowChart ] [ text "Load Flow Chart" ]
        , FlowChart.view model
            nodeToHtml
            [ A.style "height" "600px"
            , A.style "width" "85%"
            , A.style "background-color" "lightgrey"
            ]
        ]


nodeToHtml : FCTypes.FCNode -> Model -> Html FlowChart.Msg
nodeToHtml fcNode model =
    div
        [ A.style "width" "100%"
        , A.style "height" "100%"
        , A.style "background-color" "white"
        , A.style "border-radius" "4px"
        , A.style "box-sizing" "border-box"
        ]
        [ text fcNode.id ]


-- HELPER FUNCTIONS


createNode : String -> FCTypes.Vector2 -> FCTypes.FCNode
createNode id position =
    { position = position
    , id = id
    , dim = FCTypes.Vector2 130 100
    , nodeType = "default"
    , ports =
        [ { id = "port-" ++ id ++ "-0", position = FCTypes.Vector2 0 0.42 }
        , { id = "port-" ++ id ++ "-1", position = FCTypes.Vector2 0.85 0.42 }
        ]
    }


saveFlowChart : FlowChart.Model Msg -> Cmd Msg
saveFlowChart model =
    let
        { position, nodes, links } =
            FlowChart.getFCState model

        flowChartValue =
            Encode.object
                [ ( "position", FJ.encodeVector2 position )
                , ( "fcNodes", Encode.list FJ.encodeFCNode nodes )
                , ( "fcLinks", Encode.list FJ.encodeFCLink links )
                ]
    in
    File.Download.string "state.json" "application/json" (Encode.encode 2 flowChartValue)


type alias FCState =
    { position : FCTypes.Vector2
    , nodes : List FCTypes.FCNode
    , links : List FCTypes.FCLink
    }


loadFlowChart : FlowChart.Model Msg -> String -> FlowChart.Model Msg
loadFlowChart model fileData =
    let
        flowChartDecoder =
            Decode.map3 FCState
                (Decode.field "position" FJ.vector2Decoder)
                (Decode.field "fcNodes" (Decode.list FJ.fcNodeDecoder))
                (Decode.field "fcLinks" (Decode.list FJ.fcLinkDecoder))
    
        fcData = Result.toMaybe (Decode.decodeString flowChartDecoder fileData)
    in
    
    case fcData of
        Nothing ->
            model

        Just data ->
            FlowChart.setFCState data model
