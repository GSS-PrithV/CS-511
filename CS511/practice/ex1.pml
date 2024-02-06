int n=0;

// proctype P(){
//     int temp=n;
//     n=temp+1;
//     printf("P is %d and n is %d\n", _pid,n)
// }
// proctype Q(){
//     int temp=n;
//     n=temp+1;
//     printf("Q is %d and n is %d\n", _pid,n)
// }

proctype P(){
    int i;
    for(i: 1..10){
        n++;
    };
    finished++
}
proctype Q(){
    int i;
    for(i: 1..10){
        n++;
    };
    finished++
}

init{
    atomic{
        run P();
        run Q();
    };
    finished==2;
    printf("n is %d\n", n)
}