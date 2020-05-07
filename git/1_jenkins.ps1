# jenkins is a CI|CD utlility that lets you run powershell scripts in conjunction with git events.
# you can configure triggers to execute your scripts whenever there's a new commit for example.
# Jenkins has some images that you can use to host a Jenkins server. If you want to run powershell though, you'll have to do one of the following:
# * register a build agent onto your jenkins server that can run powershell
# * allow jenkins to run nested containers that contain powershell images
# * install powershell on the jenkins image, or vice versa.
# we're going to run jenkins locally and use our computer as a build agent.

# you can download jenkins for windows online at http://mirrors.jenkins-ci.org/windows-stable/latest
# after running setup, go to localhost:8080 to access your local jenkins setup.

# setup a pipeline that authenticates into your github account and use the git clone URL for your pipeline.
# create a file named Jenkinsfile and add this as content
pipeline {
    agent any
    stages {
        stage('run') {
            steps {
                powershell '.\\script.ps1'
            }
        }
    }
}

# create a script named script.ps1 and add this content
$services = get-service
foreach ($service in $services) {
    $service
}

# create a pipeline trigger that checks for new github builds every 60 seconds