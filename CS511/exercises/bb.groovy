class BB{
    Integer buff
    BB() {
        buffer=null
    }
    synchronized void produce(Integer p){
        while(buffer!=null){
            wait()
        }
        buffer=p
        notifyAll()
    }
    synchronized void consumer()) {
        while(buffer==null){
            wait()
        }
        temp=buffer
        buffer = null
        notifyAll()
        return temp
    }
}

BB bb = new BB()

10.times {
    Thread.start{

    }
}
