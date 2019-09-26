FROM golang:1.12.0-alpine3.9
RUN apk update && apk add --no-cache git
RUN mkdir /app
WORKDIR /app
COPY . .
RUN go build -o main .
CMD ["/app/main"]