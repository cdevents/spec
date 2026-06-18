# CDEvents Provider Registry

The canonical registry of known `provider` values is [`schemas/registry/providers.json`](schemas/registry/providers.json). SDKs MUST use this list as the default for provider validation. See the [Provider Validation](links.md#provider-validation) section in `links.md` for the full SDK validation requirements.

To register a provider, open a pull request adding an entry to the enum in [`schemas/registry/providers.json`](schemas/registry/providers.json). Provider identifiers MUST be lowercase, start with a letter, and contain only alphanumeric characters and hyphens. Once merged, the value is considered stable and MUST NOT be renamed.
