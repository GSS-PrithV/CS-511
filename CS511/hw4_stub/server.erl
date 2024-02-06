-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

%% executes join protocol from server perspective
do_join(ChatName, ClientPID, Ref, State) ->
	case lists:member(ChatName, maps:keys(State#serv_st.chatrooms)) of
		true ->
			ChatRoomPID = maps:get(ChatName, State#serv_st.chatrooms),
			ClientNick = maps:get(ClientPID, State#serv_st.nicks),
			ChatRoomPID!{self(), Ref, register, ClientPID, ClientNick},
			Oldroom = maps:get(ChatName, State#serv_st.registrations),
			Newroom = maps:update(ChatName,lists:append([ClientPID], Oldroom), State#serv_st.registrations),
			#serv_st{nicks = State#serv_st.nicks, registrations = Newroom, chatrooms = State#serv_st.chatrooms};
		false ->
			NRoom = spawn(chatroom, start_chatroom, [ChatName]),
			RoomList = maps:put(ChatName, NRoom, State#serv_st.chatrooms),
			NewReg = maps:put(ChatName, [ClientPID], State#serv_st.registrations),
			ClientNick = maps:get(ClientPID, State#serv_st.nicks),
			ChatRoomPID = maps:get(ChatName, RoomList),
			ChatRoomPID!{self(), Ref, register, ClientPID, ClientNick},
			#serv_st{nicks = State#serv_st.nicks, registrations = NewReg, chatrooms = RoomList}
	end.

%% executes leave protocol from server perspective
do_leave(ChatName, ClientPID, Ref, State) ->
    ChatPID = maps:get(ChatName, State#serv_st.chatrooms),
	OldR = maps:get(ChatName, State#serv_st.registrations),
	NewR = maps:update(ChatName, OldR -- [ClientPID], State#serv_st.registrations),
	ChatPID!{self(), Ref, unregister, ClientPID},
	ClientPID!{self(), Ref, ack_leave},
	#serv_st{nicks = State#serv_st.nicks, registrations = NewR, chatrooms = State#serv_st.chatrooms}.

%% executes new nickname protocol from server perspective
do_new_nick(State, Ref, ClientPID, NewNick) ->
    case lists:member(NewNick, maps:values(State#serv_st.nicks)) of 
		true ->
			ClientPID!{self(), Ref, err_nick_used},
			State;
		false ->
			NewNames = maps:update(ClientPID, NewNick, State#serv_st.nicks),
			ChatrOOms = maps:keys(maps:filter(fun(_ChatName, PIDs) -> lists:member(ClientPID, PIDs) end, State#serv_st.registrations)),
			ChatroomPIDs = maps:filter(fun(ChatName, _ChatPID) ->  lists:member(ChatName, ChatrOOms) end, State#serv_st.chatrooms),
			maps:map(fun(_Name, ChatPID) -> ChatPID!{self(), Ref, update_nick, ClientPID, NewNick} end, ChatroomPIDs),
			ClientPID!{self(), Ref, ok_nick},
			#serv_st {nicks = NewNames, registrations =  State#serv_st.registrations, chatrooms = State#serv_st.chatrooms}
	end.
%% executes client quit protocol from server perspective
do_client_quit(State, Ref, ClientPID) ->
	NMap = maps:remove(ClientPID, State#serv_st.nicks),
    lists:foreach(
         fun(Key) ->
            case lists:member([ClientPID], maps:values(State#serv_st.registrations)) of
              true ->
                ChatPid = maps:get(Key, State#serv_st.chatrooms), 
                do_leave(ChatPid, ClientPID, Ref,State);
              false -> pass
            end 
            end, maps:keys(State#serv_st.registrations)),
        ClientPID!{self(), Ref, ack_quit},
        State#serv_st{nicks = NMap,chatrooms = State#serv_st.chatrooms}.
