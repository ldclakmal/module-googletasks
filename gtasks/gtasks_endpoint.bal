import ballerina/http;

# Object for GTasks endpoint.
#
# + gTasksConnector - Reference to GTasksConnector type
public type Client client object {

    public GTasksConnector gTasksConnector;

    public function __init(GTasksConfiguration gTasksConfig) {
        self.init(gTasksConfig);
        self.gTasksConnector = new(GTASKS_API_URL, gTasksConfig.clientConfig);
    }

    # Initialize GTasks endpoint.
    #
    # + gTasksConfig - GTasks configuraion
    public function init(GTasksConfiguration gTasksConfig);

    # Returns all the authenticated user's task lists.
    #
    # + return - If success, returns json with of task list, else returns `error` object
    public remote function listTaskLists() returns json|error {
        return self.gTasksConnector->listTaskLists();
    }

    # Returns all tasks in the specified task list.
    #
    # + taskList - Name of the task list
    # + return - If success, returns json with details of given task list, else returns `error` object
    public remote function listTasks(string taskList) returns json|error {
        return self.gTasksConnector->listTasks(taskList);
    }

    # Updates the specified task.
    #
    # + taskList - Name of the task list
    # + taskId - Name of the task
    # + task - Task to be updated as json
    # + return - If success, returns json  else returns `error` object
    public remote function updateTask(string taskList, string taskId, json task) returns json|error {
        return self.gTasksConnector->updateTask(taskList, taskId, task);
    }
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
