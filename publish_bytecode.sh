#!/bin/sh

# Made this script as the front-end had a CORS issue.

curl 'https://us-central1-paradigm-ctf-2022.cloudfunctions.net/monacoSubmitBytecode' \
  -H 'Content-Type: application/json' \
  --data-raw '{"bytecode":"YOUR_BYTECODE(not the deployed one)","secret":"YOUR_TICKET"}' \
  --compressed