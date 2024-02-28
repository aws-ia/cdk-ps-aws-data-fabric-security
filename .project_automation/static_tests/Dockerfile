FROM public.ecr.aws/codebuild/amazonlinux2-x86_64-standard:5.0
#FROM public.ecr.aws/amazonlinux/amazonlinux:2023

# Install needed packages
RUN yum install -y go python3 tar wget && yum clean all

# Install NodeJs
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN . ~/.nvm/nvm.sh && source ~/.bashrc && nvm install node && nvm use node

# Install ESLint
RUN npm config set legacy-peer-deps true
RUN source ~/.bashrc && npm i -g eslint @typescript-eslint/eslint-plugin@latest prettier eslint-plugin-prettier@latest eslint-plugin-import @typescript-eslint/parser --save-dev --legacy-peer-deps

# Install golangci-lint
# binary will be $(go env GOPATH)/bin/golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.55.2


# Install semgrep and ruff
RUN yum install -y pip && yum clean all
RUN pip install semgrep
RUN pip3 install ruff

# Install grype
RUN cd /tmp && \
    curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin


