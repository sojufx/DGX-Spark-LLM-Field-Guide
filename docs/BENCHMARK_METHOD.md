# Benchmark methodology

The goal is not to produce the biggest screenshot number. The goal is to understand whether a model feels good as a real local endpoint.

## Minimum useful tests

| Test | Why |
|---|---|
| C1 short decode | baseline single-user speed |
| C2/C4 concurrency | family/team serving behavior |
| long-context decode | whether speed collapses after a large prefix |
| warm prefix repeat | agent-loop behavior |
| code-shaped output | coding agent usefulness |
| prose-shaped output | chat/reasoning behavior |

## Avoid misleading benchmarks

Do not rely on:

- 3-token or 5-token completions
- one lucky prompt
- only cold starts
- only warm starts
- only single stream
- only leaderboard prompts

## Suggested output sizes

Use at least:

```text
128 generated tokens
```

For better comparison:

```text
500 generated tokens
```

## Report these fields

```text
hardware:
vLLM version:
model:
draft model:
context length:
KV dtype:
gpu memory utilization:
max num seqs:
max num batched tokens:
speculative config:
C1 tok/s:
C2 aggregate tok/s:
C4 aggregate tok/s:
long-context tok/s:
TTFT:
notes:
```

