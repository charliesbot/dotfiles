#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new use case in :core.
#
# Usage:
#   ./scaffold-usecase.sh <UseCaseName> <package> <repository> [--flow]
#
# Examples:
#   ./scaffold-usecase.sh GetArticles com.myapp FeedRepository
#   ./scaffold-usecase.sh ObserveAuthState com.myapp AuthRepository --flow
#
# Creates:
#   core/src/main/kotlin/<package>/core/domain/usecase/<UseCaseName>UseCase.kt
#
# By default generates a suspend function returning Result<T>.
# Use --flow to generate a non-suspend function returning Flow<T>.

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <UseCaseName> <base-package> <RepositoryName> [--flow]"
  echo ""
  echo "  <UseCaseName>     Name without the 'UseCase' suffix (e.g. GetArticles)"
  echo "  <base-package>    Base package (e.g. com.myapp)"
  echo "  <RepositoryName>  Repository class name (e.g. FeedRepository)"
  echo "  --flow            Generate Flow-based use case instead of suspend"
  echo ""
  echo "Examples:"
  echo "  $0 GetArticles com.myapp FeedRepository"
  echo "  $0 ObserveAuthState com.myapp AuthRepository --flow"
  exit 1
fi

USE_CASE_NAME="$1"
BASE_PACKAGE="$2"
REPOSITORY="$3"
IS_FLOW=false
if [[ "${4:-}" == "--flow" ]]; then
  IS_FLOW=true
fi

PACKAGE_PATH="${BASE_PACKAGE//.//}"
REPO_VAR="$(echo "${REPOSITORY:0:1}" | tr '[:upper:]' '[:lower:]')${REPOSITORY:1}"
OUTPUT_DIR="core/src/main/kotlin/${PACKAGE_PATH}/core/domain/usecase"
OUTPUT_FILE="${OUTPUT_DIR}/${USE_CASE_NAME}UseCase.kt"

mkdir -p "${OUTPUT_DIR}"

if [[ -f "${OUTPUT_FILE}" ]]; then
  echo "Error: ${OUTPUT_FILE} already exists"
  exit 1
fi

if [[ "${IS_FLOW}" == true ]]; then
  cat >"${OUTPUT_FILE}" <<KOTLIN
package ${BASE_PACKAGE}.core.domain.usecase

import ${BASE_PACKAGE}.core.domain.repository.${REPOSITORY}
import kotlinx.coroutines.flow.Flow

class ${USE_CASE_NAME}UseCase(
    private val ${REPO_VAR}: ${REPOSITORY},
) {
    operator fun invoke(): Flow<TODO("Return type")> =
        TODO("Call ${REPO_VAR} method")
}
KOTLIN
else
  cat >"${OUTPUT_FILE}" <<KOTLIN
package ${BASE_PACKAGE}.core.domain.usecase

import ${BASE_PACKAGE}.core.domain.repository.${REPOSITORY}
import ${BASE_PACKAGE}.core.common.Result

class ${USE_CASE_NAME}UseCase(
    private val ${REPO_VAR}: ${REPOSITORY},
) {
    suspend operator fun invoke(): Result<TODO("Return type")> =
        TODO("Call ${REPO_VAR} method")
}
KOTLIN
fi

echo "Created: ${OUTPUT_FILE}"
echo ""
echo "Next steps:"
echo "  1. Replace the TODO placeholders with the actual return type and repository call"
echo "  2. Register in the Koin core DI module: factory { ${USE_CASE_NAME}UseCase(get()) }"
echo "  3. Write a test for the use case"
