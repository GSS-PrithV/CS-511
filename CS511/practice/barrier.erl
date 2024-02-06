-module(barrier).
-complie(export_all).
-complie(nowarn_export_all).

mk_barrier(N) ->
    spawn(?MODULE,coord,[N]).
%% coord(N,M,L)
%% N is the size of the barrier
%% M is the number of threads yet to arrive
%% L is a list of the PIDs of the threads that have already arrived

corrd(N,0,L) -> %%notify all PID in L then reset the barrier N 
    %% lists:foreach(fun (PID) -> PID!{ok} end, L), 
    [PID!{ok}|| PID <- L], %% applies PID! (notify the pid) to every element in L
    corrd(N,N,[]); %%resets N?

coord(N,M,L) ->
    receive
        {PID} ->
            coord(N,M-1,[PID|L]) %% decrements M by 1 and removes PID from the list L
    end.

reached(B)-> 
    B !{self()},
    receive
        {ok}->
            ok
    end.

