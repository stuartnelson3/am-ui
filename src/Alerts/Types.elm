module Alerts.Types exposing (..)

import Http exposing (Error)
import ISO8601


type Route
    = Route


type Msg
    = ForSelf AlertsMsg
    | ForParent OutMsg


type OutMsg
    = UpdateLoading Bool
    | SilenceFromAlert Alert


type AlertsMsg
    = AlertGroupsFetch (Result Http.Error (List AlertGroup))
    | FetchAlertGroups
    | Noop


type alias Block =
    { alerts : List Alert
    , routeOpts : RouteOpts
    }


type alias RouteOpts =
    { receiver : String }


type alias AlertGroup =
    { blocks : List Block
    , labels : List ( String, String )
    }


type alias Alert =
    { annotations : List ( String, String )
    , labels : List ( String, String )
    , inhibited : Bool
    , silenceId : Maybe Int
    , silenced : Bool
    , startsAt : ISO8601.Time
    , generatorUrl : String
    }