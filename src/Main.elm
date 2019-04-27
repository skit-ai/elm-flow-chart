module Counter exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Browser exposing (..)


main : Program () Model Action
main =
  Browser.element { init = init, view = view, update = update, subscriptions = always Sub.none }


-- MODEL

type Action = Increment | Decrement

type alias Model = Int


init : () -> (Model, Cmd Action)
init _ =
  (
    0,
    Cmd.none
  )


-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update act count =
  case act of
    Increment -> (count + 1, Cmd.none)
    Decrement -> (count - 1, Cmd.none)


view : Model -> Html Action
view mod =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text (String.fromInt mod) ]
    , button [ onClick Increment ] [ text "+" ]
    ]