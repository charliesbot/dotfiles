prdone() {
  if (( $# != 1 )) || [[ "$1" != <-> ]]; then
    print -u2 -- "Usage: prdone <pr-number>"
    return 2
  fi

  local pr="$1"
  local info number base head head_oid state cross_repo
  local current_branch current_worktree current_oid current_status common_dir main_worktree main_status stack_status
  local worktree_parent sanitized_head
  local local_ref_status remote_info remote_status remote_oid

  info=$(gh pr view "$pr" \
    --json number,baseRefName,headRefName,headRefOid,state,isCrossRepository \
    --jq '[.number, .baseRefName, .headRefName, .headRefOid, .state, .isCrossRepository] | @tsv') || return 1
  IFS=$'\t' read -r number base head head_oid state cross_repo <<< "$info"

  if [[ "$base" != "main" ]]; then
    print -u2 -- "Refusing PR #$number: base is '$base', not 'main'."
    return 1
  fi

  if [[ "$cross_repo" == "true" ]]; then
    print -u2 -- "Refusing PR #$number: fork branches are not managed by this helper."
    return 1
  fi

  current_branch=$(git branch --show-current) || return 1
  if [[ "$current_branch" != "$head" ]]; then
    print -u2 -- "Refusing PR #$number: switch to the '$head' worktree first."
    return 1
  fi

  current_worktree=$(git rev-parse --show-toplevel) || return 1

  current_oid=$(git rev-parse HEAD) || return 1
  if [[ "$current_oid" != "$head_oid" ]]; then
    print -u2 -- "Refusing PR #$number: local '$head' does not match the PR head."
    return 1
  fi

  current_status=$(git status --porcelain) || return 1
  if [[ -n "$current_status" ]]; then
    print -u2 -- "Refusing PR #$number: the '$head' worktree has uncommitted changes."
    return 1
  fi

  common_dir=$(git rev-parse --path-format=absolute --git-common-dir) || return 1
  main_worktree=${common_dir:h}

  if [[ "$(git -C "$main_worktree" branch --show-current)" != "main" ]]; then
    print -u2 -- "Refusing PR #$number: the primary worktree is not on 'main'."
    return 1
  fi

  main_status=$(git -C "$main_worktree" status --porcelain) || return 1
  if [[ -n "$main_status" ]]; then
    print -u2 -- "Refusing PR #$number: the main worktree has uncommitted changes."
    return 1
  fi

  gh stack view --json >/dev/null 2>&1
  stack_status=$?
  if (( stack_status == 0 )); then
    print -u2 -- "Refusing PR #$number: use 'gh stack merge' for stacked PRs."
    return 1
  fi
  if (( stack_status != 2 )); then
    print -u2 -- "Refusing PR #$number: unable to determine stack membership."
    return 1
  fi

  case "$state" in
    OPEN)
      gh pr merge "$number" --squash --match-head-commit "$head_oid" || return 1
      state=$(gh pr view "$number" --json state --jq .state) || return 1
      if [[ "$state" != "MERGED" ]]; then
        print -u2 -- "PR #$number is queued but not merged. Run 'prdone $number' again after it merges."
        return 1
      fi
      ;;
    MERGED)
      print -- "PR #$number is already merged; continuing cleanup."
      ;;
    *)
      print -u2 -- "Refusing PR #$number: state is '$state'."
      return 1
      ;;
  esac

  wt switch main || return 1
  git pull --ff-only origin main || return 1
  wt remove "$head" --foreground -y || return 1

  worktree_parent=${current_worktree:h}
  sanitized_head=${head//\//-}
  if [[ "$current_worktree" == "$HOME/.worktrees/"* \
      && "${current_worktree:t}" == "${main_worktree:t}" \
      && "${worktree_parent:t}" == "$sanitized_head" ]]; then
    rmdir -- "$worktree_parent" 2>/dev/null || true
  fi

  git show-ref --exists "refs/heads/$head" 2>/dev/null
  local_ref_status=$?
  case "$local_ref_status" in
    0)
      print -u2 -- "Cleanup stopped: Worktrunk retained local branch '$head'."
      return 1
      ;;
    2) ;;
    *)
      print -u2 -- "Cleanup stopped: unable to verify local branch removal."
      return 1
      ;;
  esac

  remote_info=$(git ls-remote --exit-code --heads origin "refs/heads/$head")
  remote_status=$?
  case "$remote_status" in
    0)
      remote_oid=${remote_info%%[[:space:]]*}
      if [[ "$remote_oid" != "$head_oid" ]]; then
        print -u2 -- "Cleanup stopped: remote '$head' moved after PR #$number merged."
        return 1
      fi
      git push --force-with-lease="refs/heads/$head:$head_oid" origin --delete "$head" || return 1
      ;;
    2) ;;
    *)
      print -u2 -- "Cleanup stopped: unable to inspect remote branch '$head'."
      return 1
      ;;
  esac

  print -- "PR #$number merged; main updated; '$head' removed locally and remotely."
}
