import java.util.concurrent.Semaphore

class counter {
	private volatile c=0
    //final Semaphore mutex = new Semaphore(1)
	Counter() {
		c=0
	}
	synchronized void inc() {
        //mutex.acquire()
		//synchronized (this) {c++} //this synchronizes a block of code instead of the whole method 
        //mutex.release()
        c++
	}
	synchronized int read(){
		Return c
	}
}

C = new counter()
P = Thread.start { //P
	c.inc()
}
Q = Thread.start { //Q
	c.inc()
}

P.join()
Q.join()