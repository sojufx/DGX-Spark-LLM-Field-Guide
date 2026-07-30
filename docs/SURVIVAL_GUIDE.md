# DGX Spark survival guide

Hard-won practical notes for running vLLM and large local models on DGX Spark / GB10.

## 1. Unified memory changes the failure mode

Spark is not a normal desktop GPU with separate VRAM. GPU memory pressure and system memory pressure are tied together.

That means a bad long-context prefill, oversized KV cache, or aggressive batch config can destabilize the whole machine, not only one CUDA process.

Common symptoms:

- SSH drops
- dashboard freezes
- system memory jumps to the ceiling
- vLLM dies during load or prefill
- the box feels slow after reboot

## 2. Do not start with maxed memory

Avoid starting experiments at the largest possible `--gpu-memory-utilization`.

For large NVFP4 models, start around:

```bash
--gpu-memory-utilization 0.60
```

Then move toward `0.65-0.70` only after load, short prompt, long prompt, and concurrency tests pass.

## 3. Cap prefill pressure

For unified memory stability, this flag is often more important than people expect:

```bash
--max-num-batched-tokens 2048
```

Large values can improve throughput, but they can also create transient prefill working-set spikes.

For stable daily-driver service, a lower value is often better than a higher benchmark number.

## 4. Use FP8 KV for long context

For 128K+ context, FP8 KV is one of the biggest practical knobs:

```bash
--kv-cache-dtype fp8
```

Without it, large context windows get expensive fast.

## 5. Prefix caching is essential for agents

Agents often resend the same system prompt, tool schema, instructions, and long chat prefix.

Use:

```bash
--enable-prefix-caching
```

On vLLM versions that support it, also test:

```bash
--prefix-match-unit 16
```

This can help repeated-prefix workloads.

## 6. Spec decode is not universal magic

DFlash, MTP, DSpark, and other speculative approaches can help a lot, but the right setting depends on:

- target model
- draft model
- output shape
- prompt length
- acceptance rate
- concurrency

Do not assume a larger K is better. A draft that is not accepted wastes compute.

## 7. Context and concurrency fight each other

Large context is a capability, not free capacity.

If you run a 250K context server, it does not mean four users can all hit 250K safely at the same time.

Always check vLLM startup logs for KV cache capacity and max-context concurrency estimate.

## 8. Benchmark honestly

Avoid 5-token demo screenshots.

Test:

- 128+ output tokens
- exact 500-token outputs
- C1, C2, C4, C8 concurrency
- code-shaped output
- prose-shaped output
- long-context prompts
- cold and warm prefix cache behavior

## 9. Power-limited weirdness after hard OOM

After repeated hard OOM / whole-box lockups, some users observe much lower performance until a full power cycle.

Practical recovery:

```bash
sudo shutdown now
```

Then wait for shutdown, unplug power briefly, plug back in, and boot clean.

## 10. Keep a known-good launcher

When testing new models, keep one stable production launcher backed up.

If an experiment crashes, restore the known-good script and restart the service instead of debugging from a broken state.

