public interface ILogger {
    void debug(String message);
    void debug(String message, List<Object> values);
    void debug(String message, Id contextId);
    void debug(Id contextId);
    void debug(String message, List<Object> values, Id contextId);
    void error(String message);
    void error(String message, List<Object> values);
    void error(String message, Id contextId);
    void error(Id contextId);
    void error(String message, List<Object> values, Id contextId);
}
