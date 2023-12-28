#-## Create/replace GitHub Actions from template

GO ?= go

#-## Require a bool64/dev/release-assets

## Create/Replace GitHub Actions from template
github-actions:
	@echo "Generating GitHub Actions"
	@mkdir -p $(PWD)/.github/workflows && (chmod +w $(PWD)/.github/workflows/*.yml || echo "could not chmod +w existing workflows") \
		&& cp $(EXTEND_DEVGO_PATH)/templates/github/workflows/*.yml $(PWD)/.github/workflows/ \
		&& chmod +w $(PWD)/.github/workflows/*.yml && git add $(PWD)/.github/workflows \
		&& mkdir -p $(PWD)/.github/actions && (chmod +w $(PWD)/.github/actions/* || echo "could not chmod +w existing actions") \
		&& rsync -aq --exclude='*.go' $(EXTEND_DEVGO_PATH)/templates/github/actions/ $(PWD)/.github/actions/ \
		&& chmod +w $(PWD)/.github/actions/* && git add $(PWD)/.github/actions
	@echo "Some of the actions require secrets \`PAT\` to be set in the repository settings."

.PHONY: github-actions
