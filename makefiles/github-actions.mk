#-## Create/replace GitHub Actions from template

#- Placeholders require include the file in the Makefile
#- require - bool64/dev/release-assets

GO ?= go

GITHUB_PATH ?= .github

# GITHUB_PATH_IGNORE is used to ignore files in .github folder on tests
GITHUB_PATH_IGNORE ?= false

# GITHUB_ACTIONS_RELEASE_ASSETS is used to create release-assets.yml
GITHUB_ACTIONS_RELEASE_ASSETS ?= false

#- target-group - BEFORE_GITHUB_ACTIONS_TARGETS:github-actions
BEFORE_GITHUB_ACTIONS_TARGETS :=
#- target-group - GITHUB_ACTIONS_TARGETS:github-actions
GITHUB_ACTIONS_TARGETS := "github-actions-base"
#- target-group - AFTER_GITHUB_ACTIONS_TARGETS:github-actions
AFTER_GITHUB_ACTIONS_TARGETS :=

## Run all github-actions belonging to github-actions group
github-actions:
	@echo "Generating/Replacing GitHub Actions..."
	@for target in $(BEFORE_GITHUB_ACTIONS_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target || exit 1; \
	done

	@for target in $(GITHUB_ACTIONS_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target || exit 1; \
	done

	@if [ "$(GITHUB_ACTIONS_RELEASE_ASSETS)" = "true" ]; then \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) github-actions-release-assets; \
	fi

	@for target in $(AFTER_GITHUB_ACTIONS_TARGETS); do \
		make -f $(MAKEFILE_FILE) -e PLUGIN_MANIFEST_FILE=$(PLUGIN_MANIFEST_FILE) $$target || exit 1; \
	done

## Create/Replace GitHub Actions from template
github-actions-base:
	@echo "Generating GitHub Actions base..."
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
		chmod +w "$(PWD)/$(GITHUB_PATH)/actions"/*/*.yml; \
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
github-actions-release-assets:
	@echo "Generating GitHub Actions for release-assets"
	@mkdir -p $(PWD)/$(GITHUB_PATH)/workflows
	@cp $(EXTEND_DEVGO_PATH)/templates/github/workflows/release-assets.yml $(PWD)/$(GITHUB_PATH)/workflows/ \
			&& chmod +w $(PWD)/$(GITHUB_PATH)/workflows/release-assets.yml
	@if [ "$(GITHUB_PATH_IGNORE)" != "true" ]; then \
		git add $(PWD)/$(GITHUB_PATH)/workflows/release-assets.yml; \
	fi
	@echo "Some of the actions require secrets \`PAT\` to be set in the repository settings."

## Create/Replace GitHub dependabot from template for dependabot
github-dependabot:
	@echo "Generating GitHub dependabot"
	@mkdir -p $(PWD)/$(GITHUB_PATH)
	@cp $(EXTEND_DEVGO_PATH)/templates/github/dependabot.yml $(PWD)/$(GITHUB_PATH)/ \
			&& chmod +w $(PWD)/$(GITHUB_PATH)/dependabot.yml
	@if [ "$(GITHUB_PATH_IGNORE)" != "true" ]; then \
		git add $(PWD)/$(GITHUB_PATH)/dependabot.yml; \
	fi

.PHONY: github-actions github-actions-release-assets github-dependabot
