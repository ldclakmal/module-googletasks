import ballerina/http;

# GTasks error.
#
# + message - A custom message about the error
# + cause - Error object reffered to the occurred error
public type GTasksError record {
    string message;
    error? cause;
};
