podTemplate(label: 'jenkins-slave-pod', 
  containers: [
    containerTemplate(
      name: 'git',
      image: 'alpine/git',
      command: 'cat',
      ttyEnabled: true
    ),
    containerTemplate(
      name: 'node',
      image: 'node:8.16.2-alpine3.10',
      command: 'cat',
      ttyEnabled: true
    ),
    containerTemplate(
      name: 'docker',
      image: 'docker',
      command: 'cat',
      ttyEnabled: true
    ),
  ],
  volumes: [ 
    hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock'), 
  ]
)

{
    node('jenkins-slave-pod') { 
        def registry = "10.100.0.174:5000"
        def githubCredential = "github-leeyj7141"
	//def registryCredential = "dockerhub-leeyj7141"

        // https://jenkins.io/doc/pipeline/steps/git/
        stage('Clone repository') {
            container('git') {
                // https://gitlab.com/gitlab-org/gitlab-foss/issues/38910
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [
                        [url: 'https://github.com/leeyj7141/cicd-test.git', credentialsId: "$githubCredential"]
                    ],
                ])
            }
        }
        
         stage('Build docker image') {
             container('docker') {
                 docker.withRegistry("http://$registry") {
                     sh "docker build -t leeyj7141/centos-httpd:${env.BUILD_ID} -f ./Dockerfile ."
                 }
             }
         }

         stage('Push docker image') {
             container('docker') {
                 docker.withRegistry("http://$registry") {
                     def customImage = docker.build("leeyj7141/centos-httpd:${env.BUILD_ID}")
                     customImage.push()
                 }
             }
         }
         stage('Set ENV') {
             container('node') {
                   sh ''' 
                    echo "---
BUILD_NUMBER: ${BUILD_NUMBER}
BUILD_TAG: ${BUILD_TAG}
BUILD_ID: ${BUILD_ID}
GIT_BRANCH: ${GIT_BRANCH}
GIT_COMMIT: ${GIT_COMMIT}
GIT_URL: ${GIT_URL}
JOB_NAME: ${JOB_NAME}
JOB_URL: ${JOB_URL}
                    " > trproperties.yml '''
             }
         }

         stage('Create ReplicaSet File') {
             container('node') {
                   sh ''' 
                    echo "---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  namespace: test
  name: webserver-test
  labels:
    tire: webserver-test
  annotations:
    strategy.spinnaker.io/max-version-history: 4
    traffic.spinnaker.io/load-balancers: '["service test-webserver-service"]'
spec:
  replicas: 3
  selector:
    matchLabels:
      tire: webserver-test
  template:
    metadata:
      labels:
        tire: webserver-test
    spec:
      containers:
      - name: mywebserver-test
        image: 10.100.0.174:5000/leeyj7141/centos-httpd:${BUILD_NUMBER}
        ports:
          - containerPort: 80
" > replica.yml '''
             }
         }
         stage('List files ') {
             container('node') {
                   sh ' ls -l  '
             }
         }
         stage('Git push') {
             container('git') {
                withCredentials([usernamePassword(credentialsId: "github-http-auth", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh('git config --global user.email "yjlee@linux.com"')
                    sh('git config --global user.name "youngju LEE"')
                    sh('git branch spinnaker')
                    sh('git checkout spinnaker')
                    sh('git add trproperties.yml')
                    sh('git add replica.yml')
                    sh('git commit -m "Jenkins build $BUILD_ID th"')
                    sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/leeyj7141/spinnaker-test.git spinnaker -f')
                }
             }
         }
    }   
}
