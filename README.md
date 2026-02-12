# Scalr VCS Tasks – CI/CD Examples

This repository contains ready-to-use CI/CD pipeline examples for [Scalr VCS Tasks](https://docs.scalr.io/docs/vcs#vcs-tasks). Use them to trigger Terraform/OpenTofu runs from your pipelines **after** tests, builds, or other steps complete.

## What are VCS Tasks?

VCS Tasks are API-driven requests that tell Scalr to process a specific commit and trigger runs for all VCS-driven workspaces linked to that repository. When you create a VCS task, Scalr will:

1. Find VCS-driven workspaces connected to the repository
2. Create configuration versions for the specified commit
3. Queue Terraform runs based on workspace settings and changes
4. Process runs according to your workspace auto-queue settings

**Benefits:**

- Run Terraform only after CI validates code, tests, and builds
- Integrate with any CI/CD that can make HTTP/CLI calls
- Trigger runs conditionally (e.g. after tests pass, on specific branches, or manual approval)

## Prerequisites

1. **VCS-driven workspaces** in Scalr with repository bindings
2. **VCS Provider** configured and authenticated (GitHub, GitLab, Bitbucket, Azure DevOps, etc.)
3. **Workspace setting**: Set **Auto-queue runs** to **Never** when using VCS Tasks (runs are triggered only by the task)
4. **Scalr CLI** version **0.17.0** or newer

## Scalr CLI

### Create VCS Task

```bash
scalr create-vcs-task \
  --repository-id "owner/repo-name" \
  --branch "branch-name" \
  --commit-sha "full-40-char-commit-sha"
```

### Parameters

| Parameter         | Required | Description                                              |
| ----------------- | -------- | -------------------------------------------------------- |
| `--repository-id` | Yes      | Repository ID (format depends on VCS, see below)         |
| `--branch`        | Yes      | Branch that contains the commit                          |
| `--commit-sha`    | Yes      | Full 40-character commit SHA                             |

### Repository ID format by VCS

| VCS            | Format                          | Example                    |
|----------------|---------------------------------|----------------------------|
| GitHub/GitLab  | `owner/repository-name`         | `myorg/infrastructure-repo` |
| Bitbucket      | `workspace/repository-name`     | `myteam/terraform-main`     |
| Azure DevOps   | `organization/project/repository-name` | `contoso/Platform/iac-repo` |

### Configuration

Set these before running the CLI (e.g. in CI secrets):

```bash
export SCALR_HOSTNAME="your-account.scalr.io"
export SCALR_TOKEN="your-api-token"
```

Never commit tokens; use your CI/CD’s secret management.

## Examples in this repo

| Platform         | File(s)                                      | Description                          |
|------------------|----------------------------------------------|-------------------------------------|
| GitHub Actions   | [.github/workflows/scalr-vcs-task.yml](.github/workflows/scalr-vcs-task.yml) | Multi-job: validate → Scalr VCS task |
| GitLab CI/CD     | [.gitlab-ci.yml](.gitlab-ci.yml)             | Stages: test → build → deploy (VCS task) |
| Azure DevOps     | [azure-pipelines.yml](azure-pipelines.yml)   | Stages with conditional Scalr trigger |
| Bitbucket       | [bitbucket-pipelines.yml](bitbucket-pipelines.yml) | Branch-based deployment with VCS task |

Each example includes:

- A **test/build** (or placeholder) step before the Scalr step
- **Scalr CLI** install and `create-vcs-task` usage
- **Secrets** for `SCALR_HOSTNAME` and `SCALR_TOKEN` (names may vary by platform)

## Quick start (GitHub Actions)

1. Copy [.github/workflows/scalr-vcs-task.yml](.github/workflows/scalr-vcs-task.yml) into your repo (or adapt it).
2. Add secrets in GitHub: **Settings → Secrets and variables → Actions**:
   - `SCALR_HOSTNAME` – e.g. `your-account.scalr.io`
   - `SCALR_TOKEN` – your Scalr API token
3. Adjust `repository-id`, branch filters, and job steps to match your repo and workflow.
4. Push to the configured branch; after the “validate” job passes, the workflow will run `scalr create-vcs-task` for the current commit.

Other platforms: open the corresponding file above and follow the comments for secrets and customization.

## Best practices

1. **Secrets**: Store `SCALR_HOSTNAME` and `SCALR_TOKEN` in your CI/CD secret store; never commit them.
2. **Commit SHA**: Use the full 40-character SHA from the pipeline (e.g. `$GITHUB_SHA`, `CI_COMMIT_SHA`).
3. **Branch**: Pass the branch that contains the commit (e.g. `main`, `develop`, or the PR head branch).
4. **Error handling**: Check the exit code of `scalr create-vcs-task` and fail the pipeline on error.
5. **Workspace config**: Use **Auto-queue runs: Never** for workspaces driven by VCS Tasks so only your pipeline triggers runs.

## Troubleshooting

| Issue | Cause | What to do |
|-------|--------|------------|
| **404 – VCS-driven workspaces not found** | No workspaces linked to the repo | Check repository ID format and that workspaces use this repo |
| **409 – Task already exists** | Same task already in progress | Wait or avoid duplicate triggers (e.g. single job per commit) |
| **Authentication failed** | Invalid/expired token or wrong hostname | Verify `SCALR_HOSTNAME` and `SCALR_TOKEN` in CI secrets |
| **Invalid parameters** | Wrong SHA length or repo format | Use 40-char SHA and correct `repository-id` for your VCS |

**Debug:** Run `scalr --verbose create-vcs-task ...` and ensure CLI version ≥ 0.17.0 (`scalr -version`).

## References

- [VCS Workspace & VCS Tasks (Scalr Docs)](https://docs.scalr.io/docs/vcs#vcs-tasks)
- [Scalr CLI](https://github.com/Scalr/scalr-cli) (GitHub)

## License

See [LICENSE](LICENSE).
