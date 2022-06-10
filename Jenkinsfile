pipeline{
    agent none
    tools{
        jdk 'myjava'
        maven 'mymaven'
    }
    environment{
        IMAGE_NAME ='devopstrainer/java-mvn-privaterepos:$BUILD_NUMBER'
        BUILD_SERVER_IP ='ec2-user@43.204.235.75'
        ACM_IP='ec2-user@65.0.99.34'
        AWS_ACCESS_KEY_ID=credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
        DOCKER_REG_PASSWORD=credentials("DOCKER_REG_PASSWORD")
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
        environment{
            AWS_ACCESS_KEY_ID=credentials("AWS_ACCESS_KEY_ID")
            AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
        }
        agent any
        steps{
            script{
                dir('terraform'){
                sh "terraform init"
                sh "terraform apply  --auto-approve"
                ANISBLE_TARGET_PUBLIC_IP=sh(
                    script: "terraform output ec2_public_ip",
                    returnStdout: true
                ).trim()
                echo "${ANISBLE_TARGET_PUBLIC_IP}"
            }
        }
    }
    }
    stage("Run the ansible Playbook"){
    agent any
        steps{
            script{
                sleep(time:90,unit: "SECONDS")
                echo "${ANISBLE_TARGET_PUBLIC_IP}"
                sshagent(['BUILD_SERVER_KEY']) {
                sh "scp -o  StrictHostKeyChecking=no ansible/* ${ACM_IP}:/home/ec2-user"      
        withCredentials([sshUserPrivateKey(credentialsId: 'BUILD_SERVER_KEY', keyFileVariable: 'keyfile', usernameVariable: 'user')]) {
        sh "scp $keyfile ${ACM_IP}:/home/ec2-user/.ssh/id_rsa"
sh "ssh -o StrictHostKeyChecking=no ${ACM_IP} bash /home/ec2-user/prepare-ACM.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${DOCKER_REG_PASSWORD} ${IMAGE_NAME}"  
         }

    }
}

    }
    }
}