# Pipeline — SimpleHealthAPI

This folder holds the scripts and configuration used by local runs and the CI pipeline.

Goals
- Provide a single place to bootstrap, build, run, test and cleanup the application.
- Make the scripts usable interactively (local dev) and non-interactively (CI).

What’s here
- `Pipeline/scripts/00-boostrap.ps1` — install/prepare local environment (winget, PowerShell, .NET, Pester). 
- `Pipeline/scripts/01-build.ps1` — restore, build, run unit tests and publish the app. Writes test TRX results to `./build/test-results` and published app to `./build/publish`.
- `Pipeline/scripts/02-run.ps1` — start the API using settings from the pipeline config or environment variables. Runs in silent/background mode and writes logs to `./build/logs` and PID to `./build/api.pid`.
- `Pipeline/scripts/03-test.ps1` — run Pester smoke tests and save human/machine-readable outputs under `./build/test-results`.
- `Pipeline/scripts/99-cleanup.ps1` — stop the API process started by `02-run.ps1`.
- `Pipeline/pipeline.config.json` — repo-local defaults for the pipeline (e.g. `ApiPort`, `UseHttps`).

Configuration precedence
`Pipeline/pipeline.config.json` — repo defaults
    - `API_PORT` — port to run the API on
    - `API_HTTPS` — `true`/`false` to control HTTPS

How to run locally (PowerShell)
- Run the full pipeline (bootstrap, build, run, test, cleanup):

CI behaviour (GitHub Actions)
- The workflow is located at `.github/workflows/smoke-test-workflow.yml`.
- The workflow executes the same scripts in sequence. We intentionally keep bootstrap logic in `00-boostrap.ps1`
- Artifacts uploaded by the workflow:
  - `build/publish` — published application
  - `build/test-results` — TRX and Pester outputs

TODO
- figure out how to display test results in Github Actions rather than just file output
- clean up - especially 02-run.ps1 as it looks cluttered
- add more and better comments and logging 
- move unit tests from build to seperate pre-run Powershell script