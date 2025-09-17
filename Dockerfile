# syntax=docker/dockerfile:1.5

FROM glanceapp/glance:latest

# Copy and source .env file during build (secrets available at build time)
RUN --mount=type=secret,id=_env,dst=/tmp/.env \
    cp /tmp/.env /app/.env && \
    # Source the .env file to set environment variables during build
    . /app/.env && \
    echo "Build-time secrets loaded"

# Set environment variables from secrets (these will be embedded in image)
ARG FQDN
ARG GITHUB_TOKEN
ARG REDDIT_APP_NAME
ARG REDDIT_APP_CLIENT_ID
ARG REDDIT_APP_CLIENT_SECRET
ARG MY_SECRET_TOKEN

ENV FQDN=${FQDN:-popurls.xyz}
ENV GITHUB_TOKEN=${GITHUB_TOKEN}
ENV REDDIT_APP_NAME=${REDDIT_APP_NAME:-glance}
ENV REDDIT_APP_CLIENT_ID=${REDDIT_APP_CLIENT_ID}
ENV REDDIT_APP_CLIENT_SECRET=${REDDIT_APP_CLIENT_SECRET}
ENV MY_SECRET_TOKEN=${MY_SECRET_TOKEN}

WORKDIR /app

COPY ./config/ /app/config/
COPY ./assets/ /app/assets/

EXPOSE 8080

ENTRYPOINT ["/app/glance"]
CMD ["--config", "/app/config/glance.yml"]
