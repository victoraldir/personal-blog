.PHONY: publish build

publish: build
	@echo "Publishing web..."
	@cd public && aws s3 sync . s3://$(shell cd infra && terraform output bucket_name)
	@echo "Invalidating CloudFront cache..."
	@aws cloudfront create-invalidation --distribution-id $(shell cd infra && terraform output distribution_id) --paths "/*" --no-cli-pager
	@echo "Done publishing web."

build:
	@echo "Building web..."
	@hugo --minify
	@echo "Done building web."

run-local:
	@echo "Running web locally..."
	@hugo server --minify --buildDrafts --buildFuture
	@echo "Done running web locally."

plan-infra:
	@echo "Planning infrastructure..."
	@cd infra && terraform init && terraform plan
	@echo "Done planning infrastructure."

validate-infra:
	@echo "Validating infrastructure..."
	@cd infra && terraform init && terraform validate
	@echo "Done validating infrastructure."

init-infra:
	@echo "Initializing infrastructure..."
	@cd infra && terraform init
	@echo "Done initializing infrastructure."

format-infra:
	@echo "Formatting infrastructure..."
	@cd infra && terraform init && terraform fmt
	@echo "Done formatting infrastructure."

deploy-infra:
	@echo "Deploying infrastructure..."
	@cd infra && terraform init && terraform apply -auto-approve
	@echo "Done deploying infrastructure."

destroy-infra:
	@echo "Destroying infrastructure..."
	@cd infra && terraform init && terraform destroy -auto-approve
	@echo "Done destroying infrastructure."