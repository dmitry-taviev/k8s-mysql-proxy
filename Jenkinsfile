node {
    slackSend("[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Pipeline started!")

    try {
        stage 'checkout'
        slackSend("[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Checking out..")
        checkout scm
        slackSend color: 'good', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] App is ready for packaging"

        stage 'build & push image'
        slackSend("[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Building new Docker image..")
        def service = env.JOB_NAME
        def region = 'eu-west-1'
        def repoName = "apply/smart-${service}"
        try {
            sh("aws ecr create-repository --repository-name ${repoName} --region ${region}")
        } catch (e) {}
        def dockerRepo = "944590742144.dkr.ecr.${region}.amazonaws.com/${repoName}"
        def img = docker.build("${dockerRepo}:build-${env.BUILD_NUMBER}")
        img.push()
        slackSend color: 'good', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] New image: ${img.id}"

        def rc = 'mysql'

        stage 'deploy service to qa'
        slackSend("[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Deploying to DEV environment..")
        try {
            sh("kubectl rolling-update ${rc} --namespace=dev --image=${img.id}")
            slackSend color: 'good', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Deployed!"
        } catch (failure) {
            slackSend color: 'danger', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Failed to update service, rolling back.."
            sh("kubectl rolling-update ${rc} --namespace=dev --rollback")
            slackSend color: 'danger', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Deploy failed."
            return
        }
        slackSend color: 'good', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Please <${env.BUILD_URL}input|approve> this build to continue!"
        try {
            timeout(time:1, unit:'DAYS') {
                input 'Do you approve this build?'
            }
        } catch (abort) {
            slackSend color: 'danger', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Pipeline aborted."
            return
        }

		stage 'deploy service to production'
        slackSend("[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Deploying to Production..")
        img.push('latest')
        try {
            sh("kubectl rolling-update ${rc} --namespace=default --image=${img.id}")
        } catch (failure) {
            slackSend color: 'danger', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Failed to update service, rolling back.."
            sh("kubectl rolling-update ${rc} --namespace=default --rollback")
        }

    } catch (e) {
        slackSend color: 'danger', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Pipeline failed: ${e}"
        error(e.getMessage())
    }

    slackSend color: 'good', message: "[<${env.BUILD_URL}|${env.JOB_NAME}:${env.BUILD_NUMBER}>] Pipeline finished!"
}