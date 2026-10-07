# InterviewAI Personalized Upgrade Report

## 1. Files added

- `backend/src/main/java/com/interviewai/controller/RoleController.java`
- `backend/src/main/java/com/interviewai/controller/TrainingController.java`
- `backend/src/main/java/com/interviewai/dto/RoleDtos.java`
- `backend/src/main/java/com/interviewai/service/RoleProfileService.java`
- `backend/src/main/java/com/interviewai/service/RoleAnalysisService.java`
- `backend/src/main/java/com/interviewai/service/TrainingPlanService.java`
- `backend/src/test/java/com/interviewai/service/RoleProfileServiceTest.java`
- `backend/src/test/java/com/interviewai/service/QuestionGenerationServiceTest.java`
- `frontend/src/pages/RoleSelection.tsx`
- `UPGRADE_CHANGELOG.md`
- `UPGRADE_REPORT.md`

## 2. Main files changed

Backend:

- `entity/Resume.java`
- `entity/Interview.java`
- `entity/ImprovementPlan.java`
- `dto/InterviewDtos.java`
- `dto/ReportDtos.java`
- `service/InterviewService.java`
- `service/QuestionGenerationService.java`
- `service/SkillGapService.java`
- `service/ReportService.java`
- `service/ProgressService.java`
- `repository/SkillGapRepository.java`
- `controller/InterviewController.java`
- `controller/ProgressController.java`

Frontend:

- `App.tsx`
- `api.ts`
- `store.ts`
- `types.ts`
- `components/Layout.tsx`
- `pages/Landing.tsx`
- `pages/Login.tsx`
- `pages/ResumePage.tsx`
- `pages/Setup.tsx`
- `pages/Dashboard.tsx`
- `pages/Report.tsx`
- `pages/SkillGap.tsx`
- `pages/ImprovementPlan.tsx`
- `pages/History.tsx`

Project/support:

- `README.md`
- `scripts/smoke-test.sh`

## 3. Database changes

Additive only; existing tables/relationships are retained.

### `resumes`
- `roleAnalysisJson` (`LONGTEXT`) – latest persisted role-specific resume analysis.

### `interviews`
- `selectedRole` – role chosen for the session.
- `resumeSkillMatch` – resume-to-role match at interview start.
- `readinessScore` – explainable combined readiness score.
- `retestOfInterviewId` – optional link to previous interview.

### `improvement_plans`
- `completedDays` – persisted 0–7 training-plan progress.

Existing `SkillGap` rows are now role-specific competency gaps after interview completion rather than only generic interview dimensions.

## 4. New APIs

- `GET /api/roles`
- `GET /api/roles/analysis/{userId}?role=...`
- `GET /api/roles/plan/{userId}?role=...`
- `GET /api/training/{interviewId}`
- `POST /api/training/{interviewId}/days/{day}/complete`
- `GET /api/progress/retest/{interviewId}`

Enhanced:

- `POST /api/interviews/start` now accepts `role` and optional `retestOfInterviewId`.
- `POST /api/answers` returns an evidence explanation and richer question metadata.
- `GET /api/evaluations/{id}/report` includes selected role, resume match, readiness score, role-specific gaps, interview weaknesses, and coaching.
- `GET /api/progress/{userId}` includes role, resume match, ML level, strong/weak role skills, readiness, previous/current score, and training progress.

## 5. ML changes

The original Java/Weka architecture is preserved:

- same Java ML runtime
- same `RandomForest`
- same 600-row bundled synthetic dataset
- same 13 input features
- same actual train/test evaluation path
- same serialized Java model path and portable fallback

The upgrade changes how ML is *used* in the product:

- interview questions are now role/resume/gap aware before feature aggregation;
- final reports combine the actual ML prediction with role-specific evidence;
- readiness is shown separately from the Random Forest class so the ML class is not disguised as an unexplained score;
- role gaps use resume evidence plus tested-answer evidence.

## 6. Complete user workflow

1. Login.
2. Select target role.
3. Upload resume or use demo resume.
4. Extract candidate evidence.
5. Compare evidence with expected skills for selected role.
6. Show role skill match + strong/moderate/weak/missing skills with reasons.
7. Build personalized five-round interview plan.
8. Run adaptive interview.
9. Evaluate each answer and adjust difficulty/follow-up.
10. Aggregate measured features.
11. Execute Weka Random Forest prediction.
12. Create final role-readiness and skill-gap report.
13. Generate personalized 7-day training plan.
14. Persist completed training days.
15. Start linked retest.
16. Compare previous/current performance and role-skill improvement.
17. Display longitudinal progress dashboard/history.

## 7. How to run

```bash
# MySQL
docker compose up -d mysql

# Backend
cd backend
mvn clean test
mvn spring-boot:run

# Frontend, separate terminal
cd frontend
npm install
npm run build
npm run dev

# Full API smoke flow, from project root
./scripts/smoke-test.sh
```

Open `http://localhost:5173`.

## 8. Validation/test results in the packaging environment

Passed locally in this packaging environment:

- shell syntax for `run-local.sh` and `scripts/smoke-test.sh`;
- bundled pre-trained model JSON validity;
- dataset structure check: exactly 600 rows and all four classes (`Poor`, `Average`, `Good`, `Excellent`);
- Java source parser pass: `javac` reported dependency-resolution errors only, with no Java syntax diagnostics;
- TypeScript source parser pass: global `tsc` parsed the frontend with no TypeScript syntax diagnostics.

Not runnable in this packaging environment:

- Maven unit/integration tests, because Maven is not installed;
- dependency-complete Vite production build, because npm registry/package installation is unavailable;
- MySQL connection/API smoke run, because no MySQL service is available.

The repository includes the exact commands and an expanded smoke test for these checks on a normal development machine.

## 9. Remaining limitations

- The built-in local NLP evaluator measures concept coverage and answer quality heuristics; it is not a substitute for an expert human deciding nuanced technical correctness.
- The role competency catalog is editable/configurable code, not a live labor-market ontology.
- If camera mode is disabled, presentation indicators are not shown in the report. Neutral values are used internally only where the existing fixed-width ML feature vector requires those optional inputs.
- Training completion is currently tracked by day completion, not by a full learning-management quiz engine.
- Production deployment would still require authentication hardening, DB migrations (Flyway/Liquibase), privacy/consent controls, rate limiting, and bias/accessibility review.
