# DGX Spark survival guide

I crashed my NVIDIA DGX Spark enough times to learn the rules the painful way.

This guide is for anyone running local LLMs on a DGX Spark / GB10, especially with vLLM, NVFP4 models, long context, speculative decoding, and OpenAI-compatible agent workloads.

The Spark is a tiny box with huge memory and surprising capability. It is also very easy to anger if you treat it like a normal desktop GPU.

## The big idea: unified memory changes the failure mode

DGX Spark is not a normal “GPU with separate VRAM” setup. Its 128GB unified memory means GPU memory pressure and system memory pressure are tied together.

That is powerful because it lets you run models and context windows that would be awkward on many consumer GPU setups. But it also means a bad prefill, oversized KV cache, or aggressive batch setting can destabilize the whole machine, not just one CUDA process.

On a desktop GPU, an out-of-memory error often means:

> The process died. Try a smaller config.

On Spark, a bad OOM can look more dramatic:

- SSH drops
- the dashboard freezes
- system memory hits the ceiling
- vLLM dies during load or prefill
- the box feels strangely slow after reboot

That does not mean the Spark is bad. It means the memory model is different, and the serving config matters.

## If the machine feels nerfed after crash testing

After repeated hard OOMs or whole-box lockups, some users have observed the Spark behaving like it is stuck in a low-power state: lower clocks, lower watts, and much worse token speed than expected.

The practical recovery path is simple:

```bash
sudo shutdown now
```

Wait for the machine to fully shut down, unplug power briefly, plug it back in, and boot clean.

This is not a magic performance trick. It is a recovery step for the “something is weird after a crash” state.

## The vLLM flag that saves machines

The most important stability flag is often not the exciting one:

```bash
--max-num-batched-tokens
```

This controls how much prefill work vLLM can batch. Large values can improve benchmark throughput, but they can also create transient memory spikes. On unified memory, those spikes can be the difference between “fast” and “the whole box just disappeared.”

For stable first loads, start low:

```bash
--max-num-batched-tokens 2048
```

Increase only after the model survives:

- model load
- short prompt
- long prompt
- repeated agent call
- concurrency test

## Do not start by maxing memory utilization

It is tempting to push:

```bash
--gpu-memory-utilization 0.90
```

That is usually not where I start on Spark.

For large NVFP4 models, a safer initial range is:

```bash
--gpu-memory-utilization 0.60
```

Then move toward:

```bash
--gpu-memory-utilization 0.65
--gpu-memory-utilization 0.70
```

only after real tests pass.

The goal is not “how high can I set the number?” The goal is “can this model serve users without locking the box?”

## FP8 KV is a major long-context knob

For 128K+ context, FP8 KV is one of the biggest practical options:

```bash
--kv-cache-dtype fp8
```

It helps make large context windows realistic on a single Spark. Without it, the KV cache cost climbs much faster.

If your goal is 200K, 250K, or 262K context, FP8 KV should usually be one of the first things you test.

## Context is not free concurrency

Yes, 250K or 262K context can work on a single Spark.

But a server with a 250K maximum context does not mean several users can all hit 250K at the same time.

Higher context means:

- more KV pressure
- lower full-context concurrency
- slower long-prefill requests
- higher risk when multiple users send deep prompts together

Always read the vLLM startup logs. Look for the KV cache capacity and the maximum concurrency estimate for your chosen context length.

Big context is a capability. It is not a free default workload.

## Prefix caching matters for agents

Agents often resend the same system prompt, tool schema, instructions, repository context, and long chat prefix.

Use:

```bash
--enable-prefix-caching
```

If your vLLM version supports it, also test:

```bash
--prefix-match-unit 16
```

This can help repeated-prefix workloads, especially agent loops where most of the prompt is unchanged between calls.

## Speculative decoding is model-specific

Speculative decoding can be amazing. DFlash, MTP, DSpark, and other draft approaches can noticeably improve real decode speed when the acceptance rate is good.

But it is not universal magic.

The right setting depends on:

- target model
- draft model
- output shape
- prompt length
- acceptance rate
- concurrency

A larger K value is not automatically better. If the later draft positions are rarely accepted, the draft model is doing work that gets thrown away.

Tune speculative decoding by benchmark, not vibes.

## Benchmark honestly

Do not trust tiny 3-token or 5-token screenshots.

A useful Spark benchmark should include:

- 128+ generated tokens minimum
- exact 500-token outputs when possible
- C1, C2, C4, and higher concurrency
- code-shaped prompts
- prose-shaped prompts
- long-context prompts
- cold and warm prefix cache behavior
- thinking on/off if the model supports it

A model can be “100 tok/s” in a screenshot and still feel slow in a real agent loop.

## Keep a known-good launcher

Before chasing a new model or speculative decoding trick, keep a known-good launcher backed up.

When an experiment crashes, restore the stable script and restart the service. Do not debug from a half-broken production state.

This one habit saves hours.

## My current single-Spark model map

My current practical view:

- Laguna S 2.1 NVFP4: daily-driver long-context endpoint
- Qwen3.6 35B-A3B NVFP4: fast coding / agent balance
- Qwen Coder Next NVFP4: very interesting coding model, but tool/reasoning behavior needs care
- 100B+ models: possible to experiment with, not always worth it for daily service

The Spark rewards patience. Config beats hype.

## Working recipes

Laguna S 2.1 on DGX Spark:

https://github.com/sojufx/Laguna-S-2.1-DGX-Spark-Recipe

Qwen3.6 35B NVFP4 on DGX Spark:

https://github.com/sojufx/Qwen3.6-35B-NVFP4-DGX-Spark-Recipe

## Share your results

If you run a DGX Spark, share:

- model
- vLLM version
- context length
- KV dtype
- speculative decoding config
- C1/C4 token speed
- long-context behavior
- stability/OOM notes

The more people publish reproducible configs, the less mystical Spark tuning becomes.

