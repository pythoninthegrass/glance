# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This project uses Task (Taskfile) for task automation:

- `task` or `task default` - Lists all available tasks
- `task debug` - Shows debugging information including environment variables
- `task deploy` - Deploys glance using Ansible playbook
- `task install-devbox` - Installs devbox tool (runs once)

## Environment Setup

- Copy `.env.example` to `.env` and configure required environment variables:
  - `REDDIT_APP_NAME`, `REDDIT_APP_CLIENT_ID`, `REDDIT_APP_SECRET` - For Reddit widgets
  - `GITHUB_TOKEN` - For GitHub releases widget
  - `MY_SECRET_TOKEN` - Custom token (example shows 123456)
  - `WORKING_DIR` - Directory for deployment

## Architecture

This is a Glance dashboard configuration repository with deployment automation:

### Configuration Structure

- `config/glance.yml` - Main Glance configuration file that includes other page configs
- `config/home.yml` - Primary dashboard page with widgets (RSS, weather, markets, Reddit, videos, etc.)
- `config/*.yml` - Additional specialized widget configurations (reddit, releases, rss, stock_market, twitch, videos, widgets)

### Deployment

- Uses Ansible for automated deployment to remote servers
- `deploy.yml` - Ansible playbook that syncs files to remote server and deploys via Uncloud
- `hosts` - Ansible inventory with server configurations
- `compose.yml`/`docker-compose.yml` - Docker Compose configuration for Glance container

### Widget Configuration

Glance widgets are configured in YAML files using environment variable substitution (e.g., `${GITHUB_TOKEN}`). The main dashboard includes:

- RSS feeds, weather, stock markets, Twitch channels
- YouTube channels via video IDs
- Reddit subreddits with app authentication
- GitHub release tracking

The configuration uses YAML anchors and references (`&reddit-props`, `<<: *reddit-props`) for reusable widget properties.

## Development Guidelines

- Use these tools for linting and formatting
  - editorconfig 
  - `markdownlint -c .markdownlint.jsonc` 
  - `ansible-lint`
  - ALWAYS add an EOF (trailing newline) regardless of extension
- Test reddit app configuration on remote server via
    ```bash 
    CONTAINER_ID=$(docker ps --filter "name=glance-" --format '{{.ID}}')
    CLIENT_ID=$(docker exec $CONTAINER_ID printenv REDDIT_APP_CLIENT_ID)
    CLIENT_SECRET=$(docker exec $CONTAINER_ID printenv REDDIT_APP_SECRET)
    curl -X POST https://www.reddit.com/api/v1/access_token \
        -H "User-Agent: glance/1.0" \
        -u "$CLIENT_ID:$CLIENT_SECRET" \
        -d "grant_type=client_credentials"
    ```

## Documentation URLs

- <https://github.com/glanceapp/glance>
- <https://github.com/psviderski/uncloud>
- <https://github.com/psviderski/uncloud-dns>
- <https://github.com/psviderski/unregistry>
- <https://docs.dnscontrol.org/>
- <https://docs.ansible.com/>
- <https://taskfile.dev/>

## Memories

- vps is running debian 12
- uc uses compose.yml; notably with the custom x-ports directive
- volumes were created on the vps via `uc volume`:
  - `uc volume create glance_config` 
  - `uc volume create glance_assets` 
