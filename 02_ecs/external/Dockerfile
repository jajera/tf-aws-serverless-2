FROM node:current-alpine

LABEL org.opencontainers.image.title="App1!" \
      org.opencontainers.image.description="Demo application"

RUN mkdir -p /usr/src/app1

COPY ./app1 /usr/src/app1

WORKDIR /usr/src/app1

RUN npm install

RUN apk --no-cache add curl
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost:8080 || exit 1

RUN adduser -D demouser

USER demouser

ENTRYPOINT [ "node", "app.js" ]