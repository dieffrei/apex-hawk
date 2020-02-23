/**
 *  Common interface for batches/scheduled classes
 */
@NamespaceAccessible
public interface IBatchable {

    /**
     * @return Batch Size
     */
    Integer getBatchSize();

    /**
     * @return category of job
     */
    String getCategory();

    /**
     * @return description of job
     */
    String getDescription();

    /**
     *  Schedule job to be executed
     * @return Job Id
     */
    String schedule();

    /**
     *  Stops and cancel all the jobs and scheduled jobs
     */
    void cancel();

    /**
     * Run batchs
     * @return Job Id
     */
    String execute();
}
