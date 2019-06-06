# Elm FlowChart [Under Development]

FlowChart builder in elm.

## Install
```
elm install vernacular-ai/elm-flow-chart
```

## Examples
- [BasicExample](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples/BasicExample.elm) [Minimal setup required to use the lib]
- [MultipleNodeTypesExample](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples/MultipleNodeTypesExample.elm) [Configure different node types and link or port properties]
- [EventListenerExample](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples/EventListenerExample.elm) [Subscribing to flowchart events]
- [AddNodesExample](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples/AddNodesExample.elm) [Add or Remove Nodes]
- [SaveLoadFlowChartExample](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples/SaveLoadFlowChartExample.elm) [Save or load Flowchart state as json]

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
    { fcModel : FlowChart.Model }
```

**3. Some Initialization**
```elm
type Msg
    = CanvasMsg FlowChart.Msg

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map CanvasMsg (FlowChart.subscriptions model)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { fcModel =
            FlowChart.init
                { nodes =
                    [ createNode "node-0" (FCTypes.Vector2 10 10)
                    , createNode "node-1" (FCTypes.Vector2 100 200)
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

{-| Defines how a node should look. Map a string node type to html.
-}
nodeToHtml : FCNode -> Model -> Html FlowChart.Msg
nodeToHtml node model =
    div
        [ A.style "width" "100%"
        , A.style "height" "100%"
        , A.style "background-color" "white"
        ]
        [ text nodeType ]


createNode : String -> FCTypes.Vector2 -> FCTypes.FCNode
createNode id position =
    { position = position
    , id = id
    , dim = FCTypes.Vector2 130 100
    , nodeType = "default"
    , ports =
        [ { id = "port-" ++ id ++ "-0", position = FCTypes.Vector2 0 0.42 }
        ]
    }
```
FlowChart `init` takes nodes, position, links and some configs for initial state. See [FCTypes](https://github.com/Vernacular-ai/elm-flow-chart/blob/master/src/FlowChart/Types.elm) to understand types used in the library.

**4. Update**
```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CanvasMsg cMsg ->
            FlowChart.update flowChartEvent cMsg model
```

**5. View**
```elm
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
```

See [examples](https://github.com/Vernacular-ai/elm-flow-chart/tree/master/examples) to understand all the features and how to use them.

Visit [here](https://package.elm-lang.org/packages/vernacular-ai/elm-flow-chart/latest/) for docs and more information.