FROM golang:1.19 AS build-setup

RUN apt-get update \
 && apt-get -y install cmake zip sudo git

RUN mkdir /archive

WORKDIR /archive

# clone repos
COPY . /archive

FROM build-setup AS build-binary

WORKDIR /archive

RUN	--mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build  \
    CGO_ENABLED=1 GOOS=linux go build -o /app --tags "relic,netgo" -ldflags "-extldflags -static" ./cmd/archive-access-api && \
    chmod a+x /app

## Add the statically linked binary to a distroless image
FROM gcr.io/distroless/base-debian11  AS production

COPY --from=build-binary /app /app

EXPOSE 5006

ENTRYPOINT ["/app"]