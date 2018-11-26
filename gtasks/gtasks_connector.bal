import ballerina/http;

# Object to initialize the connection with Google Tasks.
#
# + gTasksClient - Http client endpoint for api
public type GTasksConnector client object {

    public http:Client gTasksClient;

    public function __init(string url, http:ClientEndpointConfig config) {
        self.gTasksClient = new(url, config = config);
    }

    remote function listTaskLists() returns json|error;

    remote function listTasks(string taskList) returns json|error;

    remote function updateTask(string taskList, string taskId, json task) returns json|error;

    // This function is for internal usage in order to get the id of the given task list.
    function getTaskListId(string taskList) returns string|error;
};

remote function GTasksConnector.listTaskLists() returns json|error {
    http:Client httpClient = self.gTasksClient;
    string requestPath = TASK_LISTS_API;
    var response = httpClient->get(requestPath);
    var jsonResponse = parseResponseToJson(response);
    return jsonResponse;
}

remote function GTasksConnector.listTasks(string taskList) returns json|error {
    http:Client httpClient = self.gTasksClient;
    var taskListIdResult = self.getTaskListId(taskList);
    if (taskListIdResult is string) {
        string requestPath = TASKS_API + getUntaintedStringIfValid(taskListIdResult) + TASKS_API_TASKS;
        var response = httpClient->get(requestPath);
        return parseResponseToJson(response);
    } else {
        return taskListIdResult;
    }
}

remote function GTasksConnector.updateTask(string taskList, string taskId, json task) returns json|error {
    http:Client httpClient = self.gTasksClient;
    var taskListIdResult = self.getTaskListId(taskList);
    if (taskListIdResult is string) {
        string requestPath = TASKS_API + getUntaintedStringIfValid(taskListIdResult) + TASKS_API_TASKS + taskId;
        http:Request req = new;
        req.setPayload(task);
        var response = httpClient->put(untaint requestPath, req);
        return parseResponseToJson(response);
    } else {
        return taskListIdResult;
    }
}

function GTasksConnector.getTaskListId(string taskList) returns string|error {
    var listResponse = self->listTaskLists();
    if (listResponse is json) {
        var taskListArray = <json[]>listResponse.items;
        if (taskListArray is error) {
            return taskListArray;
        } else {
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
    } else {
        return listResponse;
    }
}