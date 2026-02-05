# Install tools required by pre-commit hooks
.PHONY: install-hooks-tools
install-hooks-tools: ## Install pre-commit, semgrep, ggshield, and set up hooks if not present
	if ! command -v pre-commit >/dev/null 2>&1; then \
	  brew install pre-commit || echo "[WARNING] Could not install pre-commit with brew. Please install manually if needed."; \
	else \
	  echo "pre-commit already installed."; \
	fi
	if ! command -v semgrep >/dev/null 2>&1; then \
	  brew install semgrep || echo "[WARNING] Could not install semgrep with brew. Please install manually if needed."; \
	else \
	  echo "semgrep already installed."; \
	fi
	if ! command -v ggshield >/dev/null 2>&1; then \
	  brew install gitguardian/tap/ggshield || echo "[WARNING] Could not install ggshield with brew. Please install manually if needed."; \
	else \
	  echo "ggshield already installed."; \
	fi
	pre-commit install
	echo "pre-commit, semgrep, and ggshield installed (if needed). Pre-commit hooks installed."
# Jekyll development commands
.PHONY: serve build install clean help

# Set Ruby environment - uses Homebrew Ruby 3.3
RUBY_ENV := PATH="/opt/homebrew/opt/ruby@3.3/bin:$$PATH"

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install Jekyll dependencies
	$(RUBY_ENV) bundle install

serve: ## Start Jekyll development server with live reload
	$(RUBY_ENV) bundle exec jekyll serve --livereload

build: ## Build the site for production
	$(RUBY_ENV) bundle exec jekyll build

clean: ## Clean built files
	$(RUBY_ENV) bundle exec jekyll clean
	rm -rf _site

update: ## Update Jekyll dependencies
	$(RUBY_ENV) bundle update

check: ## Check for broken links and other issues
	$(RUBY_ENV) bundle exec jekyll doctor

# Default target
.DEFAULT_GOAL := serve