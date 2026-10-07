# InterviewAI

## AI-Powered Interview Performance Analyzer and Personal Coach Using Machine Learning

InterviewAI is a solo 3rd-year AIML college project built around a measurable learning loop:

**Understand Candidate → Identify Role-Specific Gaps → Personalized Adaptive Interview → AI + ML Evaluation → Targeted Training → Retest → Measure Improvement**

The project keeps Java as the primary backend and ML runtime. It uses **React + TypeScript + Vite + Tailwind + Recharts**, **Java 21 + Spring Boot**, **MySQL/JPA**, local Java NLP/text processing, **Weka Random Forest**, Apache PDFBox, and optional OpenCV presentation indicators.

> The bundled interview-performance CSV is a **synthetic training/demo dataset**. It is not real hiring data. Weka metrics are calculated from the held-out test set at runtime and are not hard-coded.

## What changed in the personalized upgrade

The original architecture remains intact. The upgrade adds role-aware personalization rather than rebuilding the application:

1. Student selects a target role.
2. Resume is parsed and compared with that role's expected competency profile.
3. InterviewAI shows strong, moderate, weak, and missing skills with evidence-based explanations.
4. A five-round interview plan is built from the role + resume + skill gaps.
5. Questions adapt to answer quality and intentionally probe priority gaps without making every question a weakness question.
6. Answer signals are aggregated into the existing Weka Random Forest feature vector.
7. Post-interview role gaps combine resume evidence and interview evidence.
8. A personalized 7-day training plan is created from the actual latest gaps.
9. Training-day completion is persisted.
10. Retest sessions can be linked to the previous interview and compared.
11. The dashboard shows role, resume match, readiness, ML level, training progress, score history, and improvement.

## Differentiation

InterviewAI does **not** claim that AI interview evaluation is new. Its focus is the combination of:

**Resume-Personalized Adaptive Interview + Role-Specific Skill Matching + Multi-Factor Performance Analysis + Java ML Prediction + Evidence-Based Skill Gaps + Personalized Training + Retest/Progress Tracking**

The system is designed to answer:

> **What am I weak at, why am I weak at it, and what should I practice to improve?**

## Architecture

```text
React + TypeScript + Vite + Tailwind + Recharts
                    |
                    v
             Spring Boot REST API
                    |
      +-------------+--------------+
      |             |              |
      v             v              v
Resume/NLP     Adaptive AI      Weka ML
analysis       orchestration    Random Forest
      |             |              |
      +-------------+--------------+
                    |
                    v
                 MySQL
```

Optional camera frames are sent to the Java backend. OpenCV performs basic face-position analysis and produces **AI-estimated presentation indicators**. These indicators are coaching aids only and are not personality, honesty, confidence, or psychological assessments.

## AI layer vs ML layer

### AI / NLP layer

- PDF resume extraction
- skill and programming-language extraction
- candidate profile creation
- role-specific resume comparison
- personalized interview planning
- adaptive question generation
- follow-up selection
- answer concept/relevance/completeness/structure analysis
- evidence-linked feedback
- personalized coaching generation

### ML layer

- Java feature engineering
- train/test split
- Weka Random Forest training
- model evaluation
- model serialization/loading
- performance classification: `Poor`, `Average`, `Good`, `Excellent`
- probability/confidence output
- readiness support using measured interview performance

Java remains responsible for the final ML inference path.

## Supported target roles

The built-in role catalog currently includes:

- Java Developer
- Python Developer
- Full Stack Developer
- Data Analyst
- Data Scientist
- Machine Learning Engineer
- AI Engineer
- Software Developer

Each role has an expected skill profile. Example for **Java Developer**:

`Java, OOP, Collections, Exception Handling, JDBC, SQL, Spring Boot, REST API, Git, DBMS`

The catalog is defined in:

`backend/src/main/java/com/interviewai/service/RoleProfileService.java`

It can be expanded without changing the ML model.

## Resume analysis

PDF resumes are extracted with Apache PDFBox. InterviewAI creates a candidate profile from text actually detected in the document. It does not fabricate missing resume content.

For the selected role, every expected skill receives:

- a score
- `STRONG`, `MODERATE`, `WEAK`, or `MISSING`
- an explanation
- supporting resume evidence when available

The role skill-match percentage is the mean of the role competency evidence scores.

Role analysis is persisted on the latest resume in `roleAnalysisJson` and the numeric match is copied to the interview when the session begins.

## Personalized five-round interview

The interview is deliberately balanced:

1. **Round 1 – Foundation**: introduction + role motivation / baseline competency
2. **Round 2 – Resume / Project**: validates resume evidence and personal contribution
3. **Round 3 – Core Technical**: role-aligned technical depth
4. **Round 4 – Weak-Skill Probe**: highest-priority role gap
5. **Round 5 – Scenario / Problem Solving**: diagnosis, trade-offs, validation

Difficulty adapts after each answer:

- score >= 78 → increase depth when possible
- score < 55 → reduce difficulty / return to fundamentals
- partial answers → probe missing concepts

The next question is generated from the candidate profile, selected role, current role analysis, answer score, and missing concepts.

## Answer evaluation

For each answer the Java backend calculates:

- technical concept coverage
- relevance
- completeness
- structure
- communication quality
- filler words
- speaking pace
- correct/covered expected concepts
- optional eye/camera alignment
- optional posture/alignment

The API returns:

- score / 100
- strengths
- weaknesses
- missing concepts
- improvement recommendation
- a short evidence explanation
- next adaptive question

The local evaluator is deterministic and explainable. It does not pretend that keyword rules can scientifically infer personality or true confidence.

## Machine-learning dataset

`backend/src/main/resources/data/interview_performance.csv`

Features:

- `technicalKnowledge`
- `communication`
- `relevance`
- `completeness`
- `responseTime`
- `answerLength`
- `fillerWords`
- `speakingPace`
- `eyeContact`
- `posture`
- `previousScore`
- `correctConcepts`
- `questionDifficulty`

Target:

- `performanceLevel` = `Poor`, `Average`, `Good`, `Excellent`

The bundled CSV contains synthetic demo rows spanning all target classes.

## ML training pipeline

```text
CSV dataset
   ↓
Weka Instances
   ↓
Randomize with fixed seed
   ↓
80/20 train-test split
   ↓
Random Forest training
   ↓
Held-out Evaluation
   ↓
Accuracy / Precision / Recall / F1 / Confusion Matrix
   ↓
Serialize Java/Weka model
   ↓
Load model in Spring Boot
   ↓
Candidate feature vector
   ↓
Performance class + probability
```

On backend startup, the primary Weka pipeline trains/evaluates from the bundled dataset. A genuine Java-readable pre-trained forest snapshot is included as a demo fallback if the Weka initialization path cannot run.

### Train manually

```bash
curl -X POST http://localhost:8080/api/ml/train
```

### View real evaluation metrics

```bash
curl http://localhost:8080/api/ml/metrics
```

## Role-specific post-interview skill gaps

After completion, InterviewAI combines:

- selected role
- resume role-analysis score
- questions actually asked
- answer technical/completeness/relevance scores
- ML prediction

For a role skill that was tested, the current gap score combines resume evidence and measured interview evidence. For an untested role skill, the resume assessment remains the available evidence.

Each gap includes an explanation such as:

> Spring Boot is a priority gap for the Java Developer role because resume evidence was missing and interview answers on this area averaged 58%. Combined evidence score: 45%.

This is preferable to showing an unexplained percentage.

## Personalized training and retest

A completed interview produces a seven-day plan based on the latest priority gaps:

- Day 1: fundamentals
- Day 2: core concepts
- Day 3: practical usage
- Day 4: mistakes/trade-offs
- Day 5: targeted questions
- Day 6: timed mock interview
- Day 7: retest and comparison

Training-day completion is stored on the existing `ImprovementPlan` entity.

A retest can link to a previous interview with `retestOfInterviewId`. The comparison API shows:

- previous score
- current score
- score improvement
- previous readiness
- current readiness
- role skills that improved when comparable evidence exists

## Readiness score

The project exposes two related results:

1. **ML performance class / confidence** from the Weka Random Forest.
2. **Role readiness score** calculated from measured interview performance and role-specific resume match.

The readiness score is intentionally explainable rather than presented as a mysterious AI number:

`readinessScore = 72% interview performance + 28% role resume match`

This does not replace the ML prediction; it complements it with role evidence.

## Database design

Existing normalized tables are preserved:

- `users`
- `resumes`
- `skills`
- `interviews`
- `questions`
- `answers`
- `evaluations`
- `ml_predictions`
- `skill_gaps`
- `improvement_plans`

### Additive schema changes

`resumes`

- `role_analysis_json` – persisted role-specific resume assessment

`interviews`

- `selected_role`
- `resume_skill_match`
- `readiness_score`
- `retest_of_interview_id`

`improvement_plans`

- `completed_days`

No existing table is replaced. With the supplied development configuration, Hibernate applies additive changes via `spring.jpa.hibernate.ddl-auto=update`.

## REST API

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/login` | Create/find local demo user |
| GET | `/api/roles` | Supported roles + expected skills |
| GET | `/api/roles/analysis/{userId}?role=Java%20Developer` | Role-specific resume analysis |
| GET | `/api/roles/plan/{userId}?role=Java%20Developer` | Personalized five-round plan |
| POST | `/api/resumes/upload?userId={id}` | Upload PDF resume |
| POST | `/api/resumes/demo?userId={id}` | Load sample profile |
| GET | `/api/resumes/latest/{userId}` | Latest extracted profile |
| POST | `/api/interviews/start` | Start role-aware interview |
| GET | `/api/interviews/{id}/current-question` | Current adaptive question |
| POST | `/api/answers` | Evaluate answer + generate next question |
| POST | `/api/evaluations/{id}/complete` | Complete session + create ML prediction/gaps |
| GET | `/api/evaluations/{id}/report` | Evidence-based final report |
| GET | `/api/training/{interviewId}` | Personalized 7-day training plan |
| POST | `/api/training/{interviewId}/days/{day}/complete` | Persist training progress |
| GET | `/api/progress/{userId}` | Dashboard history/progress |
| GET | `/api/progress/retest/{interviewId}` | Compare current session to linked/previous session |
| GET | `/api/interviews/history/{userId}` | Interview history |
| POST | `/api/ml/train` | Retrain Random Forest |
| GET | `/api/ml/metrics` | Held-out model metrics |
| POST | `/api/ml/predict` | Direct feature-vector prediction |
| POST | `/api/presentation/frame` | Optional OpenCV frame analysis |

### Start-interview body

```json
{
  "userId": 1,
  "type": "MIXED",
  "difficulty": 2,
  "demoMode": false,
  "role": "Java Developer",
  "retestOfInterviewId": null
}
```

## Frontend workflow

1. Login
2. Select Target Role
3. Upload Resume / Demo Resume
4. Resume Role-Skill Analysis
5. Personalized Interview Preparation
6. Live Mock Interview
7. Answer Evaluation during interview
8. Final Role-Specific Skill-Gap Report
9. Personalized 7-Day Training Plan
10. Linked Retest
11. Progress Dashboard / History

## Run the project

### Requirements

- Java 21 recommended (Java 17+ compatible target can be used with dependency review)
- Maven 3.9+
- Node.js 20+
- npm
- MySQL 8+
- optional Docker / Docker Compose

### 1. Start MySQL

Recommended:

```bash
docker compose up -d mysql
```

Defaults:

- database: `interviewai`
- username: `interviewai`
- password: `interviewai`
- port: `3306`

Override with:

- `DB_URL`
- `DB_USER`
- `DB_PASSWORD`

### 2. Start Spring Boot

```bash
cd backend
mvn clean test
mvn spring-boot:run
```

Backend: `http://localhost:8080`

### 3. Start React

```bash
cd frontend
npm install
npm run build
npm run dev
```

Frontend: `http://localhost:5173`

## Automated smoke flow

With MySQL + backend running:

```bash
./scripts/smoke-test.sh
```

The script verifies:

- login
- supported roles
- demo resume
- role-specific resume analysis
- personalized interview plan
- role-aware interview creation
- five adaptive answers
- final ML prediction/report
- personalized training plan
- stored training progress
- progress dashboard API
- real model metrics
- direct Java ML prediction

## Tests

Backend:

```bash
cd backend
mvn test
```

Frontend:

```bash
cd frontend
npm install
npm run build
```

Full workflow:

```bash
./scripts/smoke-test.sh
```

## Demo Mode

Demo mode still executes the real pipeline. It can use the included sample resume, but the student still selects a role first. The application calls the same resume analysis, interview, answer-evaluation, Weka prediction, skill-gap, training, and progress services used by normal sessions.

## Judge-friendly explanation

**Where is AI?**  
Resume parsing, role-skill extraction/comparison, question personalization, adaptive follow-ups, answer analysis, evidence-linked feedback, and coaching are implemented in the Java AI/NLP service layer.

**Where is Machine Learning?**  
A supervised Weka Random Forest is trained on interview-performance features, evaluated on a held-out split, serialized, loaded by Spring Boot, and used to classify completed interviews as Poor/Average/Good/Excellent with confidence.

**Why Java?**  
Spring Boot is the primary backend, and model training, model loading, feature engineering, prediction, NLP orchestration, report generation, and persistence all execute in Java.

**What is unique?**  
“Our focus is not simply giving an interview score. InterviewAI understands the candidate against a selected role, finds evidence-based skill gaps, runs an adaptive role-aware interview, predicts performance with Java ML, creates targeted training, and proves improvement through retesting.”

## Responsible-use note

InterviewAI is a learning/coaching project, not a hiring-decision system. Camera metrics are optional **AI-estimated presentation indicators** and must not be interpreted as personality, honesty, mental state, employability, or true confidence. Real hiring use would require privacy controls, accessibility review, bias testing, consent, security hardening, and human oversight.

## Validation status for this packaged copy

The repository includes a complete API smoke script and backend unit tests. In the build environment used to prepare this package:

- Java 21 is available.
- A global TypeScript compiler is available and parses the frontend source, but package dependencies (`react`, `react-router-dom`, Recharts, etc.) are not installed because registry access is unavailable.
- Maven is not installed in the build environment.
- No local MySQL service is available for an end-to-end database run.

Therefore this package does **not** claim that Maven tests, the Vite production build, or live MySQL smoke tests were executed in that environment. Run the commands above on a normal development machine to perform those environment-dependent checks.
