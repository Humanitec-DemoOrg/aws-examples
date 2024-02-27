source "./scripts/helper_wait_for_deployment.sh"
source "./scripts/helper_clone_environment.sh"

export HUMANITEC_ENV=development
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP \
--env $HUMANITEC_ENV -f score.yaml --deploy
humanitec_wait_for_deployment


TARGET_ENVIRONMENT_TYPE=production # existing environment TYPE (not name) https://app.humanitec.io/orgs/$HUMANITEC_ORG/environment-types
TARGET_ENVIRONMENT=production  # new environment NAME (not environment type)
SOURCE_ENVIRONMENT=development # existing environment NAME
humanitec_clone_environment

export HUMANITEC_ENV=production
score-humanitec delta --token $HUMANITEC_TOKEN --org $HUMANITEC_ORG --app $HUMANITEC_APP \
--env $HUMANITEC_ENV -f score.yaml --deploy
humanitec_wait_for_deployment