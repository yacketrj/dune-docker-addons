# Addon Submission

Addon submissions are reviewed through pull requests.

## Requirements

- Publish your addon from its own public repository.
- Build an addon install archive containing `addon.json` and the addon files needed at runtime.
- Upload that archive as a GitHub Release asset.
- Add a manifest file under `addons/`.
- Add the manifest to `index.json`.
- Include a SHA-256 checksum for the release archive. Addons without a valid checksum are not considered installable.

## Manual Release Package Flow

GitHub's automatic `Source code (zip)` and `Source code (tar.gz)` downloads are not addon install packages.

Before submitting or updating an addon:

1. Build the addon package from the addon repository.
2. Upload the generated `.zip` file as a GitHub Release asset.
3. Generate the SHA-256 checksum from that exact `.zip` file.
4. Set `downloadUrl` to the uploaded release asset URL.
5. Set `sha256` to the checksum for that uploaded release asset.

The release asset should contain the addon runtime files, such as:

```text
addon.json
web/
README.md
```

Do not use GitHub's automatic source archive as `downloadUrl`.

## Updating an Existing Addon

Do not create a new addon manifest for every release.

For a new addon version, update the existing file in `addons/`:

- `version`
- `downloadUrl`
- `sha256`
- any changed permissions, description, or metadata

For example, `addons/leadership-board.json` remains the same file when moving from `1.0.0` to `1.0.1`; only the versioned values change.

Only create a new JSON file when submitting a completely new addon.

## Release Pinning

Community addon entries must point to a specific reviewed release archive, not a floating `latest` URL.

Good:

```text
https://github.com/example/dune-addon/releases/download/v1.0.1/addon.zip
```

Avoid:

```text
https://github.com/example/dune-addon/releases/latest/download/addon.zip
```

Pinned releases keep installs reproducible and let the console verify the archive against the submitted SHA-256 checksum.

## Review Notes

Addons should request the smallest permission set needed. Dangerous permissions such as Docker access, host filesystem writes, or command execution require clear justification.
