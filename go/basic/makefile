
all: install



.PHONY: install
install:
	go install

.PHONY: test
test:
	go test ./...

.PHONY: lint
lint:
	gometalinter ./...
