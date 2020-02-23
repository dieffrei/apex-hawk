/**
 * Utility class for common SObject operations
 */
public inherited sharing class SObjectUtil {

    /**
     * Collects all record ids and return a set of them
     *
     * @param records List of records
     *
     * @return set of ids from the given records
     */
    public static Set<Id> puckId(List<SObject> records) {
        return new Map<Id, SObject>(records).keySet();
    }
}
