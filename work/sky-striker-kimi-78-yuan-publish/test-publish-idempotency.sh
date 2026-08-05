#!/usr/bin/env bash
# Local simulation for publish.sh lifecycle branches. Uses this file as a fake blogctl.
set -euo pipefail

TITLE='花了 78 元，说了 14 句话，我用 Kimi 做了一款魂系飞行射击游戏'
SLUG=sky-striker-kimi-78-yuan

mock_blogctl() {
  local state="$SKY_STRIKER_MOCK_STATE" command="${1:-}" subcommand="${2:-}" id status
  shift 2
  case "$command:$subcommand" in
    media:upload)
      echo "simulation unexpectedly attempted a media upload" >&2
      return 91
      ;;
    posts:list)
      printf 'list\n' >> "$state/log"
      if [[ -s "$state/id" ]]; then
        id=$(<"$state/id")
        status=$(<"$state/status")
        printf '{"counts":{},"posts":{"items":[{"id":%s,"title":"%s","slug":"%s","status":"%s"}],"page":1,"pageSize":20,"total":1}}\n' \
          "$id" "$TITLE" "$SLUG" "$status"
      else
        printf '{"counts":{},"posts":{"items":[],"page":1,"pageSize":20,"total":0}}\n'
      fi
      ;;
    posts:create)
      printf 'create\n' >> "$state/log"
      [[ ! -e "$state/id" ]] || { echo "duplicate create attempted" >&2; return 92; }
      printf '%s\n' "$SKY_STRIKER_MOCK_CREATE_ID" > "$state/id"
      printf 'draft\n' > "$state/status"
      printf '%s\n' "$TITLE" > "$state/title"
      printf '%s\n' "$SLUG" > "$state/slug"
      printf '{"id":%s}\n' "$SKY_STRIKER_MOCK_CREATE_ID"
      ;;
    posts:get)
      id="${1:-}"
      printf 'get %s\n' "$id" >> "$state/log"
      [[ -s "$state/id" && "$id" == "$(<"$state/id")" ]] || return 44
      status=$(<"$state/status")
      printf '{"id":%s,"title":"%s","slug":"%s","status":"%s"}\n' \
        "$id" "$(<"$state/title")" "$(<"$state/slug")" "$status"
      ;;
    posts:publish)
      id="${1:-}"
      printf 'publish %s\n' "$id" >> "$state/log"
      [[ -s "$state/id" && "$id" == "$(<"$state/id")" ]] || return 45
      printf 'published\n' > "$state/status"
      printf '{"id":%s,"status":"published"}\n' "$id"
      ;;
    *)
      echo "unsupported mock command: $command $subcommand" >&2
      return 93
      ;;
  esac
}

if [[ -n "${SKY_STRIKER_MOCK_STATE:-}" ]] && { [[ "${1:-}" == posts ]] || [[ "${1:-}" == media ]]; }; then
  mock_blogctl "$@"
  exit
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PUBLISH_SCRIPT="$SCRIPT_DIR/publish.sh"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/sky-striker-publish-test.XXXXXX")
trap 'rm -rf "$TEST_ROOT"' EXIT

make_case() {
  local name="$1" case_dir
  case_dir="$TEST_ROOT/$name"
  mkdir -p "$case_dir/scratch" "$case_dir/state"
  cp "$SCRIPT_DIR/draft.md" "$case_dir/scratch/draft.md"
  cp "$SCRIPT_DIR/media-map.txt" "$case_dir/scratch/media-map.txt"
  printf 'BLOG_ADMIN_USER=dummy\nBLOG_ADMIN_PASS=dummy\n' > "$case_dir/scratch/.blogenv"
  touch "$case_dir/state/log"
  printf '%s\n' "$case_dir"
}

init_remote() {
  local case_dir="$1" id="$2" status="$3"
  printf '%s\n' "$id" > "$case_dir/state/id"
  printf '%s\n' "$status" > "$case_dir/state/status"
  printf '%s\n' "$TITLE" > "$case_dir/state/title"
  printf '%s\n' "$SLUG" > "$case_dir/state/slug"
}

run_publish() {
  local case_dir="$1" create_id="$2"
  SKY_STRIKER_MOCK_STATE="$case_dir/state" \
  SKY_STRIKER_MOCK_CREATE_ID="$create_id" \
  BLOGCTL="$0" \
  PUBLISH_SCRATCH="$case_dir/scratch" \
  PUBLISH_REPO_ROOT="$REPO_ROOT" \
    bash "$PUBLISH_SCRIPT"
}

command_count() {
  local command="$1" log="$2"
  awk -v command="$command" '$1 == command { count++ } END { print count + 0 }' "$log"
}

assert_equal() {
  local expected="$1" actual="$2" label="$3"
  [[ "$actual" == "$expected" ]] || {
    echo "FAIL $label: expected $expected, got $actual" >&2
    exit 1
  }
}

first=$(make_case first-run)
run_publish "$first" 501
run_publish "$first" 501
assert_equal 501 "$(<"$first/scratch/post-id.txt")" "first-run recorded ID"
assert_equal published "$(<"$first/state/status")" "first-run remote status"
assert_equal 1 "$(command_count create "$first/state/log")" "first-run create count after rerun"
assert_equal 1 "$(command_count publish "$first/state/log")" "first-run publish count after rerun"

resume=$(make_case resume-after-create)
init_remote "$resume" 502 draft
printf '502\n' > "$resume/scratch/post-id.txt"
run_publish "$resume" 999
assert_equal 0 "$(command_count create "$resume/state/log")" "resume create count"
assert_equal 1 "$(command_count publish "$resume/state/log")" "resume publish count"
assert_equal published "$(<"$resume/state/status")" "resume remote status"

published=$(make_case already-published)
init_remote "$published" 503 published
printf '503\n' > "$published/scratch/post-id.txt"
run_publish "$published" 999
assert_equal 0 "$(command_count create "$published/state/log")" "published create count"
assert_equal 0 "$(command_count publish "$published/state/log")" "published publish count"
assert_equal published "$(<"$published/state/status")" "published remote status"

malformed=$(make_case malformed-local-id)
printf 'not-an-id\n' > "$malformed/scratch/post-id.txt"
if run_publish "$malformed" 999 >/dev/null 2>&1; then
  echo "FAIL malformed local ID was accepted" >&2
  exit 1
fi
assert_equal 0 "$(command_count create "$malformed/state/log")" "malformed-ID create count"

mismatch=$(make_case remote-identity-mismatch)
init_remote "$mismatch" 504 published
printf '504\n' > "$mismatch/scratch/post-id.txt"
printf 'wrong title\n' > "$mismatch/state/title"
if run_publish "$mismatch" 999 >/dev/null 2>&1; then
  echo "FAIL remote identity mismatch was accepted" >&2
  exit 1
fi
assert_equal 0 "$(command_count create "$mismatch/state/log")" "identity-mismatch create count"
assert_equal 0 "$(command_count publish "$mismatch/state/log")" "identity-mismatch publish count"

ambiguous=$(make_case missing-local-id-with-remote-match)
init_remote "$ambiguous" 505 published
if run_publish "$ambiguous" 999 >/dev/null 2>&1; then
  echo "FAIL missing local ID with a remote match created or continued" >&2
  exit 1
fi
assert_equal 0 "$(command_count create "$ambiguous/state/log")" "ambiguous-state create count"
assert_equal 0 "$(command_count publish "$ambiguous/state/log")" "ambiguous-state publish count"

echo "PASS lifecycle simulations and duplicate-prevention failure branches"
