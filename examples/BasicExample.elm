module BasicExample exposing (Model, Msg(..), init, main, update, view)

import Browser
import FCCanvas
import Html exposing (Html, div, text)
import Html.Attributes as A


main : Program () Model Msg
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model =
    { canvas : FCCanvas.Model
    }


type Msg
    = CanvasMsg FCCanvas.Msg


init : () -> ( Model, Cmd Msg )
init _ =
    ( { canvas = FCCanvas.init ()
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (FCCanvas.subscriptions model.canvas)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            let
                ( canvasModel, canvasCmd ) =
                    FCCanvas.update cMsg model.canvas
            in
            ( { model | canvas = canvasModel }, Cmd.map CanvasMsg canvasCmd )


view : Model -> Html Msg
view mod =
    div []
        [ text "hello world"
        , Html.map CanvasMsg
            (FCCanvas.view mod.canvas
                [ A.style "height" "600px"
                , A.style "width" "85%"
                ]
            )
        ]
