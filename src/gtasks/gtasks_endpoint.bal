import ballerina/http;
import ballerina/oauth2;

# Object for GTasks endpoint.
#
# + gTasksClient - Http client endpoint for api
public type Client client object {

    http:Client gTasksClient;

    public function __init(GTasksConfiguration gTasksConfig) {
        oauth2:OutboundOAuth2Provider oauth2Provider = new({
            accessToken: gTasksConfig?.accessToken ?: EMPTY_STRING,
            refreshConfig: {
                clientId: gTasksConfig.clientId,
                clientSecret: gTasksConfig.clientSecret,
                refreshToken: gTasksConfig.refreshToken,
                refreshUrl: REFRESH_URL
            }
        });
        http:BearerAuthHandler oauth2Handler = new(oauth2Provider);
        self.gTasksClient = new(GTASKS_API_URL, {
            auth: {
                authHandler: oauth2Handler
            }
        });
    }

    # Returns all the authenticated user's task lists.
    #
    # + return - If success, returns json with of task list, else returns `error` object
    public remote function listTaskLists() returns json|error {
        http:Client httpClient = self.gTasksClient;
        string requestPath = TASK_LISTS_API;
        var response = httpClient->get(requestPath);
        var jsonResponse = parseResponseToJson(response);
        return jsonResponse;
    }

    # Returns all tasks in the specified task list.
    #
    # + taskList - Name of the task list
    # + return - If success, returns json with details of given task list, else returns `error` object
    public remote function listTasks(string taskList) returns json|error {
        http:Client httpClient = self.gTasksClient;
        string taskListId = check self->getTaskListId(taskList);
        string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS;
        var response = httpClient->get(requestPath);
        return parseResponseToJson(response);
    }

    # Updates the specified task.
    #
    # + taskList - Name of the task list
    # + taskId - Name of the task
    # + task - Task to be updated as json
    # + return - If success, returns json  else returns `error` object
    public remote function updateTask(string taskList, string taskId, json task) returns json|error {
        http:Client httpClient = self.gTasksClient;
        string taskListId = check self->getTaskListId(taskList);
        string requestPath = TASKS_API + getUntaintedStringIfValid(taskListId) + TASKS_API_TASKS + taskId;
        http:Request req = new;
        req.setPayload(task);
        var response = httpClient->put(<@untainted> requestPath, req);
        return parseResponseToJson(response);
    }

    remote function getTaskListId(string taskList) returns string|error {
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
            error err = error(GTASK_ERROR_CODE, message = "No matching task-list found with given name: " + taskList);
            return err;
        }
        return taskListId;
    }
};

# Object for GTasks configuration.
#
# + accessToken - The OAuth2 access token
# + clientId - The OAuth2 client id
# + clientSecret - The OAuth2 client secret
# + refreshToken - The OAuth2 refresh token
public type GTasksConfiguration record {
    string accessToken?;
    string clientId;
    string clientSecret;
    string refreshToken;
};
