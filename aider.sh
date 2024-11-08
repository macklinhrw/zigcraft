#! /bin/bash

aider --model openrouter/anthropic/claude-3.5-sonnet --architect --editor-model openrouter/anthropic/claude-3.5-sonnet --yes-always \
 --env aider/.env --auto-lint --lint-cmd "zig ast-check" --auto-test --test-cmd "zig build test" --cache-prompts