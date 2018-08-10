import ballerina/http;

documentation {
    Object for GTasks endpoint.

    F{{gtasksConnector}} Reference to GTasksConnector type
}
public type Client object {

    public GTasksConnector gtasksConnector = new;

    documentation {
        Initialize GTasks endpoint.

        P{{gtasksConfig}} GTasks configuraion
    }
    public function init(GTasksConfiguration gtasksConfig);

    documentation {
        Initialize GTasks endpoint.

        R{{}} The GTasks connector object
    }
    public function getCallerActions() returns GTasksConnector;

};

documentation {
    F{{accessToken}} Access token of the account
    F{{clientConfig}} The http client endpoint
}
public type GTasksConfiguration record {
    string accessToken;
    http:ClientEndpointConfig clientConfig;
};

function Client::init(GTasksConfiguration gtasksConfig) {
    http:AuthConfig? auth = gtasksConfig.clientConfig.auth;
    match auth {
        http:AuthConfig authConfig => {
            authConfig.refreshUrl = REFRESH_URL;
        }
        () => {}
    }
    gtasksConfig.clientConfig.url = GTASKS_API_URL;
    self.gtasksConnector.client.init(gtasksConfig.clientConfig);
}

function Client::getCallerActions() returns GTasksConnector {
    return self.gtasksConnector;
}
