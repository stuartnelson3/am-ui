module Silences.Update exposing (..)

import Navigation
import Silences.Api as Api
import Silences.Types exposing (..)
import Task
import Utils.Types as Types exposing (ApiData, ApiResponse(..), Time)
import ISO8601
import Time
import Utils.Date
import Utils.List


update : SilencesMsg -> ApiData (List Silence) -> ApiData Silence -> ( ApiData (List Silence), ApiData Silence, Cmd Msg )
update msg silences silence =
    case msg of
        CreateSilence silence ->
            ( silences, Loading, Api.create silence )

        DestroySilence silence ->
            ( silences, Loading, Api.destroy silence )

        SilenceCreate (Ok id) ->
            ( silences, Loading, Navigation.newUrl ("/#/silences/" ++ toString id) )

        SilenceCreate (Err err) ->
            ( silences, Failure err, Navigation.newUrl "/#/silences" )

        SilenceDestroy (Ok id) ->
            -- TODO: "Deleted id: ID" growl
            -- TODO: Add DELETE to accepted CORS methods in alertmanager
            -- TODO: Check why POST isn't there but is accepted
            ( silences, Loading, Navigation.newUrl "/#/silences" )

        SilenceDestroy (Err err) ->
            -- TODO: Add error to the message or something.
            ( silences, Failure err, Navigation.newUrl "/#/silences" )

        UpdateStartsAt silence time ->
            -- TODO:
            -- Update silence to hold datetime as string, on each pass through
            -- here update an error message "this is invalid", but let them put
            -- it in anyway.
            let
                startsAt =
                    Utils.Date.toISO8601Time time
            in
                ( silences, Success { silence | startsAt = startsAt }, Cmd.none )

        UpdateEndsAt silence time ->
            let
                endsAt =
                    Utils.Date.toISO8601Time time
            in
                ( silences, Success { silence | endsAt = endsAt }, Cmd.none )

        UpdateCreatedBy silence by ->
            ( silences, Success { silence | createdBy = by }, Cmd.none )

        UpdateComment silence comment ->
            ( silences, Success { silence | comment = comment }, Cmd.none )

        AddMatcher silence ->
            -- TODO: If a user adds two blank matchers and attempts to update
            -- one, both are updated because they are identical. Maybe add a
            -- unique identifier on creation so this doesn't happen.
            ( silences, Success { silence | matchers = silence.matchers ++ [ nullMatcher ] }, Cmd.none )

        DeleteMatcher silence matcher ->
            let
                -- TODO: This removes all empty matchers. Maybe just remove the
                -- one that was clicked.
                newSil =
                    { silence | matchers = (List.filter (\x -> x /= matcher) silence.matchers) }
            in
                ( silences, Success newSil, Cmd.none )

        UpdateMatcherName silence matcher name ->
            let
                matchers =
                    Utils.List.replaceIf (\x -> x == matcher) { matcher | name = name } silence.matchers
            in
                ( silences, Success { silence | matchers = matchers }, Cmd.none )

        UpdateMatcherValue silence matcher value ->
            let
                matchers =
                    Utils.List.replaceIf (\x -> x == matcher) { matcher | value = value } silence.matchers
            in
                ( silences, Success { silence | matchers = matchers }, Cmd.none )

        UpdateMatcherRegex silence matcher bool ->
            let
                matchers =
                    Utils.List.replaceIf (\x -> x == matcher) { matcher | isRegex = bool } silence.matchers
            in
                ( silences, Success { silence | matchers = matchers }, Cmd.none )

        NewDefaultTimeRange time ->
            let
                endsIso =
                    Utils.Date.addTime time (2 * Time.hour)

                endsAt =
                    Types.Time endsIso (ISO8601.toString endsIso) True

                startsIso =
                    Utils.Date.toISO8601 time

                startsAt =
                    Types.Time endsIso (ISO8601.toString startsIso) True

                sil =
                    case silence of
                        Success s ->
                            s

                        _ ->
                            nullSilence
            in
                ( silences, Success { sil | startsAt = startsAt, endsAt = endsAt }, Cmd.none )

        Noop ->
            ( silences, silence, Cmd.none )