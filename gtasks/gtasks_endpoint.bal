import ballerina/http;

# Object for GTasks endpoint.
#
# + gTasksClient - Http client endpoint for api
public type Client client object {

    http:Client gTasksClient;

    public function __init(GTasksConfiguration gTasksConfig) {
        self.init(gTasksConfig);
        self.gTasksClient = new(GTASKS_API_URL, config = gTasksConfig.clientConfig);
    }

    # Initialize GTasks endpoint.
    #
    # + gTasksConfig - GTasks configuraion
    function init(GTasksConfiguration gTasksConfig);

    # Returns all the authenticated user's task lists.
    #
    # + return - If success, returns json with of task list, else returns `error` object
    public remote function listTaskLists() returns json|error;

    # Returns all tasks in the specified task list.
    #
    # + taskList - Name of the task list
    # + return - If success, returns json with details of given task list, else returns `error` object
    public remote function listTasks(string taskList) returns json|error;

    # Updates the specified task.
    #
    # + taskList - Name of the task list
    # + taskId - Name of the task
    # + task - Task to be updated as json
    # + return - If success, returns json  else returns `error` object
    public remote function updateTask(string taskList, string taskId, json task) returns json|error;

    remote function getTaskListId(string taskList) returns string|error;
};

# Object for GTasks configuration.
#
# + clientConfig - The http client endpoint
public type GTasksConfiguration record {
    http:ClientEndpointConfig clientConfig;
};

function Client.init(GTasksConfiguration gTasksConfig) {
    http:AuthConfig? authConfig = gTasksConfig.clientConfig.auth;
    if (authConfig is http:AuthConfig) {
        authConfig.refreshUrl = REFRESH_URL;
    }
}

public remote function Client.listTaskLists() returns json|error {
    http:Client httpClient = self.gTasksClient;
    string requestPath = TASK_LISTS_API;
    var response = httpClient->get(requestPath);
    var jsonResponse = parseResponseToJson(response);
    return jsonResponse;
}

public remote function Client.listTasks(string taskList) returns json|error {
    http:Client httpClient = self.gTasksClient;
    string taskListId = check self->getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS;
    var response = httpClient->get(requestPath);
    return parseResponseToJson(response);
}

public remote function Client.updateTask(string taskList, string taskId, json task) returns json|error {
    http:Client httpClient = self.gTasksClient;
    string taskListId = check self->getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS + taskId;
    http:Request req = new;
    req.setPayload(task);
    var response = httpClient->put(untaint requestPath, req);
    return parseResponseToJson(response);
}

remote function Client.getTaskListId(string taskList) returns string|error {
    json listResponse = check self->listTaskLists();
    json[] taskListArray = <json[]>listResponse.items;
    string taskListId = "";
    foreach json list in taskListArray {
        string listTitle = list.title.toString();
        if (listTitle == taskList) {
            taskListId = list.id.toString();
            break;
        }
    }
    if (taskListId == EMPTY_STRING) {
        map<string> details = { message: "No matching task-list found with given name: " + taskList };
        error err = error(GTASK_ERROR_CODE, details);
        return err;
    }
    return taskListId;
}
