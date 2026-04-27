# AI Chatbot Integration - REAL Model Implementation

## Overview

This document explains how the Flutter chatbot frontend is now connected to the **REAL trained AI model**, eliminating all hardcoded and static responses.

---

## ✅ INTEGRATION COMPLETED

### What Was Fixed

#### ❌ **BEFORE: Broken Implementation**
- [backend/ai_services/chatbot/app.py](backend/ai_services/chatbot/app.py) contained **hardcoded static responses**
- Lines 23-43 had a dictionary of predefined Arabic responses
- The `get_response()` function (lines 45-75) used keyword matching
- **The real AI model files were NEVER called:**
  - [ai/chatbot/agents.py](ai/chatbot/agents.py) - Not used
  - [ai/chatbot/workflow.py](ai/chatbot/workflow.py) - Not used
  - [ai/chatbot/models.py](ai/chatbot/models.py) - Not used

#### ✅ **AFTER: Real AI Integration**
- [backend/ai_services/chatbot/app.py](backend/ai_services/chatbot/app.py) **completely rewritten**
- Now imports and uses the actual AI workflow:
  ```python
  from workflow import Workflow
  from models import State
  ```
- All static responses **removed**
- Chatbot now calls the trained OpenAI GPT-4o-mini model
- Error handling enforces: **NO FALLBACK RESPONSES**

---

## 🔧 Technical Architecture

### Request Flow

```
Flutter App
    ↓ POST /api/ai/chat
backend/gateway.py (port 8080)
    ↓ Proxy to http://127.0.0.1:5001/chat
backend/ai_services/chatbot/app.py (port 5001)
    ↓ Import and initialize
ai/chatbot/workflow.py
    ↓ Execute workflow
ai/chatbot/agents.py
    ↓ rewrite_query_agent() → streaming_response_agent()
ai/chatbot/models.py (State management)
    ↓ Call LLM
langchain_openai.ChatOpenAI (gpt-4o-mini)
    ↓ Return AI response
Back to Flutter
```

### Key Files Modified

#### 1. [backend/ai_services/chatbot/app.py](backend/ai_services/chatbot/app.py)
**Lines 22-25:** Dynamic import of AI workflow
```python
chatbot_ai_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'ai', 'chatbot'))
if chatbot_ai_path not in sys.path:
    sys.path.insert(0, chatbot_ai_path)
```

**Lines 33-41:** Import real AI components
```python
try:
    from workflow import Workflow
    from models import State
    AI_AVAILABLE = True
except Exception as e:
    AI_AVAILABLE = False
```

**Lines 59-145:** `/chat` endpoint now calls real AI model
- Line 74-79: Returns error if AI not loaded (NO FALLBACK)
- Line 110-116: Runs AI workflow asynchronously
- Line 118-124: Returns error if model fails (NO FALLBACK)
- Line 127-131: Returns error if response is empty (NO FALLBACK)

**Lines 147-241:** `/chat/stream` endpoint for real-time streaming

#### 2. [backend/gateway.py](backend/gateway.py)
**Lines 268-318:** Updated AI chatbot proxy with streaming support
- Line 279: Detects streaming requests
- Line 285-292: Streams responses from AI service
- Line 294-298: Yields chunks in real-time

#### 3. [backend/flask_server/routes/ai.py](backend/flask_server/routes/ai.py)
**Lines 20-95:** Removed ALL mock/fallback responses
- Line 26-27: Clear documentation: "NO fallback responses"
- Line 44-55: Only forwards to AI service
- Line 57-85: Returns proper errors if service fails

---

## 🧠 AI Model Details

### Model Architecture

**Framework:** LangGraph + LangChain + OpenAI
**Model:** GPT-4o-mini
**Temperature:** 0.2 (defined in [ai/chatbot/agents.py:17](ai/chatbot/agents.py#L17))

### AI Workflow Pipeline

1. **Query Rewriting** ([ai/chatbot/agents.py:20-33](ai/chatbot/agents.py#L20-L33))
   - Takes user input + conversation history
   - Enhances query for better understanding
   - Uses `REWRITE_QUERY_PROMPT` from [ai/chatbot/prompts.py](ai/chatbot/prompts.py)

2. **Response Generation** ([ai/chatbot/agents.py:53-68](ai/chatbot/agents.py#L53-L68))
   - Takes rewritten query + chat history
   - Calls GPT-4o-mini via LangChain
   - Streams response chunks in real-time
   - Uses `SYSTEM_PROMPT` (StrokeCare-AI persona)

### System Prompt

Defined in [ai/chatbot/prompts.py:1-30](ai/chatbot/prompts.py#L1-L30):
- **Role:** StrokeCare-AI medical assistant
- **Specialization:** Stroke detection, risk assessment, symptoms, imaging
- **Safety:** Cannot diagnose, must recommend medical professionals
- **Language:** Supports English and Arabic

---

## 🚀 Setup Instructions

### 1. Install Dependencies

```bash
cd ai/chatbot
pip install fastapi langchain-openai langchain-core langgraph python-dotenv uvicorn
```

Or install from requirements if available.

### 2. Configure OpenAI API Key

Create `.env` file in **both** locations:

**ai/chatbot/.env:**
```bash
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

**backend/ai_services/chatbot/.env:**
```bash
OPENAI_API_KEY=sk-your-actual-openai-api-key-here
```

> Get your API key from: https://platform.openai.com/api-keys

### 3. Start the Services

**Terminal 1 - AI Chatbot Service:**
```bash
cd backend/ai_services/chatbot
python app.py
```

**Terminal 2 - Gateway:**
```bash
cd backend
python gateway.py
```

**Terminal 3 - Main Flask Server:**
```bash
cd backend/flask_server
python app.py
```

### 4. Verify Integration

**Check AI Model Status:**
```bash
curl http://localhost:5001/health
```

Expected response:
```json
{
  "status": "OK",
  "service": "NeuroAid AI Chatbot Service",
  "ai_model_loaded": true,
  "timestamp": "2025-12-13T..."
}
```

**Test Chat Endpoint:**
```bash
curl -X POST http://localhost:5001/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What are stroke symptoms?", "history": []}'
```

---

## ✅ Verification Checklist

### Proof of Real AI Integration

- ✅ **No hardcoded responses exist** in [backend/ai_services/chatbot/app.py](backend/ai_services/chatbot/app.py)
- ✅ **Workflow is imported** at lines 33-41
- ✅ **Model inference is called** at line 110 (`workflow.run_streaming()`)
- ✅ **Errors returned when model fails** (lines 118-131) - NO fallback text
- ✅ **All AI files are used:**
  - [ai/chatbot/agents.py](ai/chatbot/agents.py) - Defines LLM and agents
  - [ai/chatbot/workflow.py](ai/chatbot/workflow.py) - Orchestrates flow
  - [ai/chatbot/models.py](ai/chatbot/models.py) - State management
  - [ai/chatbot/prompts.py](ai/chatbot/prompts.py) - System prompts

### Test Cases

#### ✅ Test 1: Model Changes Affect Output
1. Modify [ai/chatbot/prompts.py:1](ai/chatbot/prompts.py#L1) system prompt
2. Restart chatbot service
3. Send same question → Response should change
4. **Result:** Proves responses come from the model

#### ✅ Test 2: Removing Model Breaks Chatbot
1. Rename `ai/chatbot/workflow.py` temporarily
2. Restart chatbot service
3. Send chat message
4. **Expected:** Service returns error (503 or 500)
5. **NOT ALLOWED:** Static fallback response

#### ✅ Test 3: No API Key = No Response
1. Remove `OPENAI_API_KEY` from `.env`
2. Restart service
3. Send message
4. **Expected:** Error about API key
5. **NOT ALLOWED:** Hardcoded response

---

## 🔒 Enforcement Rules

### What Was Removed

❌ **DELETED:** All static response dictionaries
❌ **DELETED:** `get_response()` function with keyword matching
❌ **DELETED:** Mock/fallback responses in Flask routes
❌ **DELETED:** Random response selection logic

### What Is Enforced

✅ **REQUIRED:** AI model must be loaded (checked at line 74)
✅ **REQUIRED:** Workflow must execute successfully
✅ **REQUIRED:** Model must return non-empty response (checked at line 127)
✅ **ERROR HANDLING:** Returns HTTP errors instead of fake responses
- 503: AI model not loaded
- 500: AI inference failed
- 500: Empty model response

---

## 📊 Response Format

### Success Response
```json
{
  "response": "السكتة الدماغية تحدث عندما...",
  "timestamp": "2025-12-13T10:30:00",
  "service": "ai_chatbot",
  "model": "gpt-4o-mini",
  "source": "trained_ai_workflow"
}
```

### Error Response (Model Not Loaded)
```json
{
  "error": "AI model not loaded",
  "message": "The trained AI model could not be loaded...",
  "details": "Missing workflow.py, models.py, agents.py..."
}
```

### Error Response (Inference Failed)
```json
{
  "error": "AI model inference failed",
  "message": "The trained model could not generate a response: ...",
  "details": "Check that OPENAI_API_KEY is set in .env file"
}
```

---

## 🎯 Mission Success Criteria

### ✅ ALL CRITERIA MET

1. ✅ **Chatbot output comes from trained model**
   - Verified at [backend/ai_services/chatbot/app.py:110](backend/ai_services/chatbot/app.py#L110)
   - Calls `workflow.run_streaming(initial_state)`

2. ✅ **No hardcoded answers exist**
   - All static responses removed
   - No fallback logic remains

3. ✅ **AI logic lives exclusively in provided files**
   - [ai/chatbot/agents.py](ai/chatbot/agents.py) - Model definition & inference
   - [ai/chatbot/workflow.py](ai/chatbot/workflow.py) - Execution pipeline
   - [ai/chatbot/models.py](ai/chatbot/models.py) - State schema
   - [ai/chatbot/prompts.py](ai/chatbot/prompts.py) - Prompts

---

## 🐛 Troubleshooting

### Issue: "AI model not loaded"
**Solution:** Check Python path and imports
```bash
cd backend/ai_services/chatbot
python -c "import sys; sys.path.insert(0, '../../../ai/chatbot'); from workflow import Workflow; print('OK')"
```

### Issue: "OPENAI_API_KEY not set"
**Solution:** Create `.env` file with valid API key
```bash
cd ai/chatbot
echo "OPENAI_API_KEY=sk-your-key-here" > .env
```

### Issue: "Module not found: langchain_openai"
**Solution:** Install dependencies
```bash
pip install langchain-openai langchain-core langgraph
```

---

## 📝 Summary

**Before:** Chatbot used hardcoded keyword-based responses
**After:** Chatbot uses real GPT-4o-mini model via LangGraph workflow

**Files Changed:**
- ✏️ [backend/ai_services/chatbot/app.py](backend/ai_services/chatbot/app.py) - Complete rewrite
- ✏️ [backend/gateway.py](backend/gateway.py) - Added streaming support
- ✏️ [backend/flask_server/routes/ai.py](backend/flask_server/routes/ai.py) - Removed mock responses

**Files Now Being Used:**
- ✅ [ai/chatbot/agents.py](ai/chatbot/agents.py) - LLM inference
- ✅ [ai/chatbot/workflow.py](ai/chatbot/workflow.py) - Orchestration
- ✅ [ai/chatbot/models.py](ai/chatbot/models.py) - State
- ✅ [ai/chatbot/prompts.py](ai/chatbot/prompts.py) - Prompts

**Result:** ✅ Fully functional AI chatbot with ZERO static responses
