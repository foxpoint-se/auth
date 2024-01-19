SHELL = /bin/bash

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help

.PHONY: add-user
add-user:		## print instructions on how to add user to pool
	@echo "Call like this: ./scripts/add-user.sh <USERNAME> <PASSWORD> <EMAIL>"

.PHONY: setup-deploy
setup-deploy:
	cd deploy && yarn

.PHONY: setup
setup: setup-deploy		## install and setup everything for development

.PHONY: cdk-deploy-server
cdk-deploy-server:
	cd deploy && yarn cdk deploy

.PHONY: cdk-diff-server
cdk-diff-server:
	cd deploy && yarn cdk diff

.PHONY: diff
diff: setup cdk-diff-server		## cdk diff

.PHONY: deploy
deploy: setup cdk-deploy-server		## deploy everything

.PHONY: destroy-everything
destroy-everything: setup		## destroy everything
	cd deploy && yarn cdk destroy
