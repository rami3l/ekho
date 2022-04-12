# Define required macros here
SHELL = /bin/sh

RFLX = rflx
SPECS = ./libekho/specs
GENERATED = ./libekho/generated

.PHONY: generate
generate:
	$(RFLX) generate -d $(GENERATED) $(SPECS)/*.rflx

.PHONY: build
build: generate
	alr build

.PHONY: run
run: generate
	alr run

.PHONY: clean
clean:
	rm -f $(GENERATED)/*
	alr clean