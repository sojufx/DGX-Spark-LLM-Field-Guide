#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-assets/dgx-spark-survival-card.png}"
FONT="/System/Library/Fonts/Supplemental/Arial.ttf"
BOLD="/System/Library/Fonts/Supplemental/Arial Bold.ttf"

magick -size 1600x900 xc:'#05070b' \
  -fill '#0b1220' -draw 'circle 1360,100 1700,100' \
  -fill '#052e2b' -draw 'circle 150,820 520,820' \
  -fill '#111827' -stroke '#24364f' -strokewidth 3 -draw 'roundrectangle 55,50 1545,850 44,44' \
  -stroke none -font "$BOLD" -fill '#f8fafc' -pointsize 62 -annotate +92+132 'DGX Spark LLM Survival Rules' \
  -stroke none -font "$FONT" -fill '#93c5fd' -pointsize 30 -annotate +94+184 'For vLLM, NVFP4 models, long context, and unified-memory chaos' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 92,235 760,340 26,26' \
  -stroke none -font "$BOLD" -fill '#facc15' -pointsize 35 -annotate +122+281 '1. FP8 KV for long context' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +122+314 '--kv-cache-dtype fp8 keeps big windows realistic' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 840,235 1508,340 26,26' \
  -stroke none -font "$BOLD" -fill '#38bdf8' -pointsize 35 -annotate +870+281 '2. Cap prefill tokens' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +870+314 '--max-num-batched-tokens prevents nasty spikes' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 92,380 760,485 26,26' \
  -stroke none -font "$BOLD" -fill '#fb923c' -pointsize 35 -annotate +122+426 '3. Do not max memory util' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +122+459 'Start conservative, then raise after real tests' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 840,380 1508,485 26,26' \
  -stroke none -font "$BOLD" -fill '#a78bfa' -pointsize 35 -annotate +870+426 '4. Prefix cache for agents' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +870+459 '--enable-prefix-caching helps repeated prompts' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 92,525 760,630 26,26' \
  -stroke none -font "$BOLD" -fill '#22c55e' -pointsize 35 -annotate +122+571 '5. Benchmark concurrency' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +122+604 'C1 is not enough. Test C2, C4, long context' \
  \
  -fill '#020617' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 840,525 1508,630 26,26' \
  -stroke none -font "$BOLD" -fill '#ef4444' -pointsize 35 -annotate +870+571 '6. Hard OOM? Power cycle' \
  -stroke none -font "$FONT" -fill '#cbd5e1' -pointsize 22 -annotate +870+604 'Clean shutdown + unplug can restore normal speed' \
  \
  -fill '#0b1020' -stroke '#334155' -strokewidth 2 -draw 'roundrectangle 92,690 1508,775 24,24' \
  -stroke none -font "$BOLD" -fill '#f8fafc' -pointsize 30 -annotate +122+742 'Rule zero: keep a known-good launcher before chasing benchmark screenshots.' \
  \
  -stroke none -font "$FONT" -fill '#94a3b8' -pointsize 22 -annotate +92+825 'github.com/sojufx/DGX-Spark-LLM-Field-Guide' \
  -stroke none -font "$BOLD" -fill '#f8fafc' -pointsize 25 -annotate +1130+825 'Tiny box. Huge memory. Easy to anger.' \
  "$OUT"
