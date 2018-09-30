import ballerina/http;

# Check for HTTP response and if response is success parse HTTP response object into json and parse error otherwise.
#
# + response - Http response or HTTP connector error with network related errors
# + return - Json payload or `GTasksError` if anything wrong happen when HTTP client invocation or parsing response to json
function parseResponseToJson(http:Response|error response) returns (json|GTasksError) {
    json result = {};
    match response {
        http:Response httpResponse => {
            var jsonPayload = httpResponse.getJsonPayload();
            match jsonPayload {
                json payload => {
                    if (httpResponse.statusCode != http:OK_200 && httpResponse.statusCode != http:CREATED_201) {
                        GTasksError gtasksError = { message: httpResponse.statusCode + WHITE_SPACE
                            + httpResponse.reasonPhrase + DASH_WITH_WHITE_SPACES_SYMBOL + payload.toString() };
                        return gtasksError;
                    }
                    return payload;
                }
                error err => {
                    GTasksError gtasksError = { message: "Error occurred when parsing response to json." };
                    gtasksError.cause = err.cause;
                    return gtasksError;
                }
            }
        }
        error err => {
            GTasksError gtasksError = { message: err.message };
            gtasksError.cause = err.cause;
            return gtasksError;
        }
    }
}

# Return the untainted value for the given string if it is valid.
#
# + input - Input string to be validated
# + return - Untainted string or `error` if it is not valid
function getUntaintedStringIfValid(string input) returns @untainted string {
    boolean isValid = check input.matches(REGEX_STRING);
    if (isValid) {
        return input;
    } else {
        error err = { message: "Validation error: Input '" + input + "' should be valid." };
        throw err;
    }
}
