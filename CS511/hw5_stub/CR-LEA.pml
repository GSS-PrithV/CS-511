//Prithvinarayan Revuri, Dev Patel
//I pledge my honor that I have abided by the Stevens Honor System 

# define N	5	/* number of processes in the ring */
# define L	10	/* size of buffer (>= 2*N) */
byte I; 		/* will be used in init for assigning ids to nodes */

mtype = {one, winner};	
chan q[N] = [L] of {mtype, byte}; 

proctype nnode (chan inp, out; byte mynumber) {
	byte nr;

	xr inp;	
	xs out;	

	printf ("\nMSC : %d", mynumber );
	out! one, mynumber;

	end:	do
	:: inp?one(nr) ->
		if
		:: nr == mynumber ->
			out!winner(inp);
			printf("\nMSC: LEADER", inp);
			break;
		:: nr > mynumber->
			out!one(nr);

		:: nr < mynumber ->
			skip;
		fi
	:: inp?winner,nr ->
		if
		:: nr != inp ->
			printf("\nMSC: This is Node %d confirming Node %d is the leader", inp, nr)
			out!winner(nr);


		:: else ->
			printf("\nMSC: This is Node %d and I am the leader", mynumber);
			skip;
		fi;
		break;
	od
}


init {
    byte proc;
    byte Ini[6];

    atomic {
        I = 1;
        do
        :: I <= N ->
                if
                :: Ini[0] == 0 && N >= 1 -> Ini[0] = I
                :: Ini[1] == 0 && N >= 2 -> Ini[1] = I
                :: Ini[2] == 0 && N >= 3 -> Ini[2] = I
                :: Ini[3] == 0 && N >= 4 -> Ini[3] = I
                :: Ini[4] == 0 && N >= 5 -> Ini[4] = I
                :: Ini[5] == 0 && N >= 6 -> Ini[5] = I
                fi;
                I++
        :: I > N ->
                break 
        od;

        proc = 1;
        do
        :: proc <= N ->
                run nnode (q[proc-1], q[proc%N], Ini[proc-1]);
                proc++
        :: proc > N ->
            break
        od        
    }
}