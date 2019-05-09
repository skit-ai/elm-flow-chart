module FlowChart.Events exposing (onCanvasClick, onNodeClick, onLinkClick)

{-| Listeners for the various flowchart events.

@docs onCanvasClick, onNodeClick, onLinkClick

-}

import FlowChart exposing (FCEvent, FCEventConfig)
import FlowChart.Types exposing (FCLink, FCNode)


{-| Register a `CanvasClick` event listener. It will not trigger if canvas has moved
after mouse down.
-}
onCanvasClick : msg -> FCEvent msg
onCanvasClick toMsg config =
    { config | onCanvasClick = Just toMsg }


{-| Register a `NodeClick` event listener. It will not trigger if node has moved
after mouse down.
-}
onNodeClick : (FCNode -> msg) -> FCEvent msg
onNodeClick toMsg config =
    { config | onNodeClick = toMsg >> Just }


{-| Register a `LinkClick` event listener.
-}
onLinkClick : (FCLink -> msg) -> FCEvent msg
onLinkClick toMsg config =
    { config | onLinkClick = toMsg >> Just }
