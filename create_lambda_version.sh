#!/bin/bash

# Assuming the input parameter contains Lambda function names separated by commas
input_parameter="MyLambdaFunction-01,MyLambdaFunction-02,MyLambdaFunction-03"

# Convert the comma-separated string into an array
IFS=',' read -ra function_names <<< "$input_parameter"

# AWS region
region="us-east-1"

# Iterate through the array of function names
for function_name in "${function_names[@]}"; do
    # Check if a version already exists
    existing_version=$(aws lambda list-versions-by-function --function-name "$function_name" --region "$region" --query 'Versions[0].Version')

    if [ "$existing_version" == "null" ]; then
        # No version exists, create a new version
        aws lambda publish-version --function-name "$function_name" --region "$region"
        echo "Version created for function $function_name."
    else
        echo "Version already exists for function $function_name. Skipping."
    fi
    sleep 2
done
