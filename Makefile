.PHONY: exec-sample
exec-sample:
	./bin/cf-wait

.PHONY: run-main
run-main:
	mix run -e 'CfWait.CLI.main([])'

.PHONY: run-list-distributions
run-list-distributions:
	mix run -e 'CfWait.CLI.main(["list-distributions"])'

.PHONY: run-help
run-help:
	mix run -e 'CfWait.CLI.main(["--help"])'

.PHONY: build
build:
	MIX_ENV=prod mix escript.build

.PHONY: get
get:
	mix deps.get

.PHONY: docs
docs:
	mix docs

.PHONY: test
test:
	MIX_ENV=test mix test

.PHONY: console
console:
	iex -S mix
