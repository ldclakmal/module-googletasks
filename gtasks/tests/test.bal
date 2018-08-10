import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerina/config;
import ballerina/http;

endpoint Client gtasksClient {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            accessToken: config:getAsString("ACCESS_TOKEN"),
            clientId: config:getAsString("CLIENT_ID"),
            clientSecret: config:getAsString("CLIENT_SECRET"),
            refreshToken: config:getAsString("REFRESH_TOKEN"),
            refreshUrl: config:getAsString("REFRESH_URL")
        }
    }
};

@test:Config
function testListTaskLists() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gtasksClient -> listTaskLists()");

    var details = gtasksClient->listTaskLists();
    match details {
        json response => io:println(response);
        GTasksError gtasksError => test:assertFail(msg = gtasksError.message);
    }
}

@test:Config {
    dependsOn: ["testListTaskLists"]
}
function testListTasks() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gtasksClient -> listTasks()");

    var details = gtasksClient->listTasks("BallerinaDay");
    match details {
        json response => io:println(response);
        GTasksError gtasksError => test:assertFail(msg = gtasksError.message);
    }
}
