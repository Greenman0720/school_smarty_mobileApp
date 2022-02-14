const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "testnewversion": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://lvieeo5qmrhtzkulf7hpiiangq.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                    "region": "ap-northeast-2",
                    "authorizationType": "API_KEY",
                    "apiKey": "da2-osakdvznkjdzvirgmxyagdf2gy"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "AppSync": {
                    "Default": {
                        "ApiUrl": "https://lvieeo5qmrhtzkulf7hpiiangq.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                        "Region": "ap-northeast-2",
                        "AuthMode": "API_KEY",
                        "ApiKey": "da2-osakdvznkjdzvirgmxyagdf2gy",
                        "ClientDatabasePrefix": "testnewversion_API_KEY"
                    },
                    "testnewversion_AWS_IAM": {
                        "ApiUrl": "https://lvieeo5qmrhtzkulf7hpiiangq.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                        "Region": "ap-northeast-2",
                        "AuthMode": "AWS_IAM",
                        "ClientDatabasePrefix": "testnewversion_AWS_IAM"
                    }
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-northeast-2:099553fc-fd5c-4414-9af2-9fa2746f7fa1",
                            "Region": "ap-northeast-2"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-northeast-2_OrdFu6Dxo",
                        "AppClientId": "4e8p9cimpacce1mtem9q1c5coo",
                        "Region": "ap-northeast-2"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [
                            "EMAIL"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                }
            }
        }
    }
}''';