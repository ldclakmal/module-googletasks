import ballerina/io;
import ballerina/log;
import ballerina/test;
import ballerina/config;

GTasksConfiguration gTasksConfig = {
    accessToken: config:getAsString("ACCESS_TOKEN"),
    clientId: config:getAsString("CLIENT_ID"),
    clientSecret: config:getAsString("CLIENT_SECRET"),
    refreshToken: config:getAsString("REFRESH_TOKEN")
};

Client gTasksClient = new(gTasksConfig);

@test:Config{}
function testListTaskLists() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gTasksClient -> listTaskLists()");

    var response = gTasksClient->listTaskLists();
    if (response is json) {
        io:println(response);
    } else {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}

@test:Config {
    dependsOn: ["testListTaskLists"]
}
function testListTasks() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gTasksClient -> listTasks()");

    var response = gTasksClient->listTasks("Ballerina Day");
    if (response is json) {
        io:println(response);
    } else {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}

@test:Config {
    dependsOn: ["testListTasks"]
}
function testUpdateTasks() {
    io:println("\n ---------------------------------------------------------------------------");
    log:printInfo("gTasksClient -> testUpdateTasks()");

    json task = {
        "kind": "tasks#task",
        "id": "MTU1MjQzOTg1MzM3OTk0MTU2MzQ6MjMxMjc4NDQ3NDA5Mjk3NTo2MTE2OTU3ODQwMzAxNzE4",
        "etag": "\"84_7Cubo3y98GMV9bE3zQclHxhc/LTIwNDgyMDMwNTk\"",
        "title": "[⏰] Lunch @ 2:00PM",
        "updated": "2019-03-18T05:28:44.000Z",
        "selfLink": "https://www.googleapis.com/tasks/v1/lists/MTU1MjQzOTg1MzM3OTk0MTU2MzQ6MjMxMjc4NDQ3NDA5Mjk3NTow/tasks/MTU1MjQzOTg1MzM3OTk0MTU2MzQ6MjMxMjc4NDQ3NDA5Mjk3NTo2MTE2OTU3ODQwMzAxNzE4",
        "position": "00000000001610612734",
        "status": "needsAction"
    };

    var response = gTasksClient->updateTask("Ballerina Day",
        "MTU1MjQzOTg1MzM3OTk0MTU2MzQ6MjMxMjc4NDQ3NDA5Mjk3NTo2MTE2OTU3ODQwMzAxNzE4", task);
    if (response is json) {
        io:println(response);
    } else {
        test:assertFail(msg = response.detail()?.message.toString());
    }
}
