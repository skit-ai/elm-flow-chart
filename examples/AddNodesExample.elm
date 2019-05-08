module AddNodesExample exposing (Model, Msg(..), init, main, update, view)

import Browser
import FlowChart
import FlowChart.Types as FCTypes
import Html exposing (..)
import Html.Attributes as A
import Html.Events


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model =
    { canvasModel : FlowChart.Model Msg
    , noOfNodes : Int
    }


type Msg
    = CanvasMsg FlowChart.Msg
    | AddNode


flowChartEvent : FlowChart.FCEventConfig Msg
flowChartEvent =
    FlowChart.initEventConfig []


init : () -> ( Model, Cmd Msg )
init _ =
    ( { canvasModel =
            FlowChart.init
                { nodes = [ createNode "0" (FCTypes.Vector2 100 200) ]
                , position = FCTypes.Vector2 0 0
                , links = []
                }
                CanvasMsg
      , noOfNodes = 1
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    FlowChart.subscriptions model.canvasModel


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            let
                ( canvasModel, canvasCmd ) =
                    FlowChart.update flowChartEvent cMsg model.canvasModel
            in
            ( { model | canvasModel = canvasModel }, canvasCmd )

        AddNode ->
            let
                cCmd =
                    FlowChart.addNode CanvasMsg
                        (createNode (String.fromInt model.noOfNodes) (FCTypes.Vector2 10 10))
            in
            ( { model | noOfNodes = model.noOfNodes + 1 }, cCmd )


view : Model -> Html Msg
view mod =
    div []
        [ button [ Html.Events.onClick AddNode ] [ text "AddNode" ]
        , FlowChart.view mod.canvasModel
            nodeToHtml
            [ A.style "height" "600px"
            , A.style "width" "85%"
            ]
        ]


nodeToHtml : String -> Html FlowChart.Msg
nodeToHtml nodeType =
    div
        [ A.style "width" "100%"
        , A.style "height" "100%"
        , A.style "background-color" "white"
        , A.style "border-radius" "4px"
        , A.style "padding" "5px"
        , A.style "box-sizing" "border-box"
        ]
        [ text nodeType ]



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
