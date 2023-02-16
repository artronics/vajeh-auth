include .env

ws = $(SHORT_USERNAME)

.SILENT:

tf_env = AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)

tf_cmd = $(tf_env) terraform -chdir=terraform

tf-init:
	$(tf_cmd) init -backend-config="key=state"
apply:
	vajeh deploy --workspace $(ws)
plan:
	vajeh deploy --dryrun --workspace $(ws)
destroy:
	vajeh deploy --destroy --workspace $(ws)

