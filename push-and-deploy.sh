#!/usr/bin/env bash

usage() {
  cat <<EOM
Usage: ${0##*/} [options]

Tags the current commit for deployment and pushes changes.

Options:

  -h | --help                          Display this help message
  -f | --force                         Do not require unpushed commits
  -iuc | --ignore-uncommitted-changes  Ignore uncommitted changes and untracked files
  -iuf | --ignore-untracked-files      Ignore untracked files
EOM
}

require_arg () {
    local type="$1"
    local opt="$2"
    local arg="$3"

    if [[ -z "$arg" ]] || [[ "${arg:0:1}" == "-" ]]; then
      die "$opt requires <$type> argument"
    fi
}

ignoreUncommittedChanges=
ignoreUntrackedFilesOption=
force=

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage; exit 0 ;;
        -f|--force) force=t && shift 1 ;;
        -iuc|--ignore-uncommitted-changes) ignoreUncommittedChanges=t && shift 1 ;;
        -iuf|--ignore-untracked-files) ignoreUntrackedFilesOption=--untracked-files=no && shift 1 ;;
        *) echo "unexpected argument: $1" && usage; exit 1 ;;
    esac
done;

set -e

if [[ -z "$ignoreUncommittedChanges" ]]; then
  if output=$(git status --porcelain $ignoreUntrackedFilesOption) && [ -n "$output" ]; then
    # there are uncommitted changes or untracked files
    if [[ -z "$ignoreUntrackedFilesOption" ]]; then
      echo "There are uncommitted changes and/or untracked files. Use '--ignore-uncomitted-changes' or '--ignore-untracked-files'."
    else
      echo "There are uncommitted changes. Use '--ignore-uncomitted-changes'."
    fi
    exit 1
  fi
fi

doPushCommits=
if [[ -z "$force" ]]; then
  git fetch
  if unpushed=$(git log @{upstream}..) && [ -z "$unpushed" ]; then
    echo "Deployment will not work relyably because there are no unpushed commmits. Use '--force' to set and push the 'deploy' tag anyway."
    exit 1
  else
    doPushCommits=t
  fi
else
  doPushCommits=t
fi

# create / update the deploy tag
git tag -f deploy
git push --tags -f
if [[ -n "$doPushCommits" ]]; then
  git push
fi

