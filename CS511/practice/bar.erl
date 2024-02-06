-module(bar).
-compile(export_all).
-compile(nowarn_export_all).

start(P,J) ->
    S=spawn(?MODULE,server,[0,0]),
    [spawn(?MODULE,patriots,[S]) || _ <- lists:seq(1,P)],
    [spawn(?MODULE,jets,[S]) || _ <- lists:seq(1,J)],   
    spawn(?MODULE,itGotLate,[S]).

itGotLate(S) ->
  timer:sleep(1000).
  S!{itGotLate}.


%% S is reference to PID of the server 
patriots(S)-> %%inform patriots that 1 has entered
    S!{patriots}.
jets(S)->  %%wait for ok before jets can come
    S!{self(),jets},
    receive
        {ok}->
            ok
    end.
server(Delta)-> %counter for patriots avaibale for justifying ingress of jets
    receive
        {patriots} -> server(Delta+1); %%increment counter by 1
        {From,jets} when Delta>1-> 
            From!{ok}, %%notifies jets can come 
            server(Delta-2) %% two patriots for 1 jet so reset counter
    end.