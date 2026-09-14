# OULAD Churn Prediction

OULAD(Open University Learning Analytics Dataset)로 **개강 후 25일 시점 재학생의 이후 중도 이탈**을 예측하고, 그 결과를 **관리자(튜터·학사 담당)용 조기 경고 체계**로 만든 프로젝트다.

> 최종 결론과 근거는 [`docs/최종_분석_보고서.md`](./docs/최종_분석_보고서.md)에 정리했다.

## 예측 목표

> 개강 후 25일 시점에 아직 재학 중인 학생을 대상으로, 최초 25일까지 관측 가능한 정보만 사용해 25일 이후 중도 이탈(`Withdrawn`)을 예측한다.

- 25일 전에 이미 이탈한 학생(전체 이탈의 47%)은 주 모델에서 제외한다. 이들은 별도의 초기 이탈 과제로 다룬다.
- 25·28·32일을 비교해 25일을 확정했다. 25일이 개입 대상을 가장 많이 남기고 성능도 가장 높았다.
- 개발 학기는 2013B·2013J·2014B이고, **2014J는 모델과 기준을 개발 학기로 고정한 뒤에만 평가한 holdout**이다(holdout 결과를 보고 모델·기준을 바꾸지 않음).

## 핵심 결과

| 항목 | 결과 |
|---|---|
| 최종 모델 | XGBoost + sigmoid 확률 보정, 피처 20개 |
| holdout 성능 (2014J) | PR-AUC 0.357(이탈률 대비 1.9배), 평균 예측 18.0% vs 실제 18.8% |
| 주요 이탈 요인 | 25일 내 평가 점수·제출 여부·제출 시점 > 과목 구조 > 수강 학점 (평가가 늦은 과목은 학습 접속) |
| 1차(25일) 등급 | 고위험 ≥ 40% / 주의 20–40% / 관찰 13–20% 또는 과목·학기 내 상위 30% / 일반 |
| 2차(과목별 첫 평가 마감일) | 관찰 등급이 해당 평가를 미제출하면 주의로 승격 |
| 체계 성과 (holdout) | 관리자 명단 39.6%가 이탈자 63.8%를 포착, 고위험 실제 이탈률 47.0% |
| 개입 지원 | 학생별 위험 사유 상위 2개 제공(명단의 91%가 개입 가능한 사유 보유) |
| 공정성 | 집단별 확률 보정 차이 ≤ 3.3%p. 인구통계 사유는 지원 연계에만 사용 |
| 과목 설계 제안 | 첫 평가 성적 가중치·초기 참여 설계는 조기 탐지에 유리(근거 강·중), 평가 과밀은 완주자 합격률과 음의 관계. 설계만으로 이탈 감소 근거는 약함 |

위험 등급은 **학생에게 통보하지 않고 관리자에게만** 전달한다. 학생에게는 위험도와 무관한 마감 리마인더를 전원 발송한다.

## 분석 흐름

| 단계 | 노트북 | 내용 |
|---|---|---|
| 기본 EDA | `Notebooks/01_EDA_Basic/01–06` | 개별 테이블 EDA, 단계별 조인 (스터디 진행분) |
| 관측창 결정 | `02_Window_Integration/01_Window_Definition` | 25·28·32일 비교, 25일 확정 |
| 통합 테이블 | `02_Window_Integration/02_Integrated_Table` | 25일 코호트 정본 구축, 평가 기회·이월 평가 정의 |
| 25일 EDA | `02_Window_Integration/03_Landmark25_EDA` | 과목별 차이, 평가 일정, 이월 재수강, 성별 심슨의 역설 |
| 정제 | `02_Window_Integration/04_Missing_Outlier` | 결측 정책, 이상치 처리 |
| 피처 선정 | `02_Window_Integration/05_Collinearity_Recheck` | 항등식 기반 공선성 제거, 최종 피처 20개 |
| 모델 비교 | `03_Modeling/01_Baseline_Models` | Logistic·RF·XGBoost, 과목별 성능, 학기 단위 검증 |
| 이탈 요인 | `03_Modeling/02_Feature_Importance` | 순열 중요도, 오즈비, SHAP |
| 최종 모델·등급 | `03_Modeling/03_Final_Model_Tiers` | 확률 보정, 1차 등급 기준, holdout 평가 |
| 2차 체크포인트 | `03_Modeling/04_Second_Checkpoint` | 과목별 첫 평가 마감일 승격 규칙 |
| 개입 가이드 | `03_Modeling/05_Intervention_Guide` | 위험 사유 코드, 관리자 업무량, 공정성 점검 |
| 민감도 분석 | `03_Modeling/06_Sensitivity_Ambiguous` | 취소일 없는 Withdrawn 93명 포함 시 결론 변화 |
| 과목 설계 제안 | `03_Modeling/07_Course_Design_Indicators` | 과목×학기 설계 지표와 이탈·성취·조기 탐지·운영의 관계, 목적별 설계 제안 |

노트북은 위 순서대로 실행한다. 각 노트북은 앞 단계의 `CSV_files` 산출물을 읽는다.

## 폴더 안내

- `Notebooks/`: 위 분석 흐름의 노트북
- `CSV_files/`: OULAD 원본 CSV
  - `통합 버전/`: 25일 코호트 정본(`landmark25_all_cohorts.csv`), 정제 모델 테이블, 피처 명세
  - `모델링/`: 모델 비교·중요도·등급·2차 규칙·사유 코드·공정성·민감도·과목 설계 산출물
- `docs/`: 최종 분석 보고서, 데이터 사전, 기획서
- `reference_materials/personal_prework`: 스터디 지원용 개인 선행 분석(참고용, 최종 결과 아님)

## 실행 환경

- Python 3.14, pandas 3.0, scikit-learn 1.9, xgboost 3.3, statsmodels, matplotlib, seaborn (`pyproject.toml`, `uv.lock`)
- 모든 난수는 `random_state=42`로 고정했다.

```bash
uv sync                                   # 의존성 설치
uv run --with jupyter jupyter lab         # 노트북을 분석 흐름 순서대로 실행
```

- 그래프 한글 글꼴은 `Malgun Gothic`(Windows)을 사용한다. 다른 OS에서는 각 노트북 첫 셀의 `font.family`를 바꾼다.
- `03_Modeling/01_Baseline_Models`는 그리드 탐색 때문에 약 14분 걸린다. 메모리가 부족하면 노트북의 `N_JOBS`를 줄인다.

## 진행 배경

기획, 데이터 이해, 개별·조인 EDA, 가설 검증, 관측창 후보 분석까지는 스터디원들과 함께 진행했다. 이후 관측창 확정, 통합 테이블, 정제, 모델링, 조기 경고 체계, 개입 가이드는 개인 프로젝트로 이어갔다.

## 데이터 출처

Kuzilek, J., Hlosta, M., & Zdrahal, Z. (2017). Open University Learning Analytics dataset. *Scientific Data*, 4, 170171.

프로젝트 범위와 실행 계획은 [`docs/OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx`](./docs/OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx), 변수 정의는 [`docs/데이터_사전.md`](./docs/데이터_사전.md)에서 확인할 수 있다.
