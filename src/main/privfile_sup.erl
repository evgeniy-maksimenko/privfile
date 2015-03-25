-module(privfile_sup).
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).
-include("privfile.hrl").

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  ets:new(?linked_tab, [set, named_table, public, {write_concurrency, true}]),
  Flags = {one_for_one, 5, 10},
  FsmWorker = {privfile_worker, {privfile_worker, start_link,[]}, permanent, 2000, supervisor,[privfile_worker]},
  {ok, { Flags , [FsmWorker]} }.

