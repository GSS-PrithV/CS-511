import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
//Prithvinarayan Revuri
//I pledge my honor that I have abided by the Stevens Honor System.
public class Customer implements Runnable {
    private Bakery bakery;
    private Random rnd;
    private List<BreadType> shoppingCart;
    private int shopTime;
    private int checkoutTime;
    private CountDownLatch doneSignal;
    
    /**
     * Initialize a customer object and randomize its shopping cart
     */
    public Customer(Bakery bakery, CountDownLatch l) {
        // TODO
        this.bakery = bakery; 
        this.rnd = new Random(); 
        this.shoppingCart = new ArrayList<BreadType>();
        this.fillShoppingCart(); // fills the shopping cart  
        this.shopTime = rnd.nextInt(100); //generates random time required for shopping and checking out
        this.checkoutTime = rnd.nextInt(100);
        this.doneSignal = l; 
    }

    /**
     * Run tasks for the customer
     */
    public void run() {
        // TODO
        System.out.println("Customer:" + hashCode() + " has entered da building (doomslayer music starts playing).");
        try{
            Thread.sleep(shopTime); //time for customer to shop

            for(BreadType bread : shoppingCart){
                    if(bread == bread.RYE){
                        try{
                            this.bakery.rwhy.acquire();
                        }catch(InterruptedException e){
                            e.printStackTrace();
                        }
                        this.bakery.takeBread(bread);
                        System.out.println("Customer:" + hashCode() + " took " + bread + " from the shelf");
                        this.bakery.rwhy.release();
                    }

                    if(bread == bread.SOURDOUGH){
                        try{
                            this.bakery.sawyer.acquire();
                        }catch(InterruptedException e){
                            e.printStackTrace();
                        }
                        this.bakery.takeBread(bread);
                        System.out.println("Customer:" + hashCode() + " took " + bread + " from the shelf");
                        this.bakery.sawyer.release();
                    }

                    if(bread == bread.WONDER){
                        try{
                            this.bakery.andiwonder.acquire();
                        }catch(InterruptedException e){
                            e.printStackTrace();
                        }
                        this.bakery.takeBread(bread);
                        System.out.println("Customer:" + hashCode() + " took " + bread + " from the shelf");
                        this.bakery.andiwonder.release();
                    }
                }

                this.bakery.register.acquire(); //check out at a cashier 
                System.out.println("Customer:" + hashCode() + " is checking out.");
            
                Thread.sleep(checkoutTime); //sleep for checkout time
                this.bakery.addSales(getItemsValue());
                this.bakery.register.release();
        }catch(Exception e){
            e.printStackTrace();
        }
        System.out.println("Customer:" + hashCode() + " has left da building"); 
        doneSignal.countDown();
    }

    /**
     * Return a string representation of the customer
     */
    public String toString() {
        return "Customer " + hashCode() + ": shoppingCart=" + Arrays.toString(shoppingCart.toArray()) + ", shopTime=" + shopTime + ", checkoutTime=" + checkoutTime;
    }

    /**
     * Add a bread item to the customer's shopping cart
     */
    private boolean addItem(BreadType bread) {
        // do not allow more than 3 items, chooseItems() does not call more than 3 times
        if (shoppingCart.size() >= 3) {
            return false;
        }
        shoppingCart.add(bread);
        return true;
    }

    /**
     * Fill the customer's shopping cart with 1 to 3 random breads
     */
    private void fillShoppingCart() {
        int itemCnt = 1 + rnd.nextInt(3);
        while (itemCnt > 0) {
            addItem(BreadType.values()[rnd.nextInt(BreadType.values().length)]);
            itemCnt--;
        }
    }

    /**
     * Calculate the total value of the items in the customer's shopping cart
     */
    private float getItemsValue() {
        float value = 0;
        for (BreadType bread : shoppingCart) {
            value += bread.getPrice();
        }
        return value;
    }
}
