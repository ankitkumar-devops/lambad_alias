#!/bin/bash

# List all Lambda functions
lambda_functions=$(aws lambda list-functions --output json | jq -r '.Functions[].FunctionName')

# Create a CSV file and write header
csv_file="lambda_functions.csv"
echo "Function Name,Runtime,Architectures" > $csv_file

# Iterate over each Lambda function and get its details
for function_name in $lambda_functions; do
    echo "Processing Lambda Function: $function_name"

    function_details=$(aws lambda get-function --function-name $function_name --output json)
    function_runtime=$(echo $function_details | jq -r '.Configuration.Runtime')
    function_architectures=$(echo $function_details | jq -r '.Configuration.Architectures[]')

    # Append data to the CSV file
    echo "$function_name,$function_runtime,$function_architectures" >> $csv_file

    echo "------------------------"
done

echo "Data exported to $csv_file" 
# if we need to output the date in the table format
column -s, -t lambda_functions.csv
