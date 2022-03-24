FROM golang:latest AS go-builder

WORKDIR /usr/src/app
COPY . ./

RUN go build -o main main.go

FROM golang:latest AS go-runner

WORKDIR /usr/src/app
COPY --from=go-builder /usr/src/app ./

CMD ["./main"]