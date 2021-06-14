#!/usr/bin/env sh
# exit on errors
set -e

# NOTE(dgl) setup in current directory
BASE=. #$(dirname "$0")
if [ ! -d "${BASE}/.git/hooks" ]; then
    echo "${BASE} is not a vaild git directory."
    exit 1
fi

###################
# Pre-Commit Hook #
###################
# NOTE(dgl): This creates a new pre-commit.d directory which will contain all pre-commit scripts.
# The pre-commit hook calls every script inside the pre-commi.d directory
mkdir -p ${BASE}/.git/hooks/pre-commit.d/
cat <<-'EOF' > ${BASE}/.git/hooks/pre-commit
#!/usr/bin/env sh

DIR=$(dirname "$0")
HOOK_NAME=$(basename "$0")

HOOK_DIR="${DIR}/${HOOK_NAME}.d"

if [ -d $HOOK_DIR ]; then
  STDIN=$(cat /dev/stdin)

  echo "###### Running Hooks ######"
  echo "You can skip hooks by running the commit command with '--no-verify'"
  for HOOK in ${HOOK_DIR}/*; do
    echo "$HOOK_NAME - $HOOK"
    echo
    echo "$STDIN" | . $HOOK "$@"

    EXIT_CODE=$?

    if [ $EXIT_CODE != 0 ]; then
      exit $EXIT_CODE
    fi
  done
else
  echo "$HOOK_DIR not found"
  exit 1
fi

exit 0
EOF
chmod +x ${BASE}/.git/hooks/pre-commit

####################
# No-Commit Script #
####################
# NOTE(dgl): This script ignores lines that are marked with 'nocheckin' or 'no-checkin'
cat <<-'EOF' > ${BASE}/.git/hooks/pre-commit.d/99-no-checkin.sh
#!/use/bin/env sh
# This hook will look for code comments marked 'no-checkin'
#    - case-insensitive
#    - dash is optional
#    - can be prefixed with @
#
COUNT=$(git diff --no-ext-diff --cached --name-only -i -G"@?no-?checkin" | wc -l)
if [ "$COUNT" -ne "0" ]; then
   echo "WARNING: You are attempting to commit changes which include a 'no-checkin'."
   echo
   echo "Please check the following changes:"
   git diff --no-ext-diff --cached -U0 --exit-code -i -G"@?no-?checkin"
fi
EOF
chmod +x ${BASE}/.git/hooks/pre-commit.d/99-no-checkin.sh

################
# Config setup #
################
git_user=`git config user.name`
read -p "Git user: [${git_user}] " input
git_user=${input:-$git_user}
git config user.name "${git_user}"

git_email=`git config user.email`
read -p "Git email: [${git_email}] " input
git_email=${input:-$git_email}
git config user.email "${git_email}"
