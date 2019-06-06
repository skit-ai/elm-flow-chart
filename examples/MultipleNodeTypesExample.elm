module MultipleNodeTypesExample exposing (Model, Msg(..), init, main, update, view)

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
    { fcModel : FlowChart.Model Msg
    }


type Msg
    = CanvasMsg FlowChart.Msg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { fcModel =
            FlowChart.init
                { nodes =
                    [ createNode "node-0" "default" (FCTypes.Vector2 10 10)
                    , createNode "node-1" "orange" (FCTypes.Vector2 100 200)
                    , createNode "node-2" "orange" (FCTypes.Vector2 400 400)
                    , createNode "node-3" "green" (FCTypes.Vector2 300 500)
                    ]
                , position = FCTypes.Vector2 0 0
                , links = []
                , portConfig = { portSize = FCTypes.Vector2 20 20, portColor = "#72776e" }
                , linkConfig = { linkSize = 3, linkColor = "blue" }
                }
                CanvasMsg
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    FlowChart.subscriptions model


flowChartEvent : FlowChart.FCEventConfig Msg
flowChartEvent =
    FlowChart.initEventConfig []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            FlowChart.update flowChartEvent cMsg model


view : Model -> Html Msg
view model =
    div []
        [ FlowChart.view model
            nodeToHtml
            [ A.style "height" "600px"
            , A.style "width" "85%"
            , A.style "background-color" "lightgrey"
            ]
        ]


nodeToHtml : FCTypes.FCNode -> Html FlowChart.Msg
nodeToHtml fcNode =
    case fcNode.nodeType of
        "orange" ->
            div
                [ A.style "width" "100%"
                , A.style "height" "100%"
                , A.style "background-color" "#d5974d"
                , A.style "border-radius" "4px"
                , A.style "box-sizing" "border-box"
                ]
                [ text fcNode.id ]

        "green" ->
            div
                [ A.style "width" "100%"
                , A.style "height" "100%"
                , A.style "background-color" "#62a22d"
                , A.style "border-radius" "4px"
                , A.style "box-sizing" "border-box"
                ]
                [ text fcNode.id ]

        _ ->
            div
                [ A.style "width" "100%"
                , A.style "height" "100%"
                , A.style "background-color" "white"
                , A.style "border-radius" "4px"
                , A.style "box-sizing" "border-box"
                ]
                [ text fcNode.id ]



-- HELPER FUNCTIONS


createNode : String -> String -> FCTypes.Vector2 -> FCTypes.FCNode
createNode id nodeType position =
    { position = position
    , id = id
    , dim = FCTypes.Vector2 130 100
    , nodeType = nodeType
    , ports =
        [ { id = "port-" ++ id ++ "-0", position = FCTypes.Vector2 0 0.42 }
        , { id = "port-" ++ id ++ "-1", position = FCTypes.Vector2 0.85 0.42 }
        ]
    }
