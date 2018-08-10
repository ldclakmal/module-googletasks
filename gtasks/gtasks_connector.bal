import ballerina/http;
import ballerina/mime;

documentation {
    Object to initialize the connection with Google Tasks.

    F{{accessToken}} Access token of the account
    F{{client}} Http client endpoint for api
}
public type GTasksConnector object {

    public string accessToken;
    public http:Client client;

    documentation {
        Returns all the authenticated user's task lists.

        R{{}} If success, returns json with of task list, else returns `GTasksError` object
    }
    public function listTaskLists() returns (json|GTasksError);
    //public function getTaskList(string taskList) returns (json|GTasksError);
    //public function insertTaskList(string taskList) returns (json|GTasksError);
    //public function updateTaskList(string taskList) returns (json|GTasksError);
    //public function deleteTaskList(string taskList) returns (json|GTasksError);

    documentation {
        Returns all tasks in the specified task list.

        P{{taskList}} Name of the task list
        R{{}} If success, returns json with  object with basic details, else returns `GTasksError` object
    }
    public function listTasks(string taskList) returns (json|GTasksError);
    //public function getTask(string taskList, string task) returns (json|GTasksError);
    //public function insertTask(string taskList) returns (json|GTasksError);
    //public function updateTask(string taskList, string task) returns (json|GTasksError);
    //public function deleteTask(string taskList, string task) returns (json|GTasksError);
    //public function clearTasks(string taskList) returns (json|GTasksError);
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
    string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS;
    var response = httpClient->get(requestPath);
    json jsonResponse = check parseResponseToJson(response);
    return jsonResponse;
}
