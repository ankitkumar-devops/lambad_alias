#!/bin/bash

# List all functions and save the output to a file
aws lambda list-functions --output json > functions.json

# Extract architectures and runtimes from the JSON file
function_names=$(jq -r '.Functions[].FunctionName' functions.json)

# Create a CSV file and write header
csv_file="lambda_functions.csv"
echo "Function Name,Runtime,Architectures" > $csv_file

for function_name in $function_names; do
    architecture=$(jq -r --arg function_name "$function_name" '.Functions[] | select(.FunctionName == $function_name) | .Architectures[0]' functions.json)
    runtime=$(jq -r --arg function_name "$function_name" '.Functions[] | select(.FunctionName == $function_name) | .Runtime' functions.json)

    # Append data to the CSV file
    echo "$function_name,$function_runtime,$function_architectures" >> $csv_file
done

# Clean up the temporary file
rm functions.json
