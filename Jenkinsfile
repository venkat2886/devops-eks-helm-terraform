pipeline {
  agent any

  triggers {
    githubPush()
  }

  environment {
    AWS_REGION   = "us-east-1"
    CLUSTER_NAME = "sandbox-devops-eks"
    APP_NAME     = "sample-app"
    NAMESPACE    = "default"
    ECR_REPO     = "132501409694.dkr.ecr.us-east-1.amazonaws.com/sandbox-devops-sample-app"
  }

  stages {
    stage("Checkout") {
      steps { checkout scm }
    }

    stage("AWS Auth Check") {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'aws-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
            aws sts get-caller-identity
          '''
        }
      }
    }

    stage("Build Docker Image") {
      steps {
        sh '''
          docker build -t ${ECR_REPO}:${BUILD_NUMBER} .
        '''
      }
    }

    stage("Push to ECR + Deploy to EKS") {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'aws-creds',
          usernameVariable: 'AWS_ACCESS_KEY_ID',
          passwordVariable: 'AWS_SECRET_ACCESS_KEY'
        )]) {
          sh '''
            export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
            export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

            aws ecr get-login-password --region ${AWS_REGION} \
              | docker login --username AWS --password-stdin ${ECR_REPO}

            docker push ${ECR_REPO}:${BUILD_NUMBER}

            aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

            helm upgrade --install ${APP_NAME} ./charts/sample-app \
              --namespace ${NAMESPACE} --create-namespace \
              --set image.repository=${ECR_REPO} \
              --set image.tag=${BUILD_NUMBER} \
              --wait --timeout 5m

            kubectl get pods -n ${NAMESPACE}
          '''
        }
      }
    }
  }
}