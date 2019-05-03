module BasicExample exposing (Model, Msg(..), init, main, update, view)

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
    { canvasModel : FlowChart.Model
    }


type Msg
    = CanvasMsg FlowChart.Msg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { canvasModel =
            FlowChart.init
                { nodes =
                    [ createNode "node-0" (FCTypes.Position 10 10)
                    , createNode "node-1" (FCTypes.Position 100 200)
                    ]
                , position = FCTypes.Position 0 0
                , links =
                    [ FCTypes.FCLink "link-0"
                        { nodeId = "node-0", portId = "port-node-0-1" }
                        { nodeId = "node-1", portId = "port-node-1-0" }
                    ]
                }
                nodeToHtml
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (FlowChart.subscriptions model.canvasModel)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            let
                ( canvasModel, canvasCmd ) =
                    FlowChart.update cMsg model.canvasModel
            in
            ( { model | canvasModel = canvasModel }, Cmd.map CanvasMsg canvasCmd )


view : Model -> Html Msg
view mod =
    div []
        [ Html.map CanvasMsg
            (FlowChart.view mod.canvasModel
                [ A.style "height" "600px"
                , A.style "width" "85%"
                ]
            )
        ]


nodeToHtml : String -> Html FlowChart.Msg
nodeToHtml nodeType =
    div
        [ A.style "width" "40px"
        , A.style "height" "25px"
        , A.style "background-color" "white"
        , A.style "padding" "35px 45px"
        ]
        [ text nodeType ]



-- HELPER FUNCTIONS


createNode : String -> FCTypes.Position -> FCTypes.FCNode
createNode id position =
    { position = position
    , id = id
    , nodeType = "default"
    , ports =
        [ { id = "port-" ++ id ++ "-0", position = FCTypes.Position 0.42 0 }
        , { id = "port-" ++ id ++ "-1", position = FCTypes.Position 0.42 0.8 }
        ]
    }
