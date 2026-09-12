# Reproducible release exports

CI exports the pinned Godot project with `game/export_presets.cfg` into named Linux x86_64 and Windows x86_64 packages. Each package includes `build_metadata.json` with the semantic version, checkout commit, commit timestamp, and channel. CI writes these values before export using `GITHUB_SHA` and the commit timestamp; identical source and toolchain inputs therefore produce identical metadata.

Packages are zipped as `emergence-protocol-linux-x86_64.zip` and `emergence-protocol-windows-x86_64.zip`. SHA-256 files are generated beside them and uploaded with the packages. The Linux executable is launched headlessly as a smoke check; both package contents are audited for the embedded metadata and expected platform executable.

The default checked-in metadata uses `development` provenance for local editor runs. Release CI replaces it in the workspace only; generated metadata is not committed.
