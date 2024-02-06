-module(bar).
-compile(export_all).
-compile(nowarn_export_all).

start(P,J) ->
    S=spawn(?MODULE,server,[0,0,false]),
    [spawn(?MODULE,patriots,[S]) || _ <- lists:seq(1,P)],
    [spawn(?MODULE,jets,[S]) || _ <- lists:seq(1,J)],
    spawn(?MODULE,timer,[S]).

timer(S) ->
    timer:sleep(1000),
    S!{itGotLate}.

patriots(S) ->  % Reference to PID of server
    S!{patriots}.

jets(S) ->   % Reference to PID of server
    S!{self(),jets},
    receive
	{ok} ->
	    ok
    end.

flush_and_notify() ->
    receive
	{From,jets} ->
	    From!{ok},
	    flush_and_notify()
    after 0 ->
	    ok
    end.

server(Delta,false) -> % Counters for Patriots available for justifying ingress of Jets
    receive
	{patriots} ->
	    server(Delta+1,false);
	{From,jets} when Delta>1 ->
	    From!{ok},
	    server(Delta-2,false);
	{itGotLate} ->
	    flush_and_notify(), %% flush and notify all waiting jets fans
	    server(Delta,true)  %% transition server to new state
    end;
server(_Delta,true) ->
    receive
    	{patriots} ->
	    server(_Delta,true);
	{From,jets} ->
	    From!{ok},
	    server(_Delta,true)
    end.


    
