global class UpdateAccountScheduler implements Schedulable{
    public static String scheduledTime = '0 00 00 * * ?';  //Every Day at Midnight 

    global static String scheduleBatch() {
        UpdateAccountScheduler scheduler = new UpdateAccountScheduler(); 
        return System.schedule('UpdateAccountBatchScheduler', scheduledTime, scheduler);
    }

    global void execute(SchedulableContext context) {

        UpdateAccountStatus updateBatch = new UpdateAccountStatus();
        ID batch_id = Database.executeBatch(updateBatch,100);           
    }
}