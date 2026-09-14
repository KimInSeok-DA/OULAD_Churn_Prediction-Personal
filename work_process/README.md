# Work Process — 판단 기록과 단계별 보고서

이 폴더는 최종 결과에 이르기까지의 **판단 과정과 중간 보고서**를 모아 둔 곳이다.
결과만 보려면 이 폴더를 읽지 않아도 된다. 최종 결론은 [`docs/최종_분석_보고서.md`](../docs/최종_분석_보고서.md), 한 장 요약은 [`docs/포트폴리오_요약.md`](../docs/포트폴리오_요약.md)에 있다.

"왜 이렇게 정했는가", "어떤 대안을 버렸는가", "처음 결과에서 무엇이 잘못됐고 어떻게 고쳤는가"가 궁금할 때 참고한다.

## 읽는 법

- 각 문서는 **작성 시점의 기록**이다. 이후 정의가 바뀐 문서에는 맨 위에 갱신 안내를 달았고, 본문 수치는 당시 값을 유지했다.
- 최종 수치와 다르면 `docs/최종_분석_보고서.md`와 노트북 출력이 정본이다.
- 노트북·보고서에 나오는 `0913_01` 같은 번호는 아래 결정 문서 번호다.

## 추천 경로

| 궁금한 것 | 읽을 문서 |
|---|---|
| 문제를 왜 "25일 시점 재학생의 이후 이탈"로 정의했나 | [`0829_01`](./decisions/target_definition/0829_01_landmark_prediction_target.md) → [`0902_01`](./decisions/modeling/0902_01_landmark_n25_final.md) → [`reports/05`](./reports/05_landmark_25_28_32_comparison.md) |
| 첫 모델링에서 무엇이 문제였고 어떻게 고쳤나 | [`reports/06`](./reports/06_baseline_modeling_results.md) → [`reports/07`](./reports/07_pipeline_audit_before_final.md) → [`reports/08`](./reports/08_eda_and_modeling_revision.md) |
| 최종 모델과 위험 등급 기준을 왜 이렇게 정했나 | [`0913_02`](./decisions/modeling/0913_02_final_model_and_alert_tiers.md) → [`0913_03`](./decisions/modeling/0913_03_second_checkpoint_rule.md) → [`0913_04`](./decisions/modeling/0913_04_intervention_reasons_fairness.md) |
| 전처리(결측·이상치·공선성·평가 기회) 판단 | [`decisions/README.md`](./decisions/README.md)의 preprocessing 목록 |
| 프로젝트 전체 흐름 | [`reports/01`](./reports/01_project_history.md) |

## 구성

### `decisions/` — 판단 기록

한 문서에 하나의 결정을 담고, **배경 → 고려한 대안 → 결정 → 근거 → 트레이드오프** 순서로 쓴다. 목록은 [`decisions/README.md`](./decisions/README.md)에 있다.

| 주제 | 결정 |
|---|---|
| 예측 문제 | `0829_01` 예측 구조(그 시점 재학생의 이후 이탈), `0902_01` 랜드마크 N=25일 |
| 전처리 | `0912_01` 결측, `0912_02` 이상치, `0912_03` 공선성·최종 피처, `0913_01` 평가 기회·이월 정의 변경 |
| 모델·운영 | `0913_02` 최종 모델·1차 등급, `0913_03` 2차 체크포인트, `0913_04` 사유 코드·공정성, `0914_01` 과목 설계 제안 |

### `reports/` — 단계별 보고서

| 문서 | 내용 | 시점 |
|---|---|---|
| [`01_project_history`](./reports/01_project_history.md) | 기획부터 분석 완료까지의 작업 이력 | 전체 |
| [`02_analysis_findings`](./reports/02_analysis_findings.md) | 초기 EDA·관측창 분석의 핵심 발견, 데이터 품질·누수 방지 규칙 | 스터디 진행 단계 |
| [`03_current_status`](./reports/03_current_status.md) | 결측·이상치 처리 전 진행 상태 | 2026-09-12 시점 기록 |
| [`04_next_steps`](./reports/04_next_steps.md) | 당시 로드맵(P0–P6) | 2026-09-12 시점 기록 |
| [`05_landmark_25_28_32_comparison`](./reports/05_landmark_25_28_32_comparison.md) | 25·28·32일 랜드마크 비교 | 2026-08-29 |
| [`06_baseline_modeling_results`](./reports/06_baseline_modeling_results.md) | 첫 버전 모델링 결과 — 이후 검증·개정의 출발점 | 2026-09-13 (대체됨) |
| [`07_pipeline_audit_before_final`](./reports/07_pipeline_audit_before_final.md) | 최종 확정 전 파이프라인 전체 검증: 원본에서 피처를 독립 재계산하고 정의 결함 발견 | 2026-09-13 |
| [`08_eda_and_modeling_revision`](./reports/08_eda_and_modeling_revision.md) | 검증 결과를 반영한 25일 EDA 삽입과 모델링 개정 | 2026-09-13 |

모델 비교 이후의 최종 모델·등급·2차 체크포인트·개입 가이드·과목 설계 결과는 별도 보고서 대신 결정 문서와 `Notebooks/03_Modeling/03–07`, 최종 보고서에 정리했다.

## 공개하지 않은 것

- 일일 작업 로그와 작업 운영 규칙
- 재현 스냅샷(분석 단계 완료 시점의 노트북·산출물·모델 파일·해시 메타데이터 복사본). 저장소 코드와 산출물로 재생성할 수 있어 저장소 밖에 보관한다.
