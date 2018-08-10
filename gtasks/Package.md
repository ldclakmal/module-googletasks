Connects to Google Tasks from Ballerina.

# Package Overview

The Google Tasks connector allows you to do operations like list, get, insert, update, delete, patch related to
tasklists and tasks through the Google Tasks REST API. It handles OAuth 2.0 authentication.

**Tasklists Operations**

The `chanakal/gtasks` package contains list, get, insert, update, delete, patch operations related to Google TaskLists.

**Tasks Operations**

The `chanakal/gtasks` package contains list, get, insert, update, delete, patch operations related to Google Tasks.

## Compatibility
|                          |    Version     |
|:------------------------:|:--------------:|
| Ballerina Language       | 0.981.0        |
| Google Tasks API         | v1             |

## Sample
Import the `chanakal/gtasks` package into the Ballerina project.
```ballerina
import chanakal/gtasks;
```
Instantiate the connector by giving authentication details in the HTTP client config, which has built-in support for
BasicAuth and OAuth 2.0. GTasks uses OAuth 2.0 to authenticate and authorize requests. The GTasks connector can be
minimally instantiated in the HTTP client config using the access token or using the client ID, client secret,
and refresh token.

**Obtaining Tokens to Run the Sample**

1. Visit [Google API Console](https://console.developers.google.com), click **Create Project**, and follow the wizard
to create a new project.
2. Go to **Credentials -> OAuth consent screen**, enter a product name to be shown to users, and click **Save**.
3. On the **Credentials** tab, click **Create credentials** and select **OAuth client ID**.
4. Select an application type, enter a name for the application, and specify a redirect URI
(enter https://developers.google.com/oauthplayground if you want to use
[OAuth 2.0 playground](https://developers.google.com/oauthplayground)
to receive the authorization code and obtain the access token and refresh token).
5. Click **Create**. Your client ID and client secret appear.
6. In a separate browser window or tab, visit [OAuth 2.0 playground](https://developers.google.com/oauthplayground),
select the required GTask API scopes, and then click **Authorize APIs**.
7. When you receive your authorization code, click **Exchange authorization code for tokens** to obtain the refresh token
and access token.

You can now enter the credentials in the HTTP client config.
```ballerina
endpoint gtasks:Client gtasksClient {
    clientConfig: {
        auth: {
            accessToken: "",
            clientId: "",
            clientSecret: "",
            refreshToken: ""
        }
    }
};
```

The `listTaskLists` function returns the information about the task lists.
```ballerina
    var details = gtasksClient->listTaskLists();
    match details {
        json response => io:println(response);
        gtasks:GTasksError gtasksError => test:assertFail(msg = gtasksError.message);
    }
```

The `listTasks` function returns the information about the tasks of the given task list.
```ballerina
    var details = gtasksClient->listTasks("BallerinaDay");
    match details {
        json response => io:println(response);
        gtasks:GTasksError gtasksError => test:assertFail(msg = gtasksError.message);
    }
```

The `updateTask` function returns the information about the updated task for the given task list and task.
```ballerina
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
```