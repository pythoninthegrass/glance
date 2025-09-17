# syntax=docker/dockerfile:1.17.1
# check=skip=all

FROM glanceapp/glance:latest

WORKDIR /app

COPY ./config/ /app/config/
COPY ./assets/ /app/assets/

EXPOSE 8080

ENTRYPOINT ["/app/glance"]
CMD ["--config", "/app/config/glance.yml"]
