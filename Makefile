# ─────────────────────────────────────────────────────────────────
#  HNG Stack — Makefile
#  Usage: make <target> [SERVICE=<service>]
# ─────────────────────────────────────────────────────────────────

COMPOSE         := docker compose
SERVICES        := api worker frontend redis
COLOUR_RESET    := \033[0m
COLOUR_BOLD     := \033[1m
COLOUR_GREEN    := \033[32m
COLOUR_YELLOW   := \033[33m
COLOUR_CYAN     := \033[36m

.DEFAULT_GOAL := help
.PHONY: help \
        up down restart \
        up-service down-service restart-service \
        build build-service \
        logs logs-service \
        ps health \
        shell \
        clean nuke

# ── Help ─────────────────────────────────────────────────────────

help: ## Show this help message
	@printf "\n$(COLOUR_BOLD)HNG Stack$(COLOUR_RESET)\n"
	@printf "$(COLOUR_YELLOW)Usage:$(COLOUR_RESET)\n"
	@printf "  make $(COLOUR_GREEN)<target>$(COLOUR_RESET) $(COLOUR_CYAN)[SERVICE=<service>]$(COLOUR_RESET)\n\n"
	@printf "$(COLOUR_YELLOW)Available services:$(COLOUR_RESET)\n"
	@printf "  $(COLOUR_CYAN)api  worker  frontend  redis$(COLOUR_RESET)\n\n"
	@printf "$(COLOUR_YELLOW)Targets:$(COLOUR_RESET)\n"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { \
		printf "  $(COLOUR_GREEN)%-20s$(COLOUR_RESET) %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n$(COLOUR_YELLOW)Examples:$(COLOUR_RESET)\n"
	@printf "  make up                    # bring everything up\n"
	@printf "  make up-service SERVICE=api\n"
	@printf "  make logs-service SERVICE=worker\n"
	@printf "  make shell SERVICE=api\n"
	@printf "  make restart-service SERVICE=frontend\n\n"

# ── Full stack controls ───────────────────────────────────────────

up: ## Build (if needed) and start all services in detached mode
	$(COMPOSE) up --build -d

down: ## Stop and remove all containers (preserves volumes)
	$(COMPOSE) down

restart: ## Restart all services
	$(COMPOSE) restart

build: ## Force rebuild all images without cache
	$(COMPOSE) build --no-cache

# ── Single service controls ───────────────────────────────────────

_check-service:
	@test -n "$(SERVICE)" || (printf "$(COLOUR_YELLOW)SERVICE is required. e.g: make $(MAKECMDGOALS) SERVICE=api$(COLOUR_RESET)\n" && exit 1)
	@echo $(SERVICES) | grep -wq "$(SERVICE)" || \
		(printf "$(COLOUR_YELLOW)Unknown service '$(SERVICE)'. Valid: $(SERVICES)$(COLOUR_RESET)\n" && exit 1)

up-service: _check-service ## Start a single service  [SERVICE=]
	$(COMPOSE) up --build -d $(SERVICE)

down-service: _check-service ## Stop a single service  [SERVICE=]
	$(COMPOSE) stop $(SERVICE)

restart-service: _check-service ## Restart a single service  [SERVICE=]
	$(COMPOSE) restart $(SERVICE)

build-service: _check-service ## Rebuild a single image without cache  [SERVICE=]
	$(COMPOSE) build --no-cache $(SERVICE)

# ── Observability ─────────────────────────────────────────────────

logs: ## Tail logs for all services (Ctrl+C to exit)
	$(COMPOSE) logs -f

logs-service: _check-service ## Tail logs for one service  [SERVICE=]
	$(COMPOSE) logs -f $(SERVICE)

ps: ## Show status of all containers
	$(COMPOSE) ps

health: ## Print health status of every container
	@printf "\n$(COLOUR_BOLD)Container health:$(COLOUR_RESET)\n"
	@docker inspect --format \
		'  {{printf "%-20s" .Name}} {{.State.Health.Status}}' \
		$$($(COMPOSE) ps -q) 2>/dev/null || \
		printf "  No containers running.\n"
	@printf "\n"

# ── Debugging ─────────────────────────────────────────────────────

shell: _check-service ## Open a shell inside a running container  [SERVICE=]
	$(COMPOSE) exec $(SERVICE) sh

# ── Cleanup ───────────────────────────────────────────────────────

clean: ## Stop all containers and remove images for this project
	$(COMPOSE) down --rmi local

nuke: ## ⚠️  Destroy everything: containers, images, volumes, networks
	@printf "$(COLOUR_YELLOW)This will delete all volumes including Redis data. Continue? [y/N] $(COLOUR_RESET)" && \
		read ans && [ "$${ans}" = "y" ] || (printf "Aborted.\n" && exit 1)
	$(COMPOSE) down --rmi all --volumes --remove-orphans
