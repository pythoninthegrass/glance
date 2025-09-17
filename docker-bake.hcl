// Variables with defaults that can be overridden
variable "REGISTRY" {
  default = "ghcr.io"
}

variable "IMAGE_NAME" {
  default = "glance"
}

variable "TAG" {
  default = "latest"
}

// Environment variables for build arguments
variable "FQDN" {
  default = "$FQDN"
}

variable "GITHUB_TOKEN" {
  default = "$GITHUB_TOKEN"
}

variable "REDDIT_APP_NAME" {
  default = "$REDDIT_APP_NAME"
}

variable "REDDIT_APP_CLIENT_ID" {
  default = "$REDDIT_APP_CLIENT_ID"
}

variable "REDDIT_APP_CLIENT_SECRET" {
  default = "$REDDIT_APP_CLIENT_SECRET"
}

variable "MY_SECRET_TOKEN" {
  default = "$MY_SECRET_TOKEN"
}

// Base target with shared configuration
target "docker-metadata-action" {
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:${TAG}",
    "${REGISTRY}/${IMAGE_NAME}:latest",
  ]
}

// Default target that extends the base
target "build" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  // Build arguments from environment variables
  args = {
    FQDN = FQDN
    GITHUB_TOKEN = GITHUB_TOKEN
    REDDIT_APP_NAME = REDDIT_APP_NAME
    REDDIT_APP_CLIENT_ID = REDDIT_APP_CLIENT_ID
    REDDIT_APP_CLIENT_SECRET = REDDIT_APP_CLIENT_SECRET
    MY_SECRET_TOKEN = MY_SECRET_TOKEN
  }
  // Secrets for build-time access (not embedded in image)
  secret = [
    "id=_env,src=.env"
  ]
  // Output image will be pushed if push=true is set in GitHub Actions
}

// Group target to build both platforms
group "default" {
  targets = ["build"]
}

// Optional specific targets for each platform if needed
target "amd64" {
  inherits = ["build"]
  platforms = ["linux/amd64"]
  cache-from = ["type=gha,scope=linux/amd64"]
  cache-to = ["type=gha,mode=max,scope=linux/amd64"]
}

target "arm64" {
  inherits = ["build"]
  platforms = ["linux/arm64"]
  cache-from = ["type=gha,scope=linux/arm64"]
  cache-to = ["type=gha,mode=max,scope=linux/arm64"]
  // Optional arm64-specific args
  args = {
    OPENBLAS_NUM_THREADS = "1"
    MKL_NUM_THREADS = "1"
    NUMEXPR_NUM_THREADS = "1"
  }
}

// Development build with secrets
target "dev" {
  inherits = ["build"]
  tags = ["${REGISTRY}/${IMAGE_NAME}:dev"]
  secret = [
    "id=_env,src=.env"
  ]
}

// Production build with external secrets
target "prod" {
  inherits = ["build"]
  tags = ["${REGISTRY}/${IMAGE_NAME}:prod"]
  secret = [
    "id=github_token,env=GITHUB_TOKEN",
    "id=reddit_client_id,env=REDDIT_APP_CLIENT_ID",
    "id=reddit_secret,env=REDDIT_APP_CLIENT_SECRET",
    "id=my_secret,env=MY_SECRET_TOKEN"
  ]
}

// Matrix build target if you prefer to use it directly in bake
target "multi-platform" {
  inherits = ["build"]
  platforms = ["linux/amd64", "linux/arm64"]
}
