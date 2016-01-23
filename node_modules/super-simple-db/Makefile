BIN = ./node_modules/.bin

.PHONY: bootstrap test release;

SRC = $(shell find ./index.js ./test -type f -name '*.js')

bootstrap: package.json
	@npm install

lint:
	@$(BIN)/jscs $(SRC);
	@$(BIN)/jshint $(SRC);

clean:
	@rm -rf ./test/tmp

test: clean lint
	@mkdir -p ./test/tmp
	@$(BIN)/mocha test