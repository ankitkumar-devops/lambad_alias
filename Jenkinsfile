pipeline {
  agent any

  environment {
    PATH = "/usr/local/bin:${env.PATH}"
  }

  parameters {
    choice(
      name: 'CLIENT_NAME',
      choices: 'demo1\ndemo2\nALL_DEV',
      description: 'The Lambda will be = dev-irn-{CLIENT_NAME}-csv-json'
    )
  }

  stages {
    stage('checkout') {
      steps {
        script {
          checkout(
            [
              $class: 'GitSCM',
              branches: [
                [name: '*/main']
              ],
              userRemoteConfigs: [
                [credentialsId: 'github_token', url: 'https://github.com/ankitkumar-devops/lambad_alias.git']
              ]
            ]
          )
        }
      }
    }

    stage('Build') {
      steps {
        sh 'zip svc.csv.json.zip lambda_function.py'
        echo "hello world"
      }
    }

    stage('Update traffic Weights?') {
      steps {
        timeout(time: 3, unit: 'MINUTES') {
          script {
            env.traffic_weight = input(
              message: 'Do you want to Update traffic Weight?',
              parameters: [choice(name: 'traffic_weight', choices: 'YES\nNO')]
            )
          }
        }
      }
    }

    stage('Update traffic Weights') {
      when {
        expression {
          env.traffic_weight == "YES"
        }
      }

      steps {
        timeout(time: 3, unit: 'MINUTES') {
          script {
            env.traffic_weight = input(
              message: 'Do you want to Update traffic Weights?',
              parameters: [
                string(defaultValue: '0.10', description: 'Enter the traffic weight for the alias', name: 'traffic_weight')
              ]
            )

            withAWS(credentials: 'aws-cred', region: 'us-east-1') {
              def latest_version = sh(script: "aws lambda list-versions-by-function --region us-east-1 --no-paginate --function-name dev-irn-${params.CLIENT_NAME}-csv-json --query \"Versions[-1].Version\" --output text", returnStdout: true).trim()
              def older_version = sh(script: "aws lambda list-versions-by-function --region us-east-1 --no-paginate --function-name dev-irn-${params.CLIENT_NAME}-csv-json --query \"Versions[-2].Version\" --output text", returnStdout: true).trim()

              sh "aws lambda update-alias --name dev-irn-demo1-csv-json-alias --function-name dev-irn-${params.CLIENT_NAME}-csv-json --function-version ${older_version} --routing-config AdditionalVersionWeights={\"${latest_version}\"=\"${env.traffic_weight}\"}"
            }
          }
        }
      }
    }

    stage('Deploy to DEV?') {
      steps {
        timeout(time: 3, unit: 'MINUTES') {
          script {
            env.DEPLOY_DEV = input(
              message: 'Do you want to deploy to DEV?',
              parameters: [choice(name: 'DEPLOY_DEV', choices: 'YES\nNO')]
            )
          }
        }
      }
    }

    stage('Deploying in DEV') {
      when {
        expression {
          env.DEPLOY_DEV == "YES"
        }
      }

      steps {
        timeout(time: 10, unit: "MINUTES") {
          script {
            env.traffic_weight = input(
              message: 'Do you want to Update traffic Weights?',
              parameters: [string(defaultValue: '0.10', description: 'Enter the traffic weight for the alias', name: 'traffic_weight')]
            )

            echo "${env.CLIENT_NAME}"

            withAWS(credentials: 'aws-cred', region: 'us-east-1') {
              sh "aws s3 cp svc.csv.json.zip s3://code-deployment-package-3a/dev/etl-code/svc.csv.json.${env.BUILD_ID}.zip"

              if (env.CLIENT_NAME != 'ALL_DEV') {
                echo "${env.CLIENT_NAME}"

                sh "aws lambda update-function-code --function-name dev-irn-${env.CLIENT_NAME}-csv-json --s3-bucket code-deployment-package-3a --s3-key dev/etl-code/svc.csv.json.${env.BUILD_ID}.zip --architecture x86_64 --region us-east-1"
                sh "sleep 10s"
                sh "aws lambda publish-version --function-name dev-irn-${env.CLIENT_NAME}-csv-json --region us-east-1"
                //sh "aws lambda --region us-east-1 create-alias --name dev-irn-demo1-csv-json-alias --function-name dev-irn-${params.CLIENT_NAME}-csv-json --function-version 1"
                // def alias_arn = sh(script: "aws lambda --region us-east-1 get-alias --function-name dev-irn-${params.CLIENT_NAME}-csv-json --name dev-irn-demo1-csv-json-alias --query 'AliasArn' --output text", returnStdout: true).trim()
                // echo "Alias ARN: ${alias_arn}"

                // if (!alias_arn) {
                //     echo "Alias not found. Creating..."
                //     sh(script: "aws lambda --region us-east-1 create-alias --name dev-irn-demo1-csv-json-alias --function-name dev-irn-${params.CLIENT_NAME}-csv-json")
                // } else {
                //     echo "Alias 'csv-json' already exists, skipping creation."
                // }

                def latest_version = sh(script: "aws lambda list-versions-by-function --region us-east-1 --no-paginate --function-name dev-irn-${params.CLIENT_NAME}-csv-json --query \"Versions[-1].Version\" --output text", returnStdout: true).trim()
                def older_version = sh(script: "aws lambda list-versions-by-function --region us-east-1 --no-paginate --function-name dev-irn-${params.CLIENT_NAME}-csv-json --query \"Versions[-2].Version\" --output text", returnStdout: true).trim()

                sh "aws lambda update-alias --name dev-irn-demo1-csv-json-alias --function-name dev-irn-${params.CLIENT_NAME}-csv-json --function-version ${older_version} --routing-config AdditionalVersionWeights={\"${latest_version}\"=\"${env.traffic_weight}\"}"

              }
            }
          }
        }
      }
    }
   stage('Delete Old Lambda Function Versions') {
        steps {
            withAWS(credentials: 'aws-cred', region: 'us-east-1') {
                sh 'aws lambda list-versions-by-function --function-name dev-irn-demo1-csv-json --query \'Versions[*].[Version, FunctionArn]\' --output json | jq \'sort_by(.[0]) | reverse | .[5:] | .[] | select(.[0] != "$LATEST") | .[1]\' | xargs -I {} aws lambda delete-function --function-name "{}"'

            }
        }
    }
  }
}


