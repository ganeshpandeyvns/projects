# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a multi-project workspace containing several independent projects. Each project has its own technology stack and purpose.

## Projects

### progasset-mvp
Tokenized equities with on-chain Proof-of-Reserves (PoR) verification. Multi-asset ERC-20 token MVP on Hardhat.

**Tech Stack:** Node.js, Hardhat, Ethers.js, Express, Solidity (OpenZeppelin)

**Commands:**
```bash
cd progasset-mvp
npm ci
npm run dev:chain          # Start local Hardhat node
npm run dev:compile         # Compile contracts
npm run dev:deploy          # Deploy to localhost
npm run dev:deploy:multi    # Deploy multiple assets
npm run dev:test            # Run Hardhat tests
npm run por:run             # Run Proof-of-Reserves job
make demo                   # Full happy path demo
node api/server.cjs         # Start API server (port 4000)
```

**Key Directories:**
- `contracts/` - Solidity contracts (ProgAssetToken.sol)
- `api/` - Express API server
- `custodian_mock/` - Mock custodian proof generation
- `jobs/` - Background PoR verification
- `scripts/` - Deployment and utility scripts

### prosset-auth
Content authenticity backend with EVM/SVM chain router. Hashes images/videos, signs with Ed25519, anchors on EVM (Hardhat) or SVM (Solana).

**Tech Stack:** Python (FastAPI, uvicorn), Hardhat, Solana/Anchor

**Commands:**
```bash
cd prosset-auth

# EVM chain
cd chain/evm && npx hardhat node

# Backend
cd backend
source .venv/bin/activate
uvicorn app.main:app --reload    # API at http://127.0.0.1:8000/docs

# Scripts
./scripts/up.sh                  # Start services
./scripts/down.sh                # Stop services
./scripts/test_evm.sh            # Test EVM flow
./scripts/test_svm.sh            # Test SVM flow
```

**Environment Variables:**
- `HARDHAT_RPC=http://127.0.0.1:8545`
- `PROSSET_EVM_CONTRACT=0x5FbDB2315678afecb367f032d93F642f64180aa3`
- `SVM_RPC=http://127.0.0.1:8899`

### eklavya
AI tutor application with Flask backend and React frontend.

**Tech Stack:** Python (Flask, OpenAI, Firebase, SQLAlchemy), React (Create React App, Tailwind CSS)

**Commands:**
```bash
# Backend
cd eklavya/backend
source ../eklavya/bin/activate
python ai_tutor_backend.py

# Frontend
cd eklavya/frontend
npm start                        # Dev server
npm run build                    # Production build
npm test                         # Run tests
```

### sanjay
AI RL ticker prediction bot. Predicts 5 U.S. equity tickers daily with confidence scores, validates against actual movement, and retrains using RL.

**Tech Stack:** Python (PyTorch, pandas, transformers)

**Key Directories:**
- `predictor/` - Prediction logic
- `collectors/` - Data collection
- `backtester/` - Historical testing
- `oneticker/` - Single ticker analysis

### ai-studio
CrewAI/Flask-based AI pipeline with RL training components.

**Tech Stack:** Python (CrewAI, Flask, transformers, trl)

**Commands:**
```bash
cd ai-studio
pip install -r requirements.txt
python main.py
pytest                           # Run tests
```

### hello-name-app
Minimal iOS + FastAPI example app.

**Commands:**
```bash
# Backend
cd hello-name-app/backend
source .venv/bin/activate
uvicorn main:app --reload

# iOS
# Open ios/HelloNameApp.xcodeproj in Xcode
```

### hybrid_rl_trading_bot
Reinforcement learning trading bot with human-defined guardrails.

**Tech Stack:** Python (PyTorch)

### resume-ai-bot
Flask-based resume enhancement and job matching tool using GPT. Uploads resumes (PDF/DOCX), enhances them, generates cover letters, and scores against job postings.

**Tech Stack:** Python (Flask, OpenAI, WeasyPrint, PyPDF2, python-docx)

**Commands:**
```bash
cd resume-ai-bot
source venv/bin/activate
pip install -r requirement.txt
python app.py                    # Runs on port 5000
```

**Key Directories:**
- `utils/` - GPT tools, job API integration
- `templates/` - Flask HTML templates

### simple_rl_ai
Minimal OpenAI Gym environment for learning RL concepts. Simple 1D navigation task.

**Tech Stack:** Python (gym, numpy)

**Commands:**
```bash
cd simple_rl_ai
source rl-ai/bin/activate
python random_agent.py           # Run random agent demo
```

### studio
Simple Flask greeting app (prototype/demo).

**Commands:**
```bash
cd studio
python app.py                    # Runs on port 5000
```

## Common Ports
- 4000: progasset-mvp API
- 8000: prosset-auth / eklavya backend
- 8545: Hardhat local node
- 8899: Solana local validator
- 3000: React dev servers

## Killing Stuck Processes
```bash
lsof -ti tcp:8545 | xargs kill -9
lsof -ti tcp:4000 | xargs kill -9
lsof -ti tcp:8000 | xargs kill -9
```

## Architecture Notes

**Python Projects**: Most Python projects use local virtual environments (`venv/`, `<project>/bin/`, or `.venv/`). Always activate before running.

**Web Frameworks**:
- FastAPI (prosset-auth, hello-name-app): Use `uvicorn app.main:app --reload`
- Flask (eklavya backend, resume-ai-bot, studio, ai-studio): Use `python app.py` or `flask run`

**Blockchain Projects**:
- progasset-mvp: Hardhat + Express API for tokenized equities
- prosset-auth: Dual-chain support (EVM via Hardhat, SVM via Solana/Anchor)

**AI/ML Projects**: Several projects use RL patterns with PyTorch (sanjay, hybrid_rl_trading_bot, ai-studio). The ai-studio project includes CrewAI agents with self-fixing capabilities.
