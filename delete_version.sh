#!/bin/bash

aws lambda list-versions-by-function --function-name dev-irn-demo1-csv-json --query 'Versions[*].[Version, FunctionArn]' --output json | jq 'sort_by(.[0]) | reverse | .[2:] | .[] | select(.[0] != "$LATEST") | .[1]' | xargs -I {} aws lambda delete-function --function-
name {}
