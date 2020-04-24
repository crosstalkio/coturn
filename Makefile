GOFILES := go.mod $(wildcard *.go) $(wildcard */*.go) $(wildcard */*/*.go)

all:
	go build .

include .make/golangci-lint.mk
include .make/docker.mk

tidy:
	go mod tidy

lint: $(GOLANGCI_LINT)
	$(realpath $(GOLANGCI_LINT)) run

clean: clean/golangci-lint
	rm -f go.sum

test: # -count=1 disables cache
	go test -v -race -count=1 .

.PHONY: all tidy clean test
