# EOBOTER

Independent ExpertOption-oriented signal engine. Completely separate from MTBOT/MT5.

## Current mode
Demo/signal mode only. Live ExpertOption execution stays disabled until a supported integration method is available.

## Pipeline
Market closes -> Momentum / EMA / RSI -> Strategy Ranker -> bounded AI advisor -> Risk Manager -> decision/audit log.

A decision contains asset, UP/DOWN, confidence, expiry, payout requirement and calculated demo stake.

## Safety
- No ExpertOption credentials, cookies or sessions in this repository.
- No reverse-engineered/private ExpertOption protocol.
- ExpertOptionWebGateway is non-executing by design.
- Environment files, logs, databases, cookies and sessions are ignored.
- MTBOT is not imported or modified.

## Run
Install requirements, run main.py, then run pytest.
