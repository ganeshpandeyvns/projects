# KidsGPT - Safe AI Learning Companion for Children

A child-safe AI chatbot for kids 3-13 with parental controls, age-appropriate responses, and multi-layer safety filters.

## Quick Start

### 1. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env and add your OpenAI API key

# Start the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at http://localhost:8000
- API docs: http://localhost:8000/docs

### 2. Frontend Setup

```bash
cd apps/web

# Install dependencies
npm install

# Start development server
npm run dev
```

The app will be available at http://localhost:5173

## Project Structure

```
kidsGPT/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── main.py         # FastAPI app entry
│   │   ├── routers/        # API endpoints
│   │   ├── models/         # SQLAlchemy models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── services/       # Business logic
│   │   └── core/           # Config, DB setup
│   └── ai/
│       ├── providers/      # OpenAI/Anthropic adapters
│       ├── prompts/        # Age-specific prompts
│       └── filters/        # Safety filters
├── apps/
│   └── web/                # React frontend
│       └── src/
│           ├── pages/      # Page components
│           ├── components/ # Reusable components
│           └── lib/        # API client
├── PLAN.md                 # Full product plan
└── KidsGPT_Product_Plan.pdf
```

## Features (MVP)

### Kids Mode
- Fun, colorful chat interface
- Age-appropriate AI responses (Sparky mascot)
- Daily message limits
- Emoji suggestions
- Thinking indicators

### Parent Mode
- Create/manage child profiles
- Set age and interests
- View conversation history
- Monitor flagged content

### Safety
- Multi-layer content filtering
- Input filter (dangerous topics, PII)
- Output filter (profanity, inappropriate content)
- "Ask a grownup" deflections
- Age-specific system prompts

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Register parent |
| POST | /api/auth/login | Login parent |
| POST | /api/children | Create child profile |
| GET | /api/children | List children |
| POST | /api/chat | Send message, get response |
| GET | /api/chat/today/{id} | Get daily stats |
| GET | /api/chat/conversations/{id} | List conversations |

## Environment Variables

```env
# Required
OPENAI_API_KEY=sk-...

# Optional
ANTHROPIC_API_KEY=sk-ant-...
DEFAULT_AI_PROVIDER=openai  # or anthropic
DATABASE_URL=sqlite+aiosqlite:///./kidsgpt.db
```

## Tech Stack

- **Backend**: FastAPI, SQLAlchemy, Pydantic
- **Frontend**: React, Vite, Tailwind CSS, React Query
- **AI**: OpenAI GPT-4o (default), Anthropic Claude (supported)
- **Database**: SQLite (MVP), PostgreSQL (production)

## Next Steps

See [PLAN.md](./PLAN.md) for the full product roadmap including:
- Firebase authentication
- Mobile app (React Native)
- Admin portal
- Subscription tiers
- kidSAFE certification
