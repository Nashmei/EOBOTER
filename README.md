# EOBOTER

Independent AI-assisted trading research project for ExpertOption Web.

> This repository is completely separate from MTBOT/MT5. No MTBOT credentials, configuration, Git history, or runtime state belong here.

## Initial architecture

- `core/` — decision engine and session orchestration
- `strategies/` — time-expiry signal strategies
- `ai/` — bounded AI analysis layer
- `gateways/` — ExpertOption integration boundary
- `risk/` — stake/session risk controls
- `storage/` — audit and trade records
- `tests/` — automated tests

## Safety defaults

EOBOTER starts in **demo mode**. Live execution is not enabled by the initial scaffold. Secrets and browser/session credentials must never be committed.

## Status

Initial scaffold only. The ExpertOption gateway is intentionally a non-executing interface until the supported integration method is verified.
