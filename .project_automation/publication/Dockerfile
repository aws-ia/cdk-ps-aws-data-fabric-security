<<<<<<< before updating
FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0
RUN yum install -y yum-utils && yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && yum install -y gh && yum clean all
RUN yum install -y jq && yum clean all
RUN pip install copier
RUN pip install --no-cache-dir awscli

=======
FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:4.0
RUN yum install -y yum-utils && yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo && yum install -y gh 
RUN pip3 install 'copier==8.3.0' 'pyyaml-include<2.*'
RUN pip install bump2version
>>>>>>> after updating
