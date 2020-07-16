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
        def registry = "docker.io"
	def registryCredential = "dockerhub-leeyj7141"
        def githubCredential = "github-leeyj7141"

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
                 withDockerRegistry([ credentialsId: "$registryCredential", url: "http://$registry" ]) {
                     sh "docker build -t leeyj7141/centos-httpd:${env.BUILD_ID} -f ./Dockerfile ."
                 }
             }
         }


         stage('Push docker image') {
             container('docker') {
                 //docker.withRegistry("http://$registry", "$registryCredential") {
                 //    def customImage = docker.build("leeyj7141/centos-httpd:${env.BUILD_ID}")
                 //    /* Push the container to the custom Registry */
                 //    customImage.push()
                 //}
                 withDockerRegistry([ credentialsId: "$registryCredential", url: "https://$registry" ]) {
                     //docker.image("leeyj7141/centos-httpd:${env.BUILD_ID}").push()
                     // sh "docker images"
                     sh "docker push leeyj7141/centos-httpd:${env.BUILD_ID}"
                 }
             }
         }
    }   
}
