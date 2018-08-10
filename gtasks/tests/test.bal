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

@test:Config {
    dependsOn: ["testListTasks"]
}
function testUpdateTasks() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gtasksClient -> testUpdateTasks()");

    json task = {
        "kind": "tasks#task",
        "id": "MDQ4NzI4NjE3OTU0OTE0OTgwNTg6Mzg5Nzc4MDI4OTUyNzI2NDo5ODQ5ODA3NzAwODk5ODA1",
        "etag": "\"FhCqMAsBrrKDkDLKevwtJykQ9I8/LTY2NDI3MjAyNQ\"",
        "title": "[SCHEDULED] Lunch @ 1:00PM",
        "updated": "2018-08-10T06:11:36.000Z",
        "selfLink":
        "https://www.googleapis.com/tasks/v1/lists/MDQ4NzI4NjE3OTU0OTE0OTgwNTg6Mzg5Nzc4MDI4OTUyNzI2NDow/tasks/MDQ4NzI4NjE3OTU0OTE0OTgwNTg6Mzg5Nzc4MDI4OTUyNzI2NDo5ODQ5ODA3NzAwODk5ODA1",
        "position": "00000000000975315488",
        "status": "needsAction"
    };

    var details = gtasksClient->updateTask("BallerinaDay",
        "MDQ4NzI4NjE3OTU0OTE0OTgwNTg6Mzg5Nzc4MDI4OTUyNzI2NDo5ODQ5ODA3NzAwODk5ODA1", task);
    match details {
        json response => io:println(response);
        GTasksError gtasksError => test:assertFail(msg = gtasksError.message);
    }
}
