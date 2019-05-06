# Elm FlowChart [Under Development]

FlowChart builder in elm.

## Install
```
elm install vernacular-ai/elm-flow-chart
```

## Usage
Its an easy to use library to build flow charts or state diagrams in elm. 

#### Basic
**1. Import this library**
```elm
import FlowChart
import FlowChart.Types as FCTypes
```

**2. Define Model**
```elm
type alias Model =
    { canvasModel : FlowChart.Model
    }
```

**3. Some Initialization**
```elm
type Msg
    = CanvasMsg FlowChart.Msg

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (FlowChart.subscriptions model.canvasModel)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { canvasModel =
            FlowChart.init
                { nodes =
                    [ createNode "node-0" (FCTypes.Vector2 10 10)
                    , createNode "node-1" (FCTypes.Vector2 100 200)
                    ]
                , position = FCTypes.Vector2 0 0
                , links = []
                }
                nodeToHtml
      }
    , Cmd.none
    )
```
FlowChart `init` takes nodes, position and links for initial state. See [FCTypes](https://github.com/Vernacular-ai/elm-flow-chart/blob/master/src/FlowChart/Types.elm) to understand types used in the library.

**4. Update**
```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            let
                ( canvasModel, canvasCmd ) =
                    FlowChart.update cMsg model.canvasModel
            in
            ( { model | canvasModel = canvasModel }, Cmd.map CanvasMsg canvasCmd )
```

**5. View**
```elm
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
```

See [examples](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples) to better understand all the features and how to use them.