FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0

# Install needed packages
RUN yum install -y go python3 tar wget && yum clean all

# Install NodeJs
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN . ~/.nvm/nvm.sh && source ~/.bashrc && nvm install node && nvm use node

## install GitHub CLI
RUN yum install -y yum-utils && yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && yum install -y gh && yum clean all


## Install AWS CDK
RUN source ~/.bashrc && npm install -g aws-cdk

## Install Asciidoctoer
RUN gem install asciidoctor