# X thread: DGX Spark survival guide

## Tweet 1

I crashed my NVIDIA DGX Spark enough times to learn the rules the painful way.

If you’re running local LLMs on a Spark / GB10, especially vLLM + NVFP4 models, here’s the survival guide I wish I had on day one.

Tiny box. Huge memory. Very easy to anger. 🧵

## Tweet 2

DGX Spark is not a normal “GPU with separate VRAM” setup.

It has 128GB unified memory, so GPU memory pressure and system RAM pressure are tied together.

That means a bad prefill / KV / batch config can make the whole machine unstable, not just kill one CUDA process.

## Tweet 3

On a desktop GPU, OOM usually means:

“process dies, try again.”

On Spark, OOM can mean:

- SSH drops
- dashboard freezes
- system RAM hits the ceiling
- vLLM dies mid-load
- the box becomes weirdly slow after reboot

Unified memory is powerful, but bad configs get dramatic.

## Tweet 4

If your Spark suddenly feels nerfed after crash testing, check clocks / watts / tok/s.

Some users have seen the box get stuck in a low-power-feeling state after hard OOMs.

The practical fix:

```bash
sudo shutdown now
```

Then wait, unplug power briefly, plug back in, boot clean.

## Tweet 5

The vLLM flag that saves machines is often not the sexy one:

```bash
--max-num-batched-tokens
```

This controls how much prefill work vLLM can batch.

Huge values can create nasty transient memory spikes on unified memory.

## Tweet 6

For large NVFP4 models on one Spark, I now start conservative:

```bash
--max-num-batched-tokens 2048
--gpu-memory-utilization 0.65-0.70
--kv-cache-dtype fp8
--enable-prefix-caching
```

Then increase only after the model survives real prompts.

## Tweet 7

Yes, 250K / 262K context can work.

But context is not magic free space.

Higher context means:

- more KV pressure
- lower full-context concurrency
- slower long-prefill requests
- more risk when several users hit long prompts together

Big context is a capability, not a default workload.

## Tweet 8

For long context, FP8 KV is one of the biggest practical knobs:

```bash
--kv-cache-dtype fp8
```

It helps make large context windows possible on Spark.

If you try huge context with heavier KV settings, you hit the wall much faster.

## Tweet 9

Speculative decoding can be amazing, but it is model-specific.

DFlash / MTP / DSpark can help a lot when acceptance is good.

But wrong draft model or wrong K can waste compute and reduce real speed.

Do not blindly copy K=15, K=7, etc. Test it.

## Tweet 10

For agents, prefix caching is not optional.

```bash
--enable-prefix-caching
```

If your agent keeps resending the same system prompt, tool schema, repo context, or long chat prefix, prefix caching can reduce repeated prefill pain dramatically.

## Tweet 11

Do not trust 5-token screenshots.

Benchmark with:

- 128+ output tokens minimum
- code-shaped and prose-shaped prompts
- cold and warm runs
- concurrency 1, 2, 4+
- long-context prompts
- thinking on/off if the model supports it

A model can be “100 tok/s” and still feel slow.

## Tweet 12

My current single-Spark mental model:

- Laguna S 2.1 = daily-driver long-context endpoint
- Qwen3.6 35B-A3B = speed/coding/agent balance
- huge 100B+ models = possible, but usually not daily-service practical
- config beats hype

The box rewards patience.

## Tweet 13

I’m collecting my working recipes and notes here:

https://github.com/sojufx/DGX-Spark-LLM-Field-Guide

Qwen3.6 35B recipe:
https://github.com/sojufx/Qwen3.6-35B-NVFP4-DGX-Spark-Recipe

Laguna S 2.1 recipe:
https://github.com/sojufx/Laguna-S-2.1-DGX-Spark-Recipe

## Tweet 14

If you’re running a Spark, please share your numbers.

Useful details:

- model
- vLLM version
- context length
- KV dtype
- speculative config
- tok/s at C1/C4
- whether it survived long-context prompts

Let’s make Spark recipes reproducible instead of mystical.

