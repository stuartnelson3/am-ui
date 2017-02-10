module Silences.Types exposing (..)

import Http
import Utils.Types exposing (Time)
import Utils.Date
import Time
import ISO8601


type alias Silence =
    { id : Int
    , createdBy : String
    , comment : String
    , startsAt : Time
    , endsAt : Time
    , createdAt : Time
    , matchers : List Matcher
    }


type alias Matcher =
    { name : String
    , value : String
    , isRegex : Bool
    }


type Msg
    = ForSelf SilencesMsg


type SilencesMsg
    = DeleteMatcher Silence Matcher
    | AddMatcher Silence
    | UpdateMatcherName Silence Matcher String
    | UpdateMatcherValue Silence Matcher String
    | UpdateMatcherRegex Silence Matcher Bool
    | UpdateEndsAt Silence String
    | UpdateStartsAt Silence String
    | UpdateCreatedBy Silence String
    | UpdateComment Silence String
    | NewDefaultTimeRange Time.Time
    | Noop
    | SilenceCreate (Result Http.Error Int)
    | SilenceDestroy (Result Http.Error String)
    | CreateSilence Silence
    | DestroySilence Silence


nullSilence : Silence
nullSilence =
    Silence 0 "" "" nullTime nullTime nullTime [ nullMatcher ]


nullMatcher : Matcher
nullMatcher =
    Matcher "" "" False


nullTime : Time
nullTime =
    let
        epochString =
            ISO8601.toString Utils.Date.unixEpochStart
    in
        Time Utils.Date.unixEpochStart epochString True