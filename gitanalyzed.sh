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

mkdir -p $GITANALYZED_FOLDER

calculateFileChurn
calculateLineChurn
calculateAuthorChurn
calculateCodeOwnership
calculateChurnRate
calculateBugFixes
listActiveBranches

echo "Done!"