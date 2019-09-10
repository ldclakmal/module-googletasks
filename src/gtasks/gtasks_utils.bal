import ballerina/http;
import ballerina/stringutils;

# Check for HTTP response and if response is success parse HTTP response object into json and parse error otherwise.
#
# + response - Http response or HTTP connector error with network related errors
# + return - Json payload or `error` if anything wrong happen when HTTP client invocation or parsing response to json
function parseResponseToJson(http:Response|error response) returns json|error {
    json result = {};
    if (response is http:Response) {
        var jsonPayload = <@untainted> response.getJsonPayload();
        if (jsonPayload is json) {
            if (response.statusCode != http:STATUS_OK && response.statusCode != http:STATUS_CREATED) {
                error err = error(GTASK_ERROR_CODE, message = response.statusCode.toString() + WHITE_SPACE + response.reasonPhrase + DASH_WITH_WHITE_SPACES_SYMBOL + jsonPayload.toString());
                return err;
            }
            return jsonPayload;
        } else {
            error err = error(GTASK_ERROR_CODE, message = "Error occurred when parsing response to json.");
            return err;
        }
    } else {
        error err = error(GTASK_ERROR_CODE, message = response.detail()?.message.toString());
        return err;
    }
}

# Return the untainted value for the given string if it is valid.
#
# + input - Input string to be validated
# + return - Untainted string or `error` if it is not valid
function getUntaintedStringIfValid(string input) returns @untainted string {
    var matchResponse = stringutils:matches(input, REGEX_STRING);
    if (matchResponse) {
        return input;
    } else {
        error err = error(GTASK_ERROR_CODE, message = "Validation error: Input '" + input + "' should be valid.");
        panic err;
    }
}
