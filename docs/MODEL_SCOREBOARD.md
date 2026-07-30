# Model scoreboard

Personal field notes from testing models on a single DGX Spark.

This is not a universal leaderboard. It is a practical “what would I actually run?” table.

| Model | Best use | Context tested | Speed feel | Verdict |
|---|---|---:|---|---|
| Laguna S 2.1 NVFP4 | daily-driver long-context endpoint | 250K | steady | keeper |
| Qwen3.6 35B-A3B NVFP4 | coding / agent throughput | 262K | fast aggregate | keeper |
| Qwen Coder Next NVFP4 | coding experiments | varies | very fast for active size | tool/reasoning quirks need care |
| Qwen3.6 27B NVFP4 | lightweight experiments | high | slower than hoped on our setup | not production |
| Qwen3.5 122B NVFP4 variants | large-model experiments | 128K | heavy | possible, not daily |

## Current recommended starting points

### Daily driver

Use Laguna S 2.1 if you care about long-context stability and production feel.

Recipe:

https://github.com/sojufx/Laguna-S-2.1-DGX-Spark-Recipe

### Fast coding / agent model

Use Qwen3.6 35B-A3B NVFP4 if you care about aggregate throughput and coding-agent shape.

Recipe:

https://github.com/sojufx/Qwen3.6-35B-NVFP4-DGX-Spark-Recipe

