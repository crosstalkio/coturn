GOFILES := go.mod $(wildcard *.go) $(wildcard */*.go) $(wildcard */*/*.go)

all:
	go build .

tidy:
	go mod tidy

clean:
	rm -f go.sum

test: # -count=1 disables cache
	go test -v -race -count=1 .

.PHONY: all tidy clean test

include .make/lint.mk
include .make/docker.mk
