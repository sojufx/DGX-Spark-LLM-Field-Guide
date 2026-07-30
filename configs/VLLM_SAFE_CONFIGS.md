# Safe vLLM config patterns for DGX Spark

These are starting points, not universal truths. Always test on your own box.

## Conservative long-context baseline

Use this when trying a large model for the first time.

```bash
--tensor-parallel-size 1
--trust-remote-code
--max-model-len 128000
--gpu-memory-utilization 0.60
--max-num-seqs 2
--max-num-batched-tokens 2048
--kv-cache-dtype fp8
--enable-prefix-caching
--enable-chunked-prefill
```

## Stable 250K daily-driver profile

Good for long-context service when the model has already proven stable.

```bash
--max-model-len 250000
--gpu-memory-utilization 0.65
--max-num-seqs 3
--max-num-batched-tokens 2048
--kv-cache-dtype fp8
--enable-prefix-caching
--prefix-match-unit 16
```

## High-throughput coding/agent profile

Use after short and long-context tests pass.

```bash
--max-model-len 262144
--max-num-seqs 8
--max-num-batched-tokens 8192
--kv-cache-dtype fp8
--enable-prefix-caching
--enable-chunked-prefill
--async-scheduling
```

Some models can go higher, but unified-memory prefill spikes become the risk.

## Speculative decoding template

```bash
--speculative-config '{"method":"dflash","model":"DRAFT_MODEL","num_speculative_tokens":7,"draft_tensor_parallel_size":1}'
```

Tune `num_speculative_tokens` by benchmark, not vibes.

## What to lower first when unstable

1. `--max-num-batched-tokens`
2. `--max-num-seqs`
3. `--gpu-memory-utilization`
4. `--max-model-len`
5. speculative decoding K / draft model

