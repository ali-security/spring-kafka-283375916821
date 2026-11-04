#!/bin/sh
# Seal build helper: Travis archives job logs asynchronously, so a log fetched right
# after the job finishes can be cut off before the test results. Keep the job open
# (after_script cannot change the build result) until this job's own public log
# contains the Gradle final line, printing a heartbeat on every poll.
LEG="$1"
URL="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
elapsed=0
while [ "$elapsed" -lt 900 ]; do
  if curl -fsS "$URL" 2>/dev/null | grep -Eq 'BUILD (SUCCESSFUL|FAILED) in [0-9]'; then
    echo "log for leg ${LEG} archived (${elapsed}s)"
    exit 0
  fi
  echo "waiting for ${LEG} log archive... (${elapsed}s)"
  sleep 20
  elapsed=$((elapsed + 20))
done
echo "gave up waiting for ${LEG} log archive after ${elapsed}s"
