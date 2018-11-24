import ballerina/http;
import ballerina/mime;

# Object to initialize the connection with Google Tasks.
#
# + accessToken - Access token of the account
# + client - Http client endpoint for api
public type GTasksConnector client object {

    public http:Client gtaskClient;

    public function __init(http:ClientEndpointConfig config) {
        self.gtaskClient = new(config);
    }

    # Returns all the authenticated user's task lists.
    #
    # + return - If success, returns json with of task list, else returns `GTasksError` object
    remote function listTaskLists() returns json|error;

    # Returns all tasks in the specified task list.
    #
    # + taskList - Name of the task list
    # + return - If success, returns json with details of given task list, else returns `GTasksError` object
    remote function listTasks(string taskList) returns json|error;

    # Updates the specified task.
    #
    # + taskList - Name of the task list
    # + taskId - Name of the task
    # + task - Task to be updated as json
    # + return - If success, returns json  else returns `GTasksError` object
    remote function updateTask(string taskList, string taskId, json task) returns json|error;

    // This function is for internal usage in order to get the id of the given task list.
    function getTaskListId(string taskList) returns string|error;
};

remote function GTasksConnector.listTaskLists() returns json|error {
    http:Client httpClient = self.gtaskClient;
    string requestPath = TASK_LISTS_API;
    var response = httpClient->get(requestPath);
    var jsonResponse = parseResponseToJson(response);
    return jsonResponse;
}

remote function GTasksConnector.listTasks(string taskList) returns json|error {
    http:Client httpClient = self.gtaskClient;
    string taskListId = check self.getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS;
    var response = httpClient->get(requestPath);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}

remote function GTasksConnector.updateTask(string taskList, string taskId, json task) returns json|error {
    http:Client httpClient = self.gtaskClient;
    string taskListId = check self.getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS + taskId;
    http:Request req = new;
    req.setPayload(task);
    var response = httpClient->put(requestPath, req);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}

function GTasksConnector.getTaskListId(string taskList) returns string|error {
    json listResponse = check self->listTaskLists();
    json[] taskListArray = check <json[]>listResponse.items;
    string taskListId = "";
    foreach list in taskListArray {
        string listTitle = list.title.toString();
        if (listTitle == taskList) {
            taskListId = list.id.toString();
            break;
        }
    }
    if (taskListId == EMPTY_STRING) {
        map details = { message: "No matching task-list found with given name: " + taskList };
        error err = error(GTASK_ERROR_CODE, details);
        return err;
    }
    return taskListId;
}