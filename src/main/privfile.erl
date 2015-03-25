-module(privfile).

%% API
-export([
  start/0,
  stop/0
]).

-include("privfile.hrl").
-define(AtomList(Table), [ {disc_copies, [node()]}, {type, bag}, {attributes, record_info(fields, Table)}]).

start() ->

  create_db_dir(),

  application:set_env(mnesia, dir, "priv/db/mnesia"),
  mnesia:create_schema([node()]),
  
  F = fun({App, _, _}) -> App end,
  RunningApps = lists:map(F, application:which_applications()),
  LoadedApps = lists:map(F, application:loaded_applications()),
  case lists:member(?MODULE, LoadedApps) of
    true ->
      true;
    false ->
      ok = application:load(?MODULE)
  end,
  {ok, Apps} = application:get_key(?MODULE, applications),
  [ok = application:start(A) || A <- Apps ++ [?MODULE], not lists:member(A, RunningApps)],
  ok = init_table(?files_tab, ?AtomList(?files_tab)),
  ok.
stop() ->
  application:stop(?MODULE).

%% @private
%% @doc
%% Создание дирректории для локальной базы данных (mnesia)
%% @end
create_db_dir() -> create_priv_dir(file:make_dir("priv/db")).
create_priv_dir(ok) -> file:make_dir("priv/db/mnesia");
create_priv_dir(_) -> ok.

%% @private
%% @doc
%% Инициализация локальной базы данных (mnesia)
%% @end
init_table(Table, AtomList) ->
  S = mnesia:create_table(Table, AtomList),
  table_loaded(S),
  ok = mnesia:wait_for_tables([Table], 30000),
  ok.

%% @private
%% @doc
%% Информация об инициализации локальных баз данных (mnesia)
%% @end
table_loaded({already_exists, _Table}) -> ok;
table_loaded({atomic, ok}) -> ok;
table_loaded(Result) -> io:format("smt with mnesia ~p~n", [Result]).