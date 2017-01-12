%% Copyright (c) 2016, Benoit Chesneau.
%%
%% This file is part of barrel_metrics released under the BSD license.
%% See the NOTICE for more information.

%% Created by benoitc on 26/06/16.

-module(metrics_tests2).
-author("Benoit Chesneau").


-include_lib("eunit/include/eunit.hrl").

setup() ->
  {ok, _} =  application:ensure_all_started(metrics2),
  {ok, _} =  application:ensure_all_started(folsom),
  {ok, _} =  application:ensure_all_started(exometer_core),
  ok.

teardown(_) ->
  application:stop(folsom),
  application:stop(exometer_core),
  application:stop(metrics2),
  ok.


folsom_test_() ->
  {
    "Folsom backend test",
    {foreach,
      fun setup/0, fun teardown/1,
      [

        fun folsom_counter_test_/1,
        fun folsom_counter_test_inc_/1,
        fun folsom_counter_test_mul_/1,
        fun folsom_gauge_test_/1,
        fun folsom_update_or_create_/1,
        fun folsom_delete_/1
      ]
    }
  }.


exometer_test_() ->
  {
    "Exometer backend test",
    {foreach,
      fun setup/0, fun teardown/1,
      [

        fun exometer_counter_test_/1,
        fun exometer_counter_test_inc_/1,
        fun exometer_counter_test_mul_/1,
        fun exometer_gauge_test_/1,
        fun exometer_update_or_create_/1,
        fun exometer_delete_/1
      ]
    }
  }.

folsom_counter_test_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  ok = metrics2:new(counter, "c"),
  metrics2:update("c"),
  ?_assertEqual(1, folsom_metrics:get_metric_value("c")).

folsom_counter_test_inc_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  ok = metrics2:new(counter, "c"),
  metrics2:update("c", {c, 1}),
  ?_assertEqual(1, folsom_metrics:get_metric_value("c")).

folsom_counter_test_mul_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  ok = metrics2:new(counter, "c"),
  metrics2:update("c", {c, 1}),
  metrics2:update("c", {c, 1}),
  metrics2:update("c", {c, 4}),
  metrics2:update("c", {c, -1}),
  ?_assertEqual(5, folsom_metrics:get_metric_value("c")).

folsom_gauge_test_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  ok = metrics2:new(gauge, "g"),
  metrics2:update("g", 1),
  ?_assertEqual(1, folsom_metrics:get_metric_value("g")).

folsom_update_or_create_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  metrics2:update_or_create("new_counter", {c, 1}, counter),
  ?_assertEqual(1, folsom_metrics:get_metric_value("new_counter")).

folsom_delete_(_) ->
  ok = metrics2:backend(metrics_folsom2),
  ok = metrics2:new(gauge, "g"),
  ok = metrics2:new(counter, "c"),
  ok = metrics2:delete("g"),
  ?_assertEqual(["c"], folsom_metrics:get_metrics()).

exometer_counter_test_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  ok = metrics2:new(counter, "c1"),
  metrics2:update("c1"),
  ?_assertMatch({ok, [{value, 1}, _]}, exometer:get_value("c1")).

exometer_counter_test_inc_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  ok = metrics2:new(counter, "c1"),
  metrics2:update("c1", {c, 1}),
  ?_assertMatch({ok, [{value, 1}, _]}, exometer:get_value("c1")).

exometer_counter_test_mul_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  ok = metrics2:new(counter, "c1"),
  metrics2:update("c1", {c, 1}),
  metrics2:update("c1", {c, 1}),
  metrics2:update("c1", {c, 4}),
  metrics2:update("c1", {c, -1}),
  ?_assertMatch({ok, [{value, 5}, _]}, exometer:get_value("c1")).

exometer_gauge_test_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  ok = metrics2:new(gauge, "g1"),
  metrics2:update("g1", 1),
  ?_assertMatch({ok, [{value, 1}, _]}, exometer:get_value("g1")).

exometer_update_or_create_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  metrics2:update_or_create("new_exo_counter", {c, 1}, counter),
  ?_assertMatch({ok, [{value, 1}, _]}, exometer:get_value("new_exo_counter")).

exometer_delete_(_) ->
  ok = metrics2:backend(metrics_exometer2),
  ok = metrics2:new(gauge, "g"),
  ok = metrics2:new(counter, "c"),
  ok = metrics2:delete("g"),
  ?_assertEqual(undefined, exometer:info("g", status)).
