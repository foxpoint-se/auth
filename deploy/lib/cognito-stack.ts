import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as cognito from "aws-cdk-lib/aws-cognito";
import {
  IdentityPool,
  UserPoolAuthenticationProvider,
} from "@aws-cdk/aws-cognito-identitypool-alpha";

export class AuthStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const userPool = new cognito.UserPool(this, "UserPool", {
      userPoolName: "foxpoint-user-pool",
      selfSignUpEnabled: false,
      signInAliases: { username: true },
      autoVerify: { email: true },
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      passwordPolicy: {
        minLength: 8,
        requireLowercase: true,
        requireDigits: true,
        requireSymbols: false,
        requireUppercase: true,
      },
    });

    const userPoolClient = userPool.addClient("UserPoolClient", {
      userPoolClientName: "foxpoint-pool-client",
      authFlows: { userSrp: true },
    });

    const identityPool = new IdentityPool(this, "IdentityPool", {
      identityPoolName: "foxpoint-identity-pool",
      allowUnauthenticatedIdentities: false,
      authenticationProviders: {
        userPools: [
          new UserPoolAuthenticationProvider({
            userPool,
            userPoolClient: userPoolClient,
          }),
        ],
      },
    });

    identityPool.authenticatedRole.addManagedPolicy({
      managedPolicyArn: "arn:aws:iam::aws:policy/AWSIoTFullAccess",
    });

    new cdk.CfnOutput(this, "UserPoolId", {
      value: userPool.userPoolId,
    });

    new cdk.CfnOutput(this, "UserPoolClientId", {
      value: userPoolClient.userPoolClientId,
    });

    new cdk.CfnOutput(this, "IdentityPoolId", {
      value: identityPool.identityPoolId,
    });
  }
}
