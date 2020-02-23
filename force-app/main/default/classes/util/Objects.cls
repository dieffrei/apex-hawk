/**
 * TODO: refactor
 */
public inherited sharing class Objects {

    public static void assertIsNotNull(String parameterName, Object value) {
        if (value == null) {
            throw new InvalidArgumentException(parameterName, String.valueOf(value));
        }
    }

    public static void assertIsNotEmpty(String parameterName, String value) {
        if (String.isEmpty(value)) {
            throw new InvalidArgumentException(parameterName, value);
        }
    }

}
