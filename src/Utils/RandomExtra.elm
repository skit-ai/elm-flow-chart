module Utils.RandomExtra exposing (randomChar, randomString)

import Random exposing (Generator)
import String exposing (fromList)


randomChar : Generator Char
randomChar =
    Random.map (\n -> Char.fromCode (n + 97)) (Random.int 0 25)


randomString : Int -> Generator String
randomString wordLength =
    Random.map fromList (Random.list wordLength randomChar)