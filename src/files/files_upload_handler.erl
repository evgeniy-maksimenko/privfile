-module(files_upload_handler).

-export([init/2]).
-include("privfile.hrl").
init(Req, Opts) ->
  Req2 = multipart(Req),
  {ok, Req2, Opts}.

-define(generate_key, generate_key()).

%% @private
%% @doc
%% Загрузка файла на сервер
%% @end
multipart(Req) ->
  case cowboy_req:part(Req) of
    {ok, Headers, Req2} ->
      Req4 = case cow_multipart:form_data(Headers) of
               {data, _FieldName} ->
                 {ok, _Body, Req3} = cowboy_req:part_body(Req2),
                 Req3;
               {file, _FieldName, _Filename, CType, _CTransferEncoding} ->
                 KEY1 = ?generate_key,
                 KEY2 = ?generate_key,
                 ets:insert(?linked_tab, {KEY1 , 1}),
                 file:write_file(<<"./priv/", KEY1/binary>>, <<"">>),
                 Req5 = stream_file(Req2, <<"./priv/", KEY1/binary>>,CType,KEY1,KEY2),
                 reply(Req5, <<"/files/delete/", KEY1/binary,"#",KEY2/binary>>)
             end,
      multipart(Req4);
    {done, Req2} ->
      Req2
  end.

%% @private
%% @doc
%% Сохранение файла
%% @end
stream_file(Req, FilenameLink,CType,KEY1,KEY2) ->
  case cowboy_req:part_body(Req) of
    {ok, Body, Req2} ->
      BodyCrypt = crypto_cli:encrypt(KEY1,KEY2,Body),
      file:write_file(FilenameLink, BodyCrypt, [append]),
      files_dao:write(#files_tab{key1 = KEY1,key2 = KEY2,type = CType, file_destination = FilenameLink}),
      Req2;
    {more, Body, Req2} ->
      BodyCrypt = crypto_cli:encrypt(KEY1,KEY2,Body),
      file:write_file(FilenameLink, BodyCrypt, [append]),
      files_dao:write(#files_tab{key1 = KEY1,key2 = KEY2,type = CType, file_destination = FilenameLink}),
      stream_file(Req2, FilenameLink,CType,KEY1,KEY2)
  end.

%% @private
%% @doc
%% Ссылка на файл по которой этот файл можно будет получить с сервера
%% @end
reply(Req, Filename) ->
  Url = cowboy_req:host_url(Req),
  Req1 = cowboy_req:reply(200,
    [{<<"content-type">>, <<"application/json">>}],
    <<"{\"status\":\"ok\",\"link\":\"", Url/binary, Filename/binary, "\"}">>,
    Req),
  Req1.

%% @private
%% @doc
%% генерим уникальный идентификатор
%% @end
generate_key()-> list_to_binary(hex:to_hex(crypto:rand_bytes(8))).


