module Utils.CmdExtra exposing (message, multiMessage, optionalMessage, messageTask)

import Task exposing (Task)


message : msg -> Cmd msg
message x =
    Task.perform identity (Task.succeed x)


messageTask : (a -> msg) -> Task Never a -> Cmd msg
messageTask tMsg tsk =
    Task.perform tMsg tsk


multiMessage : List msg -> Cmd msg
multiMessage xs =
    xs
        |> List.map message
        |> Cmd.batch


optionalMessage : Maybe msg -> Cmd msg
optionalMessage msgMaybe =
    msgMaybe
        |> Maybe.map message
        |> Maybe.withDefault Cmd.none
