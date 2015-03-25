-module(files_dao).
-export([write/1, delete/1, update/2]).
-export([find/1, find_all/0]).

-include("privfile.hrl").

write(DataTuple) -> mnesia_dao:write(DataTuple).
delete(Key)  -> mnesia_dao:delete(Key, ?files_tab).
update(Key, DataTuple) -> mnesia_dao:update(Key, ?files_tab, DataTuple).
find_all() -> mnesia_dao:find_all(?files_tab).
find(Key) -> mnesia_dao:find(?files_tab, Key).