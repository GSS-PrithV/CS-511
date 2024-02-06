public class Swapper implements Runnable {
    private int offset;
    private Interval interval;
    private String content;
    private char[] buffer;

    public Swapper(Interval interval, String content, char[] buffer, int offset) {
        this.offset = offset;
        this.interval = interval;
        this.content = content;
        this.buffer = buffer;
    }

    @Override
    public void run() {
        // TODO: Implement me!
        String balls = content.substring(interval.getX(), interval.getY()+1);
        balls.toCharArray();
        for(int i = 0; i < balls.length(); i ++){
            buffer[offset+i] = balls.charAt(i);
        }
    }
}