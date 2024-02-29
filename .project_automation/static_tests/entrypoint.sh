#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

echo  "Starting Static Tests"

#********** Run Linting********************
echo  'Starting linting'

source ~/.bashrc

# Ruff Check for Python
ruff check --config ${PROJECT_PATH}/.config/ruff.toml ${PROJECT_PATH}/ -q

# Linting for ts & js
#
cp ${PROJECT_PATH}/.config/.eslintignore .
npm install @typescript-eslint/eslint-plugin@latest --save-dev
npm i prettier eslint-plugin-import @typescript-eslint/parser --save-dev --legacy-peer-deps
npm i eslint-plugin-prettier@latest eslint-config-prettier@latest --save-dev
npm i eslint-import-resolver-typescript
npm i eslint
npx eslint ${PROJECT_PATH}/ --no-eslintrc --config ${PROJECT_PATH}/.config/eslint-config.json --quiet --no-error-on-unmatched-pattern

# Linting for GOLang
golangci-lint run -c ${PROJECT_PATH}/.config/.golangcli.yml


echo  "linting complete"

#********** Run semgrep********************
echo  'Starting Semgrep Checks'

cp ${PROJECT_PATH}/.config/.semgrepignore .
semgrep scan --config auto

echo  'Finished Semgrep Checks'

#********** Run Grype ********************
echo  'Starting Vulnerability Checks'

grype dir:${PROJECT_PATH} -c ${PROJECT_PATH}/.config/config.yaml --fail-on high


echo  'Finished Vulnerability Checks'

echo  "Static Tests Finished"

#************ Run Cleanup ********************
rm -f ${PROJECT_PATH}/.semgrepignore
rm -f ${PROJECT_PATH}/.eslintignore
rm -rf ${PROJECT_PATH}/node_modules && rm -f package-lock.json

exit 0