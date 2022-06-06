pipeline{
    agent none
    tools{
        jdk 'myjava'
        maven 'mymaven'
    }
    environment{
        IMAGE_NAME ='devopstrainer/java-mvn-privaterepos:$BUILD_NUMBER'
        BUILD_SERVER_IP ='ec2-user@3.110.40.103'
       
        }

    stages{
        stage("COMPILE"){
            agent any
            steps{
                script{
                  echo "COMPILIG THE CODE"
                  sh 'mvn compile'
                }
            }
        }
        stage("UNITTEST"){
            //agent {label 'linux_slave'}
            agent any
         steps{
           script{
               echo "Testing THE CODE"
                sh 'mvn test'
                }
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage("PACKAGE+BUILD THE DOCKER IMAGE"){
            agent any
            steps{
            script{
                echo "Packaging THE CODE"
                sshagent(['BUILD_SERVER_KEY']) {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER_IP}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER_IP} 'bash ~/server-script.sh'"
                sh "ssh ${BUILD_SERVER_IP} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/addressbook"
                sh "ssh ${BUILD_SERVER_IP} sudo docker login -u $USERNAME -p $PASSWORD"
                sh "ssh ${BUILD_SERVER_IP} sudo docker push ${IMAGE_NAME}"
                }
                }
            }
        }
        }
    stage("TF will provison deploy server"){
        steps{
            script{
                dir('terraform'){
                sh "terraform init"
                sh "terraform apply  --auto-approve"
                EC2_PUBLIC_IP=sh(
                    script: "terraform output ec2-ip",
                    returnStdout: true
                ).trim()
            }
        }
    }
    }
    stage("Deploy the docker image"){
    agent any
        steps{
            script{
                sleep(time:90,unit: "SECONDS")
                echo "${EC2_PUBLIC_IP}"
                sshagent(['BUILD_SERVER_KEY']) {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
               sh "ssh-o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} sudo docker login -u $USERNAME -p $PASSWORD"
                sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker run -itd -p 8000:8080 ${IMAGE_NAME}"
                    }
                         }
                }
            }
                 }
    }
}