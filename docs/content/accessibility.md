# Accessibility contract

`AccessibilitySettings` persists the accessibility surface in SaveSystem settings:

- text scale has three supported steps: `1.0`, `1.25`, and `1.5`;
- `choose`, `open_archive`, and `initialize_successor` accept normalized non-empty bindings;
- unknown actions, empty bindings, and unsupported scale indices are rejected;
- missing settings retain defaults during load.

Controller and keyboard focus remain available through the shared `ControllerNavigation` helper. UI code should apply the selected scale to every generated control and use shape/icon plus text, not color alone, for intent communication.

## Icon review rubric

Intent icons must remain distinguishable under protanopia, deuteranopia, and tritanopia simulation. Review each icon set for silhouette, label, and contrast independently of hue. This repository provides the rubric and automated settings coverage; the required external screenshot review remains a manual release activity.

`game/tests/test_accessibility_settings.gd` covers scale boundaries, remap validation, and persistence.
