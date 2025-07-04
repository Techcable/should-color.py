test: mypy _lint && check-format
    # Testing project
    @just _test

# Run test just on the current python version
test-single:
    # Test on current python version
    uv run pytest

check: mypy lint

# runs lints, but not type checking or tests
#
# Avoids performance penalty of `mypy`
lint: _lint && check-format

_lint:
    -uv run ruff check src

fix: && _format fix-spelling
    @# Failure to fix should not prevent formatting
    -uv run ruff check --fix src

build: mypy && _test check-format
    # Build project
    uv build

mypy:
    uv run mypy src

# runs tests without anything else
_test: test-single
    @just _test_ver 3.13
    @just _test_ver 3.12
    @just _test_ver 3.11
    @just _test_ver 3.10
    @just _test_ver 3.9
    @just _test_ver 3.8


# runs python tests for a specific version
_test_ver pyver:
    # running tests for python {{pyver}}
    @# NOTE: Using `uv` is vastly faster than using `tox`
    @# Using --isolated avoids clobbering dev environment
    @uv run --isolated --python {{pyver}} --only-group test pytest --quiet

# Check for spelling issues
spellcheck:
    # Check for obvious spelling issues
    uv run typos

# Fix obvious spelling issues
fix-spelling:
    # Fix obvious spelling issues
    uv run typos --write-changes

# Checks for formatting issues
check-format: && spellcheck
    uv run ruff format --check .
    uv run ruff check --select I --output-format concise .
    # Checking TOML file formatting
    RUST_LOG=WARN uv run taplo format --check

format: _format && spellcheck

_format:
    uv run ruff format .
    uv run ruff check --select 'I' --fix .
    RUST_LOG=WARN uv run taplo format
