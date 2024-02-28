#!/bin/bash -e

## NOTE: paths may differ when running in a managed task. To ensure behavior is consistent between
# managed and local tasks always use these variables for the project and project type path
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype

cd ${PROJECT_PATH}


VERSION=$(cat ${PROJECT_PATH}/VERSION)
CURREL=$(gh release list -L 1 | awk '{print $2}')

if [[ ${VERSION} == "${CURREL}" ]]; then
  echo "Please update VERSION file as a Release with this number already exists"
  exit 1
else
  if [ -f ${PROJECT_PATH}/changelog.md ];
    then
      gh release create ${VERSION} -F changelog.md
  else
      gh release create ${VERSION} --generate-notes
  fi
fi

exit 0