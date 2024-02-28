FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0
RUN yum install -y yum-utils && yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && yum install -y gh && yum clean all
RUN yum install -y jq && yum clean all
RUN pip install copier
RUN pip install --no-cache-dir awscli

