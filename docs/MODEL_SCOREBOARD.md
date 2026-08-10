# Model scoreboard

Personal field notes from testing models on a single DGX Spark.

This is not a universal leaderboard. It is a practical “what would I actually run?” table.

| Model | Best use | Context tested | Speed feel | Verdict |
|---|---|---:|---|---|
| DeepSeek V4 Flash IQ2XXS DS4 | huge MoE / tool-heavy reasoning experiments | 128K | slower raw decode, wild capability | keeper with guardrails |
| Laguna S 2.1 NVFP4 | daily-driver long-context endpoint | 250K | steady | keeper |
| Qwen3.6 35B-A3B NVFP4 | coding / agent throughput | 262K | fast aggregate | keeper |
| Qwen3.5 122B-A10B NVFP4 | large Qwen MoE / concise agent experiments | 128K | surprisingly usable but heavy | experiment |
| Qwen Coder Next NVFP4 | coding experiments | varies | very fast for active size | tool/reasoning quirks need care |
| Qwen3.6 27B NVFP4 | lightweight experiments | high | slower than hoped on our setup | not production |

## Current recommended starting points

### Biggest model that actually ran at home

Use DeepSeek V4 Flash through DS4 if you want the “how is this running on one Spark?” experience. It needs stronger guardrails than vLLM models: memory admission, a watchdog with boot grace, and a proxy if you want an OpenAI-compatible family/agent endpoint.

Recipe:

https://github.com/sojufx/DeepSeek-V4-Flash-One-Spark-Stable-Serve

### Daily driver

Use Laguna S 2.1 if you care about long-context stability and production feel.

Recipe:

https://github.com/sojufx/Laguna-S-2.1-DGX-Spark-Recipe

### Fast coding / agent model

Use Qwen3.6 35B-A3B NVFP4 if you care about aggregate throughput and coding-agent shape.

Recipe:

https://github.com/sojufx/Qwen3.6-35B-NVFP4-DGX-Spark-Recipe

### Large Qwen MoE experiment

Use Qwen3.5 122B-A10B NVFP4 if you want to test a larger Qwen MoE on a single Spark. It can be concise and useful in agent workflows, but it is heavier than Laguna and Qwen3.6 35B, so treat it as an experiment before making it daily production.

Recipe:

https://github.com/sojufx/Qwen3.5-122B-A10B-DFlash-DGX-Spark-Recipe
