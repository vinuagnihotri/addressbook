pipeline{
    agent none
    tools{
        jdk 'myjava'
        maven 'mymaven'
    }
    environment{
        SERVER_IP='ec2-user@18.216.181.235'
    }
    stages{
      
        stage("Compile"){
            agent none
         steps{
                echo "COMPILING THE CODE"
                sh 'mvn compile'
            }
        }
        stage("UnitTest"){
            agent any
          steps{
                echo "Run the TC"
                sh 'mvn test'
            }
          post{
            always{
                junit 'target/surefire-reports/*.xml'
            }
          }
        }
        stage("Package"){
            agent any
           steps{
             script{
                sshagent(['jenkins-slave']) {
                 echo "Package the code"
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${SERVER_IP}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${SERVER_IP} 'bash ~/server-script.sh'"     
             }
            
              
               
            }
            
        }
    }
    }
}