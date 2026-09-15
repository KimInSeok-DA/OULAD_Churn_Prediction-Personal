# 25일 모델 대상 이상치 점검 및 처리 방침

> **2026-09-13 갱신 안내**: 노트북 번호 변경 `03_Missing_Outlier` → **`04_Missing_Outlier`**. 평가 기회·이월 정의 변경([[0913_01_assessment_opportunity_banked]]) 후 재실행에서도 도메인 유효성 위반 0건(이월 관련 점검 3종 추가)이며, `03_Landmark25_EDA` 7절에서 연속형 피처와 이탈률 관계가 극단 구간에서 뒤집히지 않음을 확인해 방침(제거·캡핑 없음)을 유지한다.
>
> 3.2절 IQR 극단값 비율은 결정 당시 값이다. 재실행 후 평가 관련 컬럼만 바뀌었다: `n_opportunity_25` 28.73% → **23.93%**, `submission_rate_25` 16.29% → **13.76%**, `n_missing_25` 12.31% → **11.04%**, `avg_submit_delay_25` 9.25% → **11.46%**, `avg_score_25` 3.17% → **5.83%**. 나머지 컬럼은 같고, 이산·경계형은 IQR 부적합이라는 판정도 그대로다.

## 상태

- 결정일: 2026-09-12
- 상태: 최종 확정
- 적용 범위: `Notebooks/02_Window_Integration/03_Missing_Outlier.ipynb`(당시 이름 → 현 `04_Missing_Outlier`, 7~8절, 점검) 및 이후
  모델별 전처리 파이프라인(모델 단계 처리)
- 근거 노트북: `Notebooks/02_Window_Integration/03_Missing_Outlier.ipynb` (7~8절, 현 `04_Missing_Outlier`)
- 선행 문서: [[0912_01_missing_value_policy]] (같은 노트북, 결측치 처리 방침)

## 1. 배경

`model_df_clean`(27,654행)을 대상으로 수치형 피처 12개의 이상치를 점검한다:
`num_of_prev_attempts`, `studied_credits`, `date_registration`, `total_click_25`,
`active_days_25`, `distinct_resources_25`, `n_opportunity_25`, `n_submitted_25`,
`n_missing_25`, `submission_rate_25`, `avg_score_25`, `avg_submit_delay_25`.

결측치 처리에 이어 이상치 점검(`total_click_25`, `avg_submit_delay_25` 등 이상치 점검)에 따라
진행한다.

## 2. 점검 방법

1. **도메인 유효 범위 점검**: 물리적으로 불가능한 값(음수 카운트, 비율/점수 범위 이탈,
   제출·미제출 건수가 기회 건수를 초과하는 논리 모순)이 있는지 확인
2. **IQR×1.5 기준 극단값 규모**: 컬럼별 이상치 비율 산출
3. **상위/하위 극단값 개별 확인**: 극단값이 데이터 오류인지 정상적인 극단 행동인지 원본
   행 단위로 검토

## 3. 결과

### 3.1 도메인 유효 범위 점검 — 위반 0건

아래 9개 항목 모두 위반 건수 0건을 확인했다.

| 점검 항목 | 위반 건수 |
|---|---:|
| `total_click_25` 음수 | 0 |
| `active_days_25` 범위(0~26) 이탈 | 0 |
| `distinct_resources_25` 음수 | 0 |
| `n_opportunity_25` 범위(0~2) 이탈 | 0 |
| `n_submitted_25 > n_opportunity_25` | 0 |
| `n_missing_25 > n_opportunity_25` | 0 |
| `submission_rate_25` 범위(0~1) 이탈 | 0 |
| `avg_score_25` 범위(0~100) 이탈 | 0 |
| `studied_credits <= 0` | 0 |

즉 명백한 오류성 이상치(데이터 수집·적재 과정의 물리적 모순)는 없다.

### 3.2 IQR×1.5 기준 극단값 비율

| 컬럼 | 이상치 비율 | 비고 |
|---|---:|---|
| `n_opportunity_25` | 28.73% | 값이 {0,1,2}뿐인 이산·경계형 — IQR 부적합 |
| `submission_rate_25` | 16.29% | 값이 [0,1] 경계에 몰림 — IQR 부적합 |
| `num_of_prev_attempts` | 12.62% | 값이 {0,1,2,...}로 0에 집중 — IQR 부적합 |
| `n_missing_25` | 12.31% | 값이 {0,1,2}뿐 — IQR 부적합 |
| `avg_submit_delay_25` | 9.25% | 연속형, 3.3절에서 개별 확인 |
| `total_click_25` | 5.75% | 연속형, 3.3절에서 개별 확인 |
| `studied_credits` | 5.46% | 연속형(이산 단계), 3.3절에서 개별 확인 |
| `avg_score_25` | 3.17% | 연속형(0~100 상한 있음), 하단 극단만 존재 |
| `distinct_resources_25` | 2.55% | 연속형, 3.3절에서 개별 확인 |
| `date_registration` | 1.31% | 연속형, 3.3절에서 개별 확인 |
| `active_days_25` | 0.00% | 상한(26)에 자연스럽게 눌려 IQR 밖 값 없음 |
| `n_submitted_25` | 0.00% | 값이 {0,1,2}뿐이나 이번엔 IQR 밖 값 없음 |

**주의**: `n_opportunity_25`, `n_missing_25`, `submission_rate_25`, `num_of_prev_attempts`처럼
값이 소수의 정수/경계값에 몰린 이산·경계형 컬럼은 IQR이 0에 가까워지므로, 정상 값(예:
`n_opportunity_25 == 2`, 재수강 1회)까지 기계적으로 "이상치"로 잡힌다. 이 컬럼들은 IQR
판정 자체가 부적합하므로 개별 확인 대상에서 제외하고, 3.1절 도메인 유효성 검사(위반 0건)로
충분하다고 판단한다.

### 3.3 상위/하위 극단값 개별 확인

- `total_click_25`/`distinct_resources_25` 상위값: 25일 동안 최대 5,818회 클릭, 최대 257개
  자원에 접근한 사례가 있으나, 동일 타임스탬프 반복이나 음수·비정상 자원 수 등 수집 오류로
  의심할 패턴은 없다. 짧은 기간 내 매우 활발한 고몰입 학습 행동으로 해석한다.
- `studied_credits` 상위값(최대 630): 여러 과목을 동시 수강하는 학생으로, OULAD 도메인에서
  흔한 패턴이며 오류가 아니다.
- `date_registration` 최솟값(최대 -311, 개강 약 10개월 전 등록): 조기 등록으로 해석 가능한
  범위이며, 같은 학생이 여러 수강에서 반복 등장하는 등 오류를 의심할 패턴은 없다.
- `avg_submit_delay_25` 양쪽 극단(최소 -35, 최대 13): 매우 이른 제출/마감 이후 제출이지만
  `n_submitted_25`와 모순되지 않는다.

결론: 점검한 극단값은 **데이터 수집 오류가 아니라 정상 범위 내의 극단적 학생 행동**이다.

## 4. 처리 방침 (확정)

- 도메인상 불가능한 값이 없으므로 **행 제거는 하지 않는다.**
- 극단값은 실제 신호(고몰입/저몰입 행동)일 가능성이 높으므로 **임의 캡핑(winsorize)도
  하지 않는다.** 결측치와 달리 이상치는 정보를 담고 있어 제거·변형 시 신호 손실 위험이 크다.
- **트리 기반 모델(RandomForest, XGBoost)**: 값의 크기가 아니라 순서(분기 기준)만 사용하므로
  극단값에 영향을 받지 않는다. 별도 처리 불필요.
- **Logistic Regression**: 값의 크기(거리)에 민감하므로 이상치 제거 대신 `RobustScaler`
  (중앙값·IQR 기반 스케일링)를 사용해 극단값의 영향을 완화한다. `StandardScaler`(평균·표준편차
  기반)는 극단값에 민감해 이 데이터셋에는 부적합하므로 사용하지 않는다.
- `imd_band`/`date_registration` 결측 처리는 [[0912_01_missing_value_policy]] 4절 방침을
  그대로 따른다(이 문서의 범위 아님).

## 5. 검증

- 노트북 실행 결과: `model_df_clean` 27,654행 기준, 도메인 유효성 위반 0건(9개 항목),
  IQR 극단값 비율 0.00%~28.73%(이산·경계형 컬럼은 판정 부적합으로 해석에서 제외)
- 상위 10건 개별 확인(`total_click_25`, `distinct_resources_25`, `studied_credits`,
  `date_registration` 하위 10건, `avg_submit_delay_25` 상하위 5건씩): 오류 의심 패턴 없음
- 전체 노트북 재실행, 에러 0건

## 6. 다음 작업

1. [[0912_01_missing_value_policy]] 5절(모델별 결측 전략)과 이 문서의 4절(모델별 이상치
   전략)을 통합해 모델별 `Pipeline`/`ColumnTransformer`를 구현한다.
2. Group split/학기 holdout 검증 방식 결정 후 베이스라인 모델링(더미 → Logistic →
   RandomForest → XGBoost)을 진행한다.
