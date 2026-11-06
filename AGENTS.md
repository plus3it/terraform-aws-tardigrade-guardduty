# Agent Instructions

Before starting any task in this repository:

1. Run `make agents/sync`. It writes the shared Plus3 IT instructions for this repository's tardigrade-ci version to `.agents/plus3it/AGENTS.md`.
2. Read `.agents/plus3it/AGENTS.md` and follow it together with this file. If the sync fails, tell the user, and don't guess the conventions.

These rules always apply, even without the shared instructions:

- Don't push, open pull requests, publish releases, or apply infrastructure changes unless the user asks. List those steps for a person in your final report.
- Don't edit files under `.agents/plus3it/`; they are generated and overwritten by the sync.

@.agents/plus3it/AGENTS.md

## Repository-specific

### Purpose

This Terraform module creates a standard GuardDuty setup in a single AWS account. It always creates a detector, and it can also create filters, IP sets, threat intel sets, malware protection plans, detector features, and an S3 publishing destination. The main input is `detector_features`, with `filters`, `ipsets`, `threatintelsets`, `protection_plans`, and `publishing_destination` for the other resources. The module outputs `detector`, `filter`, `ipset`, `threatintelset`, and `publishing_destination`.

### Module-specific files

- `modules/member/` — Submodule that invites a member account from an administrator account and accepts the invite in the member account; consumers call it directly, and the root module does not call it
- `modules/org-admin-account/` — Submodule that sets the delegated GuardDuty administrator account for an AWS organization and turns on auto-enable for the organization; consumers call it directly, and the root module does not call it
