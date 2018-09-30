import ballerina/http;
import ballerina/mime;

# Object to initialize the connection with Google Tasks.
#
# + accessToken - Access token of the account
# + client - Http client endpoint for api
public type GTasksConnector object {

    public string accessToken;
    public http:Client client;

    # Returns all the authenticated user's task lists.
    #
    # + return - If success, returns json with of task list, else returns `GTasksError` object
    public function listTaskLists() returns (json|GTasksError);

    # Returns all tasks in the specified task list.
    #
    # + taskList - Name of the task list
    # + return - If success, returns json with details of given task list, else returns `GTasksError` object
    public function listTasks(string taskList) returns (json|GTasksError);


    # Updates the specified task.
    #
    # + taskList - Name of the task list
    # + taskId - Name of the task
    # + task - Task to be updated as json
    # + return - If success, returns json  else returns `GTasksError` object
    public function updateTask(string taskList, string taskId, json task) returns (json|GTasksError);

    //public function getTaskList(string taskList) returns (json|GTasksError);
    //public function insertTaskList(string taskList) returns (json|GTasksError);
    //public function updateTaskList(string taskList) returns (json|GTasksError);
    //public function deleteTaskList(string taskList) returns (json|GTasksError);
    //public function getTask(string taskList, string task) returns (json|GTasksError);
    //public function insertTask(string taskList) returns (json|GTasksError);
    //public function deleteTask(string taskList, string task) returns (json|GTasksError);
    //public function clearTasks(string taskList) returns (json|GTasksError);

    // This function is for internal usage in order to get the id of the given task list.
    function getTaskListId(string taskList) returns (string|GTasksError);
};

function GTasksConnector::listTaskLists() returns (json|GTasksError) {
    endpoint http:Client httpClient = self.client;
    string requestPath = TASK_LISTS_API;
    var response = httpClient->get(requestPath);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}

function GTasksConnector::listTasks(string taskList) returns (json|GTasksError) {
    endpoint http:Client httpClient = self.client;
    string taskListId = check self.getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS;
    var response = httpClient->get(requestPath);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}

function GTasksConnector::updateTask(string taskList, string taskId, json task) returns (json|GTasksError) {
    endpoint http:Client httpClient = self.client;
    string taskListId = check self.getTaskListId(taskList);
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS + taskId;
    http:Request req = new;
    req.setPayload(task);
    var response = httpClient->put(requestPath, req);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}

function GTasksConnector::getTaskListId(string taskList) returns (string|GTasksError) {
    json listResponse = check self.listTaskLists();
    json[] taskListArray = check <json[]>listResponse.items;
    string taskListId;
    foreach list in taskListArray {
        string listTitle = list.title.toString();
        if (listTitle == taskList) {
            taskListId = list.id.toString();
            break;
        }
    }
    if (taskListId == EMPTY_STRING) {
        GTasksError gtasksError = { message: "No matching task-list found with given name: " + taskList };
        return gtasksError;
    }
    return taskListId;
}