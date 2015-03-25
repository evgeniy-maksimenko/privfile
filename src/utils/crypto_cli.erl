-module(crypto_cli).
-export([decrypt/3, encrypt/3]).

-type key1() :: binary().
-type key2() :: binary().
-type file() :: binary().
-type body() :: binary().
-type result() :: binary().

%% Дешифрование
-spec decrypt(key1(),key2(),file()) -> result().
decrypt(KEY1,KEY2,File) ->
  crypto:aes_cfb_128_decrypt(KEY1,KEY2,File).

%% Шифрование
-spec encrypt(key1(),key2(),body()) -> result().
encrypt(KEY1,KEY2,Body) ->
  crypto:aes_cfb_128_encrypt(KEY1,KEY2,Body).