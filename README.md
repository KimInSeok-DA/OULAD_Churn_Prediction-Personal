# OULAD Churn Prediction

OULAD(Open University Learning Analytics Dataset)를 활용해 **개강 후 N일 시점에 재학 중인 학생의 이후 이탈**을 예측하고, 실제 개입 가능한 위험 신호를 찾는 프로젝트다.

## 현재 예측 목표

> 개강 후 25일 시점에 아직 재학 중인 학생을 대상으로, 최초 25일까지 관측 가능한 정보만 사용해 25일 이후 중도이탈을 예측한다.

- 25일 이전에 이미 이탈한 학생은 주 모델에서 제외하고 별도 초기 이탈 분석 대상으로 다룬다.
- 25·28·32일 비교 결과를 근거로 랜드마크를 25일로 최종 확정했다.
- 기존 28일 통합 SQL/CSV의 `label_churn_28d`는 과거 초안 타깃이므로 최종 모델링에 그대로 사용하지 않는다.
- 국내 직업훈련 공공데이터와 대시보드는 핵심 OULAD 모델을 완성한 뒤 검토할 확장 범위로 보류한다.

## 진행 배경

프로젝트 기획, 데이터 이해, 개별·조인 EDA, 가설 검증, 관측창 후보 분석을 거쳐 **모델링용 통합 테이블을 확정하기 직전 단계까지는 스터디원들과 함께 진행**했다.

이후 스터디를 더 진행하기 어려워져, 다음 단계부터는 개인 프로젝트로 이어간다.

- 관측창 최종 확정
- 25일 전체 코호트 단일 통합 테이블 구축(완료)
- 결측치·이상치 처리
- 통합 후 공선성 재검증과 최종 피처 선정
- 모델 비교·평가·해석
- 개입 전략 및 최종 발표자료 정리

## 폴더 안내

- `Notebooks/01_EDA_Basic`: 스터디 과정의 기본 EDA 및 단계별 조인 작업
- `Notebooks/02_Window_Integration`: 관측창 검증과 이후 통합 테이블 작업 공간
- `reference_materials/personal_prework`: 스터디원을 지원하고 후속 작업을 미리 검토하기 위해 개인적으로 선행한 분석 자료. 정식 공동 진행 결과나 최종 모델이 아니라 참고용이다.
- `work_process/decisions`: 랜드마크와 예측 타깃을 선택한 근거
- `work_process/reports`: 프로젝트 이력, 분석 결과, 현재 상태와 향후 계획
- `docs`: 데이터 사전 등 프로젝트 문서
- `CSV_files`: 원본 CSV와 `통합 버전/landmark25_all_cohorts.csv` 정본

분석의 현재 상태는 [`03_current_status.md`](./work_process/reports/03_current_status.md), 이후 계획은
[`04_next_steps.md`](./work_process/reports/04_next_steps.md), N=25 선정 근거는
[`0902_01_landmark_n25_final.md`](./work_process/decisions/modeling/0902_01_landmark_n25_final.md)에서 확인할 수 있다.

프로젝트 범위와 실행 계획의 정본은 [`docs/OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx`](./docs/OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx)다.
