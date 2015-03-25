-module(files_delete_handler).
-export([init/2]).

-include("privfile.hrl").

%% @private
%% @doc
%% Скачивание файла с сервера
%% @end
init(Req, Opts) ->
  [Key1] = cowboy_req:path_info(Req),
  Req2 = case ets:lookup(?linked_tab,Key1) of
    [{_, Count}] ->
      case Count > 1 of
        true ->
          delete_file(Key1),
          cowboy_req:reply(200,
            [{<<"content-type">>, <<"application/json">>}],
            <<"{\"status\":\"err\",\"err_desc\":\"file not found\"}">>,
            Req);
         false ->
           update_counter(Key1),
           {files_tab, KEY1, KEY2, Type, _File, Link} = files_dao:find(Key1),
           {ok, Binary}  = file:read_file(Link),
           DecryptFile = crypto_cli:decrypt(KEY1,KEY2,Binary),
           cowboy_req:reply(200, [{<<"content-type">>, Type}], DecryptFile, Req)
      end;
    [] ->
      delete_file(Key1),
      cowboy_req:reply(200,
        [{<<"content-type">>, <<"application/json">>}],
        <<"{\"status\":\"err\",\"err_desc\":\"file not found\"}">>,
        Req)
  end,
  {ok, Req2, Opts}.

%% @private
%% @doc
%% Удаление файла с сервера
%% @end
delete_file(Key1) ->
  files_dao:delete(Key1),
  file:delete(binary_to_list(<<"priv/", Key1/binary>>)),
  ets:delete(?linked_tab, Key1).

%% @private
%% @doc
%% Накручивание счетчика, для исключения повтороной загрузки файла с сервера
%% @end
update_counter(Key1) ->
  ets:update_counter(?linked_tab, Key1, 1).



