-module(pc).
-compile(export_all).
-compile(nowarn_export_all).

start(N,P,C) ->
    B = spawn(?MODULE,buffer,[N,0,0,0]),
    [ spawn(?MODULE,producer,[B]) || _ <- lists:seq(1,P)],
    [ spawn(?MODULE,consumer,[B]) || _ <- lists:seq(1,C)].
    

%% buffer(N,Oc,PSP,CSC)
%% N: size of the buffer
%% Oc: number of occupied slots
%% PSP: number of producers that started producing
%% CSC: number of consumers that started consuming

buffer(N,Oc,PSP,CSC) ->
   receive
       {From,start_producing} when Oc+PSP<N ->
	   From!{ok},
	   buffer(N,Oc,PSP+1,CSC);
       {stop_producing} ->
	   buffer(N,Oc+1,PSP-1,CSC);
       {From,start_consuming} when Oc-CSC>0 ->
	   From!{ok},
	   buffer(N,Oc,PSP,CSC+1);
       {stop_consuming} ->
	   buffer(N,Oc-1,PSP,CSC-1)
    end.

producer(B) ->
    B!{self(),start_producing},
    receive
	{ok} ->
	    ok
    end,
    %% produce
    B!{stop_producing}.


cosumer(B) ->
    B!{self(),start_consuming},
    receive
	{ok} ->
	    ok
    end,
    %% produce
    B!{stop_consuming}.
