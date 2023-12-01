
#!/bin/bash

# Read Lambda function names from a file (one function name per line)
while IFS= read -r FUNCTION_NAME
do
  NEW_ALIAS_NAME="${FUNCTION_NAME}-alias"
  aws lambda create-alias --function-name "$FUNCTION_NAME" --function-version "\$LATEST" --name "$NEW_ALIAS_NAME"
done < lambda_function_names.txt
