/* Guarantee, using semaphores, that c is printed only after P and Q are done 
    18 Sep 2023
    Exercise
*/

import java.util.concurrent.Semaphore

Semaphore mutex = new Semaphore(1)  // fair or strong
Semaphore donePQ = new Semaphore(??)
c=0

Thread.start { // P
    donePQ .acquire()
    10.times {
	mutex.acquire()
	c++
	mutex.release()
    }
    donePQ.release()
}

Thread.start { // Q
    donePQ.acquire()
    10.times {
	mutex.acquire()
	c++
	mutex.release()
    }
    donePQ.release()
}


println c


