module Utils.MathUtils exposing (addVector2, subVector2)

import FlowChart.Types exposing (Vector2)


addVector2 : Vector2 -> Vector2 -> Vector2
addVector2 vecA vecB =
    { x = vecA.x + vecB.x, y = vecA.y + vecB.y }


subVector2 : Vector2 -> Vector2 -> Vector2
subVector2 vecA vecB =
    { x = vecA.x - vecB.x, y = vecA.y - vecB.y }
