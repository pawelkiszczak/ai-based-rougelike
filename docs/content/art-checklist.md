# Slice art checklist

Locked palette: `#091122`, `#10294a`, `#1a4d64`, `#70e1ff`, `#d2e5ff`, `#ffb86b`, `#e86161`.

| Asset id | Surface | 640×360 / 2× review |
|---|---|---|
| `mutation_categories` | Four mutation category icons | Distinct silhouettes and warm center marks |
| `archetypes` | Sentinel, oracle, parasite silhouettes | Three distinct shapes and baseline labels |
| `boss_gate` | Command Mesh final gate | Red escalation core remains legible |
| `environment_frame` | Command Mesh environment framing | Cyan frame and horizon remain readable |
| `archive_recap` | Archive and recap panels | Separate panel outlines and trend marks |

`tools/validate_art.py` performs the missing-asset and palette-subset checks. Screenshot review remains a manual gate; assets use vector geometry and the locked palette so they scale at integer factors without resampling artifacts.
