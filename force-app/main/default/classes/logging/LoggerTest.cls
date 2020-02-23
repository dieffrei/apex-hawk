@IsTest
private class LoggerTest {

	@IsTest
	private static void debug() {
		// Setup
		enableLogEvents(System.today());

		Id contextId = 'a2R1T0000034dUTUAY';
		String message = '{0}=={1}:{2}';
		List<Object> values = new List<Object>{ 1, '2', false };

        Logger logger = new Logger();

		// Execute
        logger.debug(message, values, contextId);

		// Verify
		Log__e log = logger.currentEvent;

		System.assertEquals('1==2:false', log.Message__c);
		System.assertEquals(LoggingLevel.DEBUG.name(), log.Level__c);
		System.assertEquals(contextId, log.Context__c);
		System.assertEquals(thisClassName(), log.ClassName__c);
		System.assertEquals('debug', log.Method__c);
		System.assertEquals(16, log.LineNumber__c);
	}


	@IsTest
	private static void error() {
		// Setup
        enableLogEvents(System.today());

        Logger logger = new Logger();

		// Execute
        logger.error('');

        System.debug('logger.currentEvent: ' + logger.currentEvent);

		// Verify
		System.assertEquals(LoggingLevel.ERROR.name(), logger.currentEvent.Level__c);
	}


	@IsTest
	private static void timestampWhenNoContextId() {
		// Setup
        enableLogEvents(System.today());
        Logger logger = new Logger();

		// Execute
        logger.debug('');

		// Verify
		System.assertNotEquals(null, logger.currentEvent.Context__c);
	}

	@IsTest
	private static void noEventsSendWhenDisabled() {
		// Execute
        Logger logger = new Logger();
        logger.debug('');

		// Verify
		System.assertEquals(null, logger.currentEvent);
	}

	@IsTest
	private static void noEventsWhenExpired() {
		// Setup
        enableLogEvents(yesterDay());
        Logger logger = new Logger();

		// Execute
        logger.debug('');

		// Verify
		System.assertEquals(null, logger.currentEvent);
	}

	private static void enableLogEvents(Date day) {
		insert new LoggerSetting__c(SetupOwnerId = UserInfo.getUserId(), dat_LogViaEvents__c = day);
	}


	private static Date yesterDay() {
		return System.today().addDays(-1);
	}

	private static String thisClassName() {
		String ns = [SELECT NamespacePrefix FROM Organization].NamespacePrefix + '.';
		return LoggerTest.class.getName().removeStart(ns);
	}
}
