#!/usr/bin/env zsh

source "${0:A:h}/prdone.zsh"

typeset scenario test_log
integer passed=0

record() {
  print -r -- "$*" >> "$test_log"
}

gh() {
  record "gh $*"

  if [[ "$1" == "stack" && "$2" == "view" ]]; then
    return 2
  fi

  if [[ "$1" == "pr" && "$2" == "view" ]]; then
    if [[ "$*" == *"--json state"* ]]; then
      [[ "$scenario" == "queued" ]] && print -- "OPEN" || print -- "MERGED"
    else
      print -r -- $'17\tmain\tfeature\tabc\tOPEN\tfalse'
    fi
    return 0
  fi

  [[ "$1" == "pr" && "$2" == "merge" ]]
}

git() {
  record "git $*"

  case "$*" in
    "branch --show-current") print -- "feature" ;;
    "rev-parse HEAD") print -- "abc" ;;
    "rev-parse --path-format=absolute --git-common-dir") print -- "/repo/.git" ;;
    "status --porcelain")
      [[ "$scenario" == "status-error" ]] && return 128
      return 0
      ;;
    "-C /repo branch --show-current") print -- "main" ;;
    "-C /repo status --porcelain")
      [[ "$scenario" == "main-status-error" ]] && return 128
      return 0
      ;;
    "pull --ff-only origin main") ;;
    "show-ref --exists refs/heads/feature")
      [[ "$scenario" == "retained-local" ]] && return 0
      [[ "$scenario" == "local-ref-error" ]] && return 1
      return 2
      ;;
    "ls-remote --exit-code --heads origin refs/heads/feature")
      [[ "$scenario" == "remote-error" ]] && return 128
      [[ "$scenario" == "remote-absent" ]] && return 2
      [[ "$scenario" == "remote-moved" ]] && print -r -- $'def\trefs/heads/feature' || print -r -- $'abc\trefs/heads/feature'
      ;;
    "push --force-with-lease=refs/heads/feature:abc origin --delete feature") ;;
    *) return 1 ;;
  esac
}

wt() {
  record "wt $*"
  [[ "$1" == "switch" || "$1" == "remove" ]]
}

line_number() {
  local needle="$1" line
  integer number=1

  while IFS= read -r line; do
    if [[ "$line" == "$needle"* ]]; then
      print -- "$number"
      return 0
    fi
    (( number++ ))
  done < "$test_log"

  return 1
}

assert_before() {
  local first second
  first=$(line_number "$1") || return 1
  second=$(line_number "$2") || return 1
  (( first < second ))
}

run_case() {
  scenario="$1"
  local expected_status="$2"
  shift 2
  test_log=$(mktemp)

  prdone 17 >/dev/null 2>&1
  local actual_status=$?

  if (( actual_status != expected_status )); then
    print -u2 -- "$scenario: expected status $expected_status, got $actual_status"
    return 1
  fi

  while (( $# > 0 )); do
    if [[ "$1" == "present" ]]; then
      line_number "$2" >/dev/null || {
        print -u2 -- "$scenario: missing '$2'"
        return 1
      }
    else
      if line_number "$2" >/dev/null; then
        print -u2 -- "$scenario: unexpected '$2'"
        return 1
      fi
    fi
    shift 2
  done

  [[ "$scenario" != "success" ]] && rm -f "$test_log"
  (( ++passed ))
}

run_case success 0 \
  present "gh pr merge" \
  present "wt switch main" \
  present "git pull --ff-only origin main" \
  present "wt remove feature --foreground -y" \
  present "git show-ref --exists refs/heads/feature" \
  present "git ls-remote --exit-code --heads origin refs/heads/feature" \
  present "git push --force-with-lease=refs/heads/feature:abc origin --delete feature" || exit 1
assert_before "gh pr merge" "wt switch main" || exit 1
assert_before "wt switch main" "git pull --ff-only origin main" || exit 1
assert_before "git pull --ff-only origin main" "wt remove feature" || exit 1
assert_before "wt remove feature" "git push --force-with-lease" || exit 1
rm -f "$test_log"

run_case queued 1 absent "wt switch main" || exit 1
run_case status-error 1 absent "gh stack view" || exit 1
run_case main-status-error 1 absent "gh stack view" || exit 1
run_case retained-local 1 absent "git ls-remote" || exit 1
run_case local-ref-error 1 absent "git ls-remote" || exit 1
run_case remote-moved 1 absent "git push" || exit 1
run_case remote-error 1 absent "git push" || exit 1
run_case remote-absent 0 absent "git push" || exit 1

print -- "$passed tests passed"
