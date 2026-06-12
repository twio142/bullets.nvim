TEST_FILES ?= $(wildcard tests/*_spec.lua)

.PHONY: test

test:
	@for file in $(TEST_FILES); do \
		echo "Running tests in $$file..."; \
		nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedFile $$file" 2>&1 || exit 1; \
	done
