import * as cdk from 'aws-cdk-lib';
import { AwsSolutionsChecks } from 'cdk-nag';

import { Config } from '../lib/core/config';
import { MainStack } from '../lib/main';

const app = new cdk.App();
cdk.Aspects.of(app).add(new AwsSolutionsChecks({
  verbose: true,
  reports: true
}));

async function Main() {
  new Config().Load(`./config/dev.yaml`).then(_f => {

    new MainStack(app, "DataFabricStack", {
      env: {
        account: Config.Current.AWSAccountID,
        region: Config.Current.AWSRegion
      },
      description: '(qs-1u67sa7bo)'
    });
  });

}

Main();