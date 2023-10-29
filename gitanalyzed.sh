#!/bin/bash

echo "🧠 Analyzing Git repository... ⌛️"

GITANALYZED_FOLDER="gitanalyzed"
FILENAME_FILE_CHURN="file_churn.txt"
FILENAME_LINE_CHURN="line_churn.txt"
FILENAME_AUTHOR_CHURN="author_churn.txt"
FILENAME_CODE_OWNERSHIP="code_ownership.txt"
FILENAME_CHURN_RATE="churn_rate.txt"
FILENAME_BUG_FIXES="bug_fixes.txt"
FILENAME_BUG_FIXES_PERCENT="bug_fix_percentage.txt"
FILENAME_ACTIVE_BRANCHES="active_branches.txt"
FILENAME_COMMITS_LAST_MONTH="commits_last_month.txt"
FILENAME_DAYS_SINCE_LAST_COMMIT="days_since_last_commit.txt"
FILENAME_TAG_STATISTICS="tag_statistics.txt"

calculateFileChurn() {
  git log --pretty=format: --name-only | grep -v '^$' | sort | uniq -c | sort -nr >"$GITANALYZED_FOLDER/$FILENAME_FILE_CHURN"
}

calculateLineChurn() {
  line_churn_output=$(git log --numstat --format="%H" | awk '{ add += $1; remove += $2 } END { printf "Added lines: %s\nRemoved lines: %s\n", add, remove }')
  echo "$line_churn_output" >"$GITANALYZED_FOLDER/$FILENAME_LINE_CHURN"
}

calculateAuthorChurn() {
  git log --format='%aN' | sort | uniq -c | sort -nr >"$GITANALYZED_FOLDER/$FILENAME_AUTHOR_CHURN"
}

calculateCodeOwnership() {
  git ls-tree -r HEAD --name-only | while read filename; do
    authors=$(git log --format='%aN' "$filename" | sort -u)
    author_count=$(echo "$authors" | wc -l)
    if [ "$author_count" -gt 0 ]; then
      echo "$author_count $(echo "$authors" | tr '\n' ', ') $filename"
    fi
  done | sort -nr >"$GITANALYZED_FOLDER/$FILENAME_CODE_OWNERSHIP"
}

calculateChurnRate() {
  total_changes=$(git log --oneline | wc -l)
  total_days=$(git log --format="%ad" --date=short | sort -u | wc -l)
  if [ "$total_days" -gt 0 ]; then
    churn_rate=$((total_changes / total_days))
    echo "Churn rate: $churn_rate changes per day" >"$GITANALYZED_FOLDER/$FILENAME_CHURN_RATE"
  else
    echo "Churn rate calculation failed: Total days is zero." >"$GITANALYZED_FOLDER/$FILENAME_CHURN_RATE"
  fi
}

calculateBugFixes() {
  git log --grep="^bug" --grep="^error" --grep="^fix" --format="%h %ad %s" >"$GITANALYZED_FOLDER/$FILENAME_BUG_FIXES"
  total_commits=$(git log --oneline | wc -l)
  bug_fix_count=$(wc -l <"$GITANALYZED_FOLDER/$FILENAME_BUG_FIXES")
  if [ "$total_commits" -gt 0 ]; then
    bug_fix_percentage=$((bug_fix_count * 100 / total_commits))
    echo "Bug fixes/errors: $bug_fix_count out of $total_commits commits ($bug_fix_percentage%)" >"$GITANALYZED_FOLDER/$FILENAME_BUG_FIXES_PERCENT"
  else
    echo "Bug fix calculation failed: Total commits is zero." >"$GITANALYZED_FOLDER/$FILENAME_BUG_FIXES_PERCENT"
  fi
}

listActiveBranches() {
  active_branches=$(git branch -r --merged | grep -v HEAD | sed 's/origin\///')
  echo "$active_branches" >"$GITANALYZED_FOLDER/$FILENAME_ACTIVE_BRANCHES"
}

listCommitsLastMonth() {
  commits_last_month=$(git log --since="1 month ago" --until="0 month ago" --pretty=format:'%h,%an,%ar,%s' | wc -l)
  echo "Commits in the Last Month: $commits_last_month" >"$GITANALYZED_FOLDER/$FILENAME_COMMITS_LAST_MONTH"
  list_commits_last_month=$(git log --since="1 month ago" --until="0 month ago" --pretty=format:'%h,%an,%ar,%s')
  echo "$list_commits_last_month" >>"$GITANALYZED_FOLDER/$FILENAME_COMMITS_LAST_MONTH"
}

daysSinceLastCommit() {
  last_commit_date=$(git log -1 --format="%ai")

  if [[ "$(uname | tr '[:upper:]' '[:lower:]')" == "darwin" ]]; then
    last_commit_timestamp=$(date -jf "%Y-%m-%d %H:%M:%S %z" "$last_commit_date" "+%s")
  else
    last_commit_timestamp=$(date -d "$last_commit_date" "+%s")
  fi

  current_timestamp=$(date "+%s")
  time_diff=$((current_timestamp - last_commit_timestamp))
  days_since_last_commit=$((time_diff / 86400)) # 86400 seconds in a day
  echo "Days since the last commit: $days_since_last_commit" >"$GITANALYZED_FOLDER/$FILENAME_DAYS_SINCE_LAST_COMMIT"
}

calculateCommitsPerTag() {
  if [[ "$(uname | tr '[:upper:]' '[:lower:]')" == "darwin" ]]; then
    tag_date=$(date -jf "%Y-%m-%d" "$(git log -1 --format=%ai "$1")" "+%s")
  else
    tag_date=$(date -d "$(git log -1 --format=%ai "$1")" "+%Y-%m-%d")
  fi

  commits_per_tag=$(git rev-list --count "$1"..."$2")
  echo "$1 ($tag_date): $commits_per_tag" >>"$GITANALYZED_FOLDER/$FILENAME_TAG_STATISTICS"
}

calculateTagStatistics() {
  total_tags=$(git tag | wc -l)

  echo "Total tags: $total_tags" >"$GITANALYZED_FOLDER/$FILENAME_TAG_STATISTICS"

  if [ "$total_tags" -gt 0 ]; then
    total_commits=$(git log --oneline | wc -l)
    average_commits_per_tag=$(awk "BEGIN {print $total_commits/$total_tags}")

    echo "Average commits per tag: $average_commits_per_tag" >>"$GITANALYZED_FOLDER/$FILENAME_TAG_STATISTICS"
    echo "" >>"$GITANALYZED_FOLDER/$FILENAME_TAG_STATISTICS"

    start_tag=""
    for tag in $(git tag --sort=-taggerdate); do
      if [ -n "$start_tag" ]; then
        calculateCommitsPerTag "$start_tag" "$tag"
      fi
      start_tag=$tag
    done

    # Count the number of commits between the first tag and the first commit
    calculateCommitsPerTag "$start_tag" "$(git rev-list --max-parents=0 --first-parent HEAD)"
  else
    echo "Average commits per tag: N/A" >>"$GITANALYZED_FOLDER/$FILENAME_TAG_STATISTICS"
  fi
}

# Check if the current directory is a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not in a Git repository. Exiting."
  exit 1
fi

mkdir -p $GITANALYZED_FOLDER

calculateFileChurn
calculateLineChurn
calculateAuthorChurn
calculateCodeOwnership
calculateChurnRate
calculateBugFixes
listActiveBranches
listCommitsLastMonth
daysSinceLastCommit
calculateTagStatistics

echo "Done!"
