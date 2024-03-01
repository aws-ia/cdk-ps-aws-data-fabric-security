import * as cdk from "aws-cdk-lib";
import * as iam from "aws-cdk-lib/aws-iam";
import * as lambda from "aws-cdk-lib/aws-lambda";


/**
 * Interface for the Lambda deployment stacks.
 */
export interface ILambdaDeploymentStack {
  createDeployPolicy(props: cdk.StackProps): iam.PolicyDocument;
  createDestroyPolicy(props: cdk.StackProps): iam.PolicyDocument;
  createDeployFunction(props: cdk.StackProps): lambda.Function;
  createDestroyFunction(props: cdk.StackProps): lambda.Function;
  createBootstrap(deployFunction: lambda.Function, destroyFunction: lambda.Function): void;
}