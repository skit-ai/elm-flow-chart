module BasicExample exposing (Model, Msg(..), init, main, update, view)

import Browser
import FCCanvas
import Html exposing (..)
import Html.Attributes as A
import Html.Events
import Types


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model =
    { canvasModel : FCCanvas.Model
    , noOfNodes : Int
    }


type Msg
    = CanvasMsg FCCanvas.Msg
    | AddNode


init : () -> ( Model, Cmd Msg )
init _ =
    ( { canvasModel = FCCanvas.init nodeToHtml
      , noOfNodes = 0
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (FCCanvas.subscriptions model.canvasModel)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            let
                ( canvasModel, canvasCmd ) =
                    FCCanvas.update cMsg model.canvasModel
            in
            ( { model | canvasModel = canvasModel }, Cmd.map CanvasMsg canvasCmd )

        AddNode ->
            let
                cCmd =
                    FCCanvas.addNode
                        { position = Types.Position 10 10
                        , id = String.fromInt model.noOfNodes
                        , nodeType = "default"
                        }
            in
            ( { model | noOfNodes = model.noOfNodes + 1 }, Cmd.map CanvasMsg cCmd )


view : Model -> Html Msg
view mod =
    div []
        [ button [ Html.Events.onClick AddNode ] [ text "AddNode" ]
        , Html.map CanvasMsg
            (FCCanvas.view mod.canvasModel
                [ A.style "height" "600px"
                , A.style "width" "85%"
                ]
            )
        ]


nodeToHtml : String -> Html FCCanvas.Msg
nodeToHtml nodeType =
    div
        [ A.style "width" "40px"
        , A.style "height" "25px"
        , A.style "background-color" "white"
        , A.style "padding" "35px 45px"
        ]
        [ text nodeType ]
