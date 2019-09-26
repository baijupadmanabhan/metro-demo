FROM golang:1.12.0-alpine3.9
RUN mkdir /app
ADD /metro-demo/Golang/main.go /app/main.go
WORKDIR /app
RUN go build -o main .
CMD ["/app/main"]