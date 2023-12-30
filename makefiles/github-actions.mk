#-## Create/replace GitHub Actions from template

#- Placeholders require include the file in the Makefile
#- require - bool64/dev/release-assets

GO ?= go

GITHUB_PATH ?= .github

# GITHUB_PATH_IGNORE is used to ignore files in .github folder on tests
GITHUB_PATH_IGNORE ?= false

#-## Require a bool64/dev/release-assets

## Create/Replace GitHub Actions from template
github-actions:
	@echo "Generating GitHub Actions"
	@mkdir -p $(PWD)/$(GITHUB_PATH)/workflows
	@if [ -n "$$(find "$(PWD)/$(GITHUB_PATH)/workflows" -name '*.yml' -print -quit)" ]; then \
		chmod +w "$(PWD)/$(GITHUB_PATH)/workflows"/*.yml; \
		if [ $$? -ne 0 ]; then \
            echo "could not chmod +w existing workflows"; \
        fi; \
	fi
	@rsync -aq --exclude='release-assets.yml' $(EXTEND_DEVGO_PATH)/templates/github/workflows/*.yml $(PWD)/$(GITHUB_PATH)/workflows/ \
		&& chmod +w $(PWD)/$(GITHUB_PATH)/workflows/*.yml \
		&& mkdir -p $(PWD)/$(GITHUB_PATH)/actions
	@if [ -n "$$(find "$(PWD)/$(GITHUB_PATH)/actions" -name '*.yml' -print -quit)" ]; then \
		chmod +w "$(PWD)/$(GITHUB_PATH)/actions"/*.yml; \
		if [ $$? -ne 0 ]; then \
            echo "could not chmod +w existing actions"; \
        fi; \
	fi
	@rsync -aq --exclude='*.go' $(EXTEND_DEVGO_PATH)/templates/github/actions/ $(PWD)/$(GITHUB_PATH)/actions/ \
		&& chmod +w $(PWD)/$(GITHUB_PATH)/actions/*/* && chmod +x $(PWD)/$(GITHUB_PATH)/actions/*/*.sh
	@if [ "$(GITHUB_PATH_IGNORE)" != "true" ]; then \
		git add $(PWD)/$(GITHUB_PATH)/workflows && \
		git add $(PWD)/$(GITHUB_PATH)/actions; \
	fi
	@echo "Some of the actions require secrets \`PAT\` to be set in the repository settings."


## Create/Replace GitHub Actions from template for release-assets
github-actions-release-assets: github-actions
	@echo "Generating GitHub Actions for release-assets"
	@cp $(EXTEND_DEVGO_PATH)/templates/github/workflows/release-assets.yml $(PWD)/$(GITHUB_PATH)/workflows/ \
			&& chmod +w $(PWD)/$(GITHUB_PATH)/workflows/release-assets.yml
	@if [ "$(GITHUB_PATH_IGNORE)" != "true" ]; then \
		git add $(PWD)/$(GITHUB_PATH)/workflows/release-assets.yml; \
	fi
	@echo "Some of the actions require secrets \`PAT\` to be set in the repository settings."

.PHONY: github-actions github-actions-release-assets
