.PHONY: validate fmt dev-plan test-plan prod-plan

fmt:
	terraform fmt -recursive

validate:
	powershell -ExecutionPolicy Bypass -File scripts/validate-all.ps1

dev-plan:
	cd environments/dev && terraform plan -out=dev.tfplan

test-plan:
	cd environments/test && terraform plan -out=test.tfplan

prod-plan:
	cd environments/prod && terraform plan -out=prod.tfplan