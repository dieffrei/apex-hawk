public inherited sharing class Logger implements ILogger {

    public class Location {
        public String className;
        public String methodName;
        public Integer lineNumber;

        public Location() {
        }

        public Location(String className, String methodName, Integer lineNumber) {
            this.className = className;
            this.methodName = methodName;
            this.lineNumber = lineNumber;
        }
    }

    private final Boolean LOG_VIA_EVENTS;
    private final String ORG_NAMESPACE;
    private final String CLASSNAME;
    private final Pattern STACK_LINE;
    private final String THIS_CONTEXT;

    public Logger() {
        LOG_VIA_EVENTS = logViaEvents();
        ORG_NAMESPACE = [SELECT NamespacePrefix FROM Organization].NamespacePrefix;
        CLASSNAME = Logger.class.getName();
        STACK_LINE = Pattern.compile('^(?:Class\\.)?([^.]+)\\.?([^\\.\\:]+)?[\\.\\:]?([^\\.\\:]*): line (\\d+), column (\\d+)$');
        THIS_CONTEXT = timestamp();
    }

    public void debug(String message) {
        debug(message, new List<Object>(), null);
    }

    public void debug(String message, List<Object> values) {
        debug(message, values, null);
    }

    public void debug(String message, Id contextId) {
        debug(message, new List<Object>(), contextId);
    }

    public void debug(Id contextId) {
        debug('', new List<Object>(), contextId);
    }

    public void debug(String message, List<Object> values, Id contextId) {
        emit(message, values, contextId, LoggingLevel.DEBUG);
    }

    public void error(String message) {
        error(message, new List<Object>(), null);
    }

    public void error(String message, List<Object> values) {
        error(message, values, null);
    }

    public void error(String message, Id contextId) {
        error(message, new List<Object>(), contextId);
    }

    public void error(Id contextId) {
        error('', new List<Object>(), contextId);
    }

    public void error(String message, List<Object> values, Id contextId) {
        emit(message, values, contextId, LoggingLevel.ERROR);
    }

    private void emit(String message, List<Object> values, Id contextId, LoggingLevel level) {
        message = String.format(message, values);
        Location location = getClassLocation();

        if (LOG_VIA_EVENTS) {
            currentEvent = new Log__e();
            currentEvent.User__c = UserInfo.getUserId();
            currentEvent.Message__c = message;
            currentEvent.Level__c = level.name();
            currentEvent.Context__c = (contextId == null) ? THIS_CONTEXT : '' + contextId;

            if (location != null) {
                currentEvent.ClassName__c = location.className;
                currentEvent.Method__c = location.methodName;
                currentEvent.LineNumber__c = location.lineNumber;
            }

            EventBus.publish(currentEvent);
        } else {
            System.debug(String.format('{0}.{1}: {2}', new List<String>{
                location.className,
                location.methodName,
                message != null ? message : ''
            }));
        }
    }

    public String timestamp() {
        return System.now().formatGmt('HH:mm:ss.SSS');
    }

    private Location getClassLocation() {

        Location location = new Location();

        // Note: Idea taken from https://salesforce.stackexchange.com/questions/153835
        List<String> stacktrace = new DmlException().getStackTraceString().split('\n');

        for (String line : stacktrace) {
            Matcher matcher = STACK_LINE.matcher(line);

            if (matcher.find() && !line.startsWith('Class.' + CLASSNAME + '.')) {
                Boolean hasNamespace = String.isNotBlank(matcher.group(3));

                if (hasNamespace) {
                    location.className = (matcher.group(1).equals(ORG_NAMESPACE)) ? matcher.group(2) : matcher.group(1) + '.' + matcher.group(2);
                    location.methodName = prettyMethod(matcher.group(3));
                } else {
                    location.className = matcher.group(1);
                    location.methodName = prettyMethod(matcher.group(2));
                }

                location.lineNumber = Integer.valueOf(matcher.group(4));

            }
        }

        return location;
    }


    private String prettyMethod(String method) {
        String result = (method == null) ? 'anonymous' : method;
        return (result.contains('init')) ? 'ctor' : result;
    }

    private Boolean logViaEvents() {
        LoggerSetting__c settings = LoggerSetting__c.getValues(UserInfo.getUserId());
        return (settings == null) ? false : (System.today() == settings.dat_LogViaEvents__c);
    }

    // Note: Required to allow testing
    @TestVisible
    private Log__e currentEvent = null;
}
