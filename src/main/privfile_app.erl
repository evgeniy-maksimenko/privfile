-module(privfile_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/files/upload/", 				files_upload_handler, 	[]},
      {"/files/delete/[...]", 	files_delete_handler,   []},
%%       {"/files/get/[...]", 			cowboy_static, {dir, "./priv", [{mimetypes, cow_mimetypes, all}]}},
      {"/[...]", cowboy_static, {file, "priv/index.html"}}
    ]}
  ]),
  Port = 8008,
  {ok, _} = cowboy:start_http(http_listener, 100,
    [{port, Port}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  privfile_sup:start_link().

stop(_State) ->
    ok.
