-module(barrier_client).
-compile(export_all).
-compile(nowarn_export_all).

%% client code

start() ->
    B = barrier:mk_barrier(3),
    spawn(?MODULE,client,[B,"a\n","1\n"]),
    spawn(?MODULE,client,[B,"b\n","2\n"]),
    spawn(?MODULE,client,[B,"c\n","3\n"]).

client(B,BeforeStr,AfterStr) ->
    io:format(BeforeStr),
    barrier:reached(B),
    io:format(AfterStr).
