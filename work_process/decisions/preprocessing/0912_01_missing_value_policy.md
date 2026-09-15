# 25일 모델 대상 결측치 원인 진단 및 처리 방침

> **2026-09-13 갱신 안내**
> - 노트북 번호 변경: `03_Missing_Outlier` → **`04_Missing_Outlier`** (25일 코호트 EDA `03_Landmark25_EDA` 삽입). 아래 본문의 옛 이름은 같은 노트북이다.
> - 평가 기회·이월 정의 변경([[0913_01_assessment_opportunity_banked]])으로 결측 건수가 바뀌었다: `avg_score_25` 10,023 → **8,362**, `avg_submit_delay_25` 10,017 → **8,355**, `submission_rate_25` 6,766 → **5,453**. 결측 원인에 "이월로 기회 없음"(463명, 이탈률 24.8%)이 추가됐고 처리 방침(NaN 유지, 모델별 분기)은 그대로다. 본문 수치는 결정 당시 값이다.
> - `imd_band` 결측 원인 해석을 수정했다(3.2절 해당 문단).

## 상태

- 결정일: 2026-09-12
- 상태: 최종 확정
- 적용 범위: `Notebooks/02_Window_Integration/03_Missing_Outlier.ipynb`(당시 이름 → 현 `04_Missing_Outlier`, 데이터셋 단계 처리) 및 이후 모델별 전처리 파이프라인(모델 단계 처리)
- 근거 노트북: `Notebooks/02_Window_Integration/03_Missing_Outlier.ipynb` (4~6절, 현 `04_Missing_Outlier`)

## 1. 배경

`landmark25_all_cohorts.csv`에서 추출한 모델 대상(`model_df`, 27,661행)에 결측이 있는 컬럼은 5개다:
`imd_band`, `date_registration`, `avg_score_25`, `avg_submit_delay_25`, `submission_rate_25`.
25일 통합 정본을 확정한 뒤, 모델링 전 단계로 결측 원인을 진단하고 처리 방침을 정한다.

## 2. 결측 현황

| 컬럼 | 결측 건수 | 결측 비율 |
|---|---:|---:|
| `imd_band` | 1,030 | 3.72% |
| `date_registration` | 7 | 0.03% |
| `avg_score_25` | 10,023 | 36.24% |
| `avg_submit_delay_25` | 10,017 | 36.21% |
| `submission_rate_25` | 6,766 | 24.46% |

## 3. 원인 진단

### 3.1 평가 행동 결측 (`submission_rate_25`, `avg_score_25`, `avg_submit_delay_25`)

- `submission_rate_25` 결측 6,766건은 `no_assessment_opportunity_25 == 1`(=`n_opportunity_25 == 0`)과 **100% 일치**한다. 완전한 구조적 결측이며 기존 플래그로 원인이 전부 설명된다.
- `avg_score_25`/`avg_submit_delay_25` 결측(각 10,023건/10,017건)은 대부분 `n_submitted_25 == 0`(기회 없음 6,766건 + 기회는 있었으나 미제출 3,251건)로 설명된다. 두 원인 모두 이미 `no_assessment_opportunity_25`, `n_submitted_25` 피처에 드러나 있어 구조적 결측이다.
- 예외적으로 `avg_score_25`만 6건이 제출 기록(`n_submitted_25 > 0`)이 있음에도 결측이다. 비중이 0.02%로 극히 작아 전체 결론에 영향을 주지 않으며, 원본 `studentAssessment` 점수 필드 자체가 비어 있는 개별 사례로 추정된다.

### 3.2 `imd_band` 결측 — 지역별 분포

결측이 `North Region`(43.7%)과 `Ireland`(22.6%)에 집중되고 나머지 11개 지역은 2% 미만(대다수 0%)이다. 즉 무작위 결측이 아니라 특정 지역에 집중된 결측이다.

> **2026-09-13 해석 수정**: 처음에는 "IMD가 잉글랜드 지표라 잉글랜드 외 지역에는 값이 없다"로 해석했으나 데이터와 맞지 않아 철회한다. 결측률 1위 **North Region은 잉글랜드**이고, 잉글랜드 외 지역인 **Scotland(0.3%)·Wales(0.0%)는 결측이 거의 없다**. 원인은 "특정 지역(North Region, Ireland)의 수집 누락, 원인 불명"으로 기술한다. 결측 행의 이탈률(15.1%)이 값 있는 행(19.1%)과 달라 결측 자체가 약한 정보를 가지므로 `Unknown` 범주 처리는 그대로 유지한다(`03_Landmark25_EDA` 12절).

### 3.3 `date_registration` 결측 (7건)

7건이 특정 모듈·학기에 집중되지 않고(BBB/CCC/DDD×3/EEE/FFF), `total_click_25`·`n_opportunity_25` 등 다른 피처는 결측 없이 채워져 있다.

다만 재검토 결과 다음 패턴이 확인된다:
- 7건 **전부 `total_click_25 == 0.0`**이다. 즉 결측 학생은 예외 없이 25일까지 VLE 클릭 기록이 전혀 없다.
- `id_student 2710343`은 서로 다른 두 수강(`DDD/2013B`, `DDD/2014B`)에서 모두 `date_registration`이 결측이다. 특정 학생에게 반복되는 패턴이 존재한다.

이는 완전 무작위 결측(MCAR)이라기보다, "등록 후 VLE 활동 기록이 사실상 없는 학생"에 공통되는 원본 데이터 누락(`studentRegistration`)일 가능성을 시사한다. 다만 7건(0.03%)으로 건수가 극히 적어 원인 규명을 더 파고들 실익이 낮고, 처리 방침(행 제외)에도 영향을 주지 않는다.

## 4. 처리 방침 (제안)

| 컬럼 | 결측 성격 | 제안 |
|---|---|---|
| `submission_rate_25` | 완전한 구조적 결측 (기회 없음과 100% 일치) | NaN 유지 + `no_assessment_opportunity_25` 플래그로 모델에 전달 (0으로 채우면 "기회는 있었으나 0% 제출"로 오독될 수 있음) |
| `avg_score_25`, `avg_submit_delay_25` | 구조적 결측 (기회 없음 + 미제출로 전부 설명, 예외 6건 존재) | NaN 유지, `n_submitted_25`(이미 피처)가 원인을 대신 설명하므로 별도 플래그 불필요. 예외 6건은 다른 결측과 동일하게 처리 |
| `imd_band` | 특정 지역(North Region, Ireland)에 집중된 수집 누락, 원인 불명 | `'Unknown'` 범주 추가 (수치형 대치 대신 범주형 결측 그대로 인코딩) |
| `date_registration` | 소수 원본 결측 (7건, 0.03%), `total_click_25 == 0` 공통 패턴 확인 | 건수가 미미하므로 해당 7행 제외 권장 (모델 성능에 영향 없을 것으로 예상) |

위 표는 **데이터셋 단계**(이 노트북 6절)에서 적용하는 처리다. `imd_band`의 `'Unknown'` 범주화와
`date_registration` 7행 제외는 모델 종류와 무관하게 한 번만 적용하면 되는 처리라 여기서 확정
반영한다. 반면 `submission_rate_25`/`avg_score_25`/`avg_submit_delay_25`는 "NaN 유지"까지만
데이터셋 단계에서 하고, 실제 대치 여부와 방식은 5절처럼 **모델별로 다르게** 모델링 파이프라인
안에서 처리한다.

## 5. 모델별 결측 처리 전략 (모델링 단계)

같은 `model_df`를 Logistic Regression → Random Forest → XGBoost 순으로 비교할 예정이다
(`work_process/reports/04_next_steps.md` P4). 세 모델군은 NaN을 다루는 방식이 근본적으로
달라서, 결측 처리를 데이터셋 단계에서 한 번에 끝내지 않고 **모델별 `Pipeline` 안에서 분기**한다.

### 5.1 모델별 NaN 수용 여부

| 모델 | NaN 직접 처리 | 비고 |
|---|---|---|
| Logistic Regression (sklearn) | 불가 | 사전 대치 필수, 안 하면 `fit()` 에러 |
| Random Forest (sklearn) | 불가 | 마찬가지로 사전 대치 필수 |
| XGBoost / LightGBM | 가능 | 학습 중 결측 방향(분기)을 자동 학습 — 결측 자체가 신호로 활용됨 |

### 5.2 왜 단순 평균/중앙값 대치를 쓰지 않는가

`submission_rate_25`/`avg_score_25`/`avg_submit_delay_25` 결측은 3.1절에서 확인했듯 "평가
기회가 없었거나 제출을 안 했다"는 구조적 결측이다. 이를 전체 평균으로 채우면 위험군(제출 안
한 학생)이 "평균만큼 잘 낸 것"처럼 보여 신호가 왜곡된다. 이미 `n_submitted_25`,
`no_assessment_opportunity_25` 플래그가 결측 원인을 설명하고 있으므로, 이 플래그를 유지한
채로 모델별 전략을 아래처럼 분기한다.

### 5.3 모델별 전략

- **XGBoost/LightGBM**: NaN을 그대로 입력. 대치하지 않는다. 결측 패턴 자체를 트리 분기로
  학습하게 둔다.
- **Logistic Regression**: 결측을 상수(0 또는 대표값)로 채우되, 기존 플래그
  (`no_assessment_opportunity_25`, `n_submitted_25`)를 피처에 함께 포함해 "이 값이 원래
  결측이었다"는 정보를 모델이 참고할 수 있게 한다. 필요하면 `avg_score_25 × no_assessment_opportunity_25`
  같은 교차항을 추가로 검토한다.
- **Random Forest (sklearn)**: Logistic과 동일하게 사전 대치(중앙값 또는 상수) 필요. sklearn
  구현은 XGBoost처럼 NaN 인식 분기를 지원하지 않는다.
- **`imd_band`**: `'Unknown'` 범주로 이미 데이터셋 단계에서 처리되므로, 세 모델 모두 원-핫/
  범주형 인코딩만 하면 추가 조치가 필요 없다.

### 5.4 파이프라인 구성 원칙

1. 대치·인코딩은 반드시 `sklearn.pipeline.Pipeline`/`ColumnTransformer` 안에서 수행해
   `GridSearchCV`가 매 fold의 train 쪽에서만 `fit`하게 한다(검증 데이터로 대치값을 계산하는
   누수 방지, `04_next_steps.md`의 "전처리를 학습 fold 안에서만 수행" 원칙과 동일).
2. 세 모델은 서로 다른 `Pipeline`(전처리 스켈레톤)을 쓰되, **비교 조건은 반드시 통일**한다.
   - 같은 `model_df`, 같은 행
   - 같은 `StratifiedGroupKFold` 객체(같은 `random_state`, `groups=id_student`)를 한 번만
     만들어 세 모델에 재사용
   - 같은 주 평가지표(PR-AUC, `0902_01_landmark_n25_final.md`와 동일 기준)
3. 모델별 `(name, pipeline, param_grid)` 구성을 리스트로 관리하고 동일 루프에서
   `GridSearchCV`를 순회 실행해 결과를 한 표로 비교한다. 코드 중복 없이 관리하기 위함이며,
   최종 챔피언 모델만 선정 후 재학습해 holdout 평가로 넘어간다.

## 6. 검증

- 노트북 실행 결과: 전체 32,593행, 모델 대상 27,661행, 복합 키 중복 0건, 타깃 결측 0건, 양성 5,247건, 음성 22,414건 (기존 데이터 계약과 일치)
- 결측 원인 분해에 사용한 크로스탭(`submission_rate_25`↔`no_assessment_opportunity_25`, `avg_score_25`/`avg_submit_delay_25`↔`n_submitted_25`)이 각각 100% 대응됨을 확인
- `imd_band` 결측-지역 크로스탭에서 결측이 2개 지역에 집중됨을 확인
- `date_registration` 결측 7건 전수 조회로 `total_click_25 == 0` 공통 패턴과 학생 중복(2710343) 확인

## 7. 다음 작업

1. 4절 방침을 `03_Missing_Outlier.ipynb`(현 `04_Missing_Outlier`) 6절에 반영해 `imd_band` `'Unknown'` 처리와
   `date_registration` 7행 제외를 실제로 적용한다.
2. 이상치 점검(`total_click_25`, `avg_submit_delay_25` 등)을 같은 노트북에서 이어서 진행한다.
3. 5절의 모델별 전략에 따라 모델링 단계에서 `Pipeline` 기반 대치·인코딩을 구현한다.
