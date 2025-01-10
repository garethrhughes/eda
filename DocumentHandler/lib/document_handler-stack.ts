import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import { Topic } from 'aws-cdk-lib/aws-sns';
import { SqsSubscription } from 'aws-cdk-lib/aws-sns-subscriptions';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as lambdaEventSources from 'aws-cdk-lib/aws-lambda-event-sources';

export class DocumentHandlerStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const queue = new sqs.Queue(this, 'DocumentHandlerQueue', {
      visibilityTimeout: cdk.Duration.seconds(300)
    });

    const lambdaFunction = new lambda.Function(this, 'Function', {
      code: lambda.Code.fromAsset('src'),
      handler: 'index.handler',
      functionName: 'SqsMessageHandler',
      runtime: lambda.Runtime.NODEJS_22_X,
    });

    const topic = Topic.fromTopicArn(this, 'DocumentUploadTopic', 'arn:aws:sns:ap-southeast-2:905418130127:my-sns-topic');
    topic.addSubscription(new SqsSubscription(queue));

    const eventSource = new lambdaEventSources.SqsEventSource(queue);
    lambdaFunction.addEventSource(eventSource);
  }
}
