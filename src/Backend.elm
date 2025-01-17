port module Backend exposing (..)
import Types exposing(Song)

import Utils exposing (..)
import Models exposing (Model)

import List exposing (filter, map, append)
import String exposing (contains, toUpper)

-- Existe la funcion findSong que recibe
-- una condicion y una lista de canciones
-- findSong : (Song -> Bool) -> List Song -> Song

-- Existe la funcion tailSafe que recibe
-- una lista de canciones y se queda con la cola
-- si la lista no tiene cola (tiene un solo elemento)
-- se queda con una lista vacia
-- tailSafe : List Song -> List Song

-- Existe idFirst que recibe una lista
-- de canciones y devuelve el id de la primera
-- idFirst : List Song -> String

-- Debería darnos la url de la cancion en base al id
urlById : String -> List Song -> String
urlById id songs = (encontrarPorId id songs).url

encontrarPorId : String -> List Song -> Song
encontrarPorId id = findSong (esSuId id) 

esSuId : String -> Song -> Bool
esSuId unId song = song.id == unId

noEsSuId : String -> Song -> Bool
noEsSuId unId song = song.id /= unId

-- Debería darnos las canciones que tengan ese texto en nombre o artista
filterByName : String -> List Song -> List Song
filterByName text = filter (estaEnElNombreOArtista text)

estaEnElNombreOArtista : String -> Song -> Bool
estaEnElNombreOArtista texto song = ((||) (loContiene texto song.artist) << loContiene texto) song.name

loContiene : String -> String -> Bool
loContiene texto lugar = (contains (toUpper texto) << toUpper) lugar

-- Recibe un id y tiene que likear/dislikear una cancion
-- switchear song.liked

toggleLike : String -> List Song -> List Song
toggleLike id songs = map (switchearLikeSiEsSuId id) songs

switchearLikeSiEsSuId : String -> Song -> Song
switchearLikeSiEsSuId id song = if esSuId id song then switchearLike song else song

switchearLike : Song -> Song
switchearLike song = if song.liked then dislikear song else likear song

likear : Song -> Song
likear song = { song | liked = True }

dislikear : Song -> Song
dislikear song = { song | liked = False }

-- Esta funcion tiene que decir si una cancion tiene
-- nuestro like o no, por ahora funciona mal...
-- hay que arreglarla
isLiked : Song  -> Bool
isLiked song = song.liked

-- Recibe una lista de canciones y nos quedamos solo con las que
-- tienen un like
filterLiked : List Song -> List Song
filterLiked = filter (isLiked)

-- Agrega una cancion a la cola de reproduccion
-- (NO es necesario preocuparse porque este una sola vez)
addSongToQueue : Song -> List Song -> List Song
addSongToQueue song queue = append queue [song]

-- Saca una cancion de la cola
-- (NO es necesario que se elimine una sola vez si esta repetida)
removeSongFromQueue : String -> List Song -> List Song
removeSongFromQueue id = filter (noEsSuId id)

-- Hace que se reproduzca la canción que sigue y la saca de la cola
playNextFromQueue : Model -> Model
playNextFromQueue model = (playSong (removeHeadFromQueue model) << idFirst) model.queue

removeHeadFromQueue : Model -> Model
removeHeadFromQueue model = { model | queue = tailSafe model.queue }

-------- Funciones Listas --------

-- Esta funcion recibe el modelo y empieza a reproducir la
-- cancion que tenga el id que se pasa...
-- Mirar la función urlById
playSong : Model -> String -> Model
playSong model id = { model | playerUrl = urlById id model.songs, playing = (if id /= "" then Just True else Nothing) }

applyFilters : Model -> List Song
applyFilters model =
  model.songs
    |> filterByName model.filterText
    |> if model.onlyLiked then filterLiked else identity

port togglePlay : Bool -> Cmd msg
port songEnded : (Bool -> msg) -> Sub msg