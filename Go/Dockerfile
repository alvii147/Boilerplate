FROM golang:1.17-alpine AS go-builder

WORKDIR /usr/src/app
COPY . ./

RUN go build -o main main.go

FROM golang:1.17-alpine AS go-runner

WORKDIR /usr/src/app
COPY --from=go-builder /usr/src/app ./

CMD ["./main"]