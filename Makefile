include .env

ws = $(SHORT_USERNAME)

.SILENT:

tf-init:
	terraform -chdir=terraform init
apply:
	vajeh deploy --workspace $(ws)
plan:
	vajeh deploy --dryrun --workspace $(ws)
destroy:
	vajeh deploy --destroy --workspace $(ws)

