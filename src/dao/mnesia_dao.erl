-module(mnesia_dao).
-export([write/1, delete/2, update/3]).
-export([find_all/1, find_by_uuid/2]).
-export([find/2]).

write(GroupsTuple) ->
  mnesia:transaction(fun() -> mnesia:write(GroupsTuple) end).

delete(Key, Table) ->
  mnesia:transaction(fun() -> mnesia:delete({Table, Key}) end).

update(Key, Table, DataTuple) ->
  mnesia:transaction(fun() ->
    mnesia:delete({Table, Key}),
    mnesia:write(DataTuple)
  end).

find_all(Table) ->
  {atomic, List} = mnesia:transaction(fun() -> mnesia:select(Table, [{'_',[],['$_']}]) end),
  List.

find_by_uuid(Uuid, Table) ->
  find(Table, Uuid).

find(Table, Key) ->
  case mnesia:transaction(fun() -> mnesia:read(Table, Key) end) of
    {atomic, [Res]} -> Res;
    {atomic, []} -> []
  end.