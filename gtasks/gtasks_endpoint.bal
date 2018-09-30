import ballerina/http;

# Object for GTasks endpoint.
#
# + gtasksConnector - Reference to GTasksConnector type
public type Client object {

    public GTasksConnector gtasksConnector = new;

    # Initialize GTasks endpoint.
    #
    # + gtasksConfig - GTasks configuraion
    public function init(GTasksConfiguration gtasksConfig);

    # Initialize GTasks endpoint.
    #
    # + return - The GTasks connector object
    public function getCallerActions() returns GTasksConnector;

};

# Object for GTasks configuration.
#
# + accessToken - Access token of the account
# + clientConfig - The http client endpoint
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
