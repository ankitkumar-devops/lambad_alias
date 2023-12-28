#!/bin/bash

# # Assuming the input parameter contains Lambda function names separated by commas
# #input_parameter="function1,function2,function3"

input_parameter="dev-ewb-delivery-details"

# Convert the comma-separated string into an array
IFS=',' read -ra function_names <<< "$input_parameter"

# AWS region
region="ap-south-1"

# Iterate through the array of function names
for function_name in "${function_names[@]}"; do
    # Create alias name by appending '-alias'
    alias_name="${function_name}-alias"

    # Check if the alias already exists
    alias_exists=$(aws lambda get-alias --function-name "$function_name" --name "$alias_name" --region "$region" 2>/dev/null)

    if [ -z "$alias_exists" ]; then
       # Alias does not exist, create it
       aws lambda create-alias --function-name "$function_name" \
           --name "$alias_name" \
           --function-version '$LATEST' \
           --region "$region"

       echo "Alias $alias_name created for function $function_name."
    else
       echo "Alias $alias_name already exists for function $function_name. Skipping."
    fi

    # Optionally, you can add some sleep time between API calls if needed
    # sleep 1
done
