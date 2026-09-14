# 통합 후 공선성 재검증 및 최종 피처 목록 확정

> **2026-09-13 갱신 안내 — 본문 수치 일부가 대체됨**
> - 노트북 번호 변경: `04_Collinearity_Recheck` → **`05_Collinearity_Recheck`**, `03_Missing_Outlier` → `04_Missing_Outlier`.
> - 평가 기회·이월 정의 변경([[0913_01_assessment_opportunity_banked]]) 후 재실행 결과
>
> | 항목 | 결정 당시 | 갱신 |
> |---|---|---|
> | 최종 피처 | 19개 (수치형 11) | **20개 (수치형 12, `n_banked_25` 추가)** |
> | 축소 피처셋 최대 VIF | 3.11 | **2.95** (`n_banked_25` 1.19) |
> | `no_assessment_opportunity_25` VIF | 6.39 | 5.71 |
> | `submission_rate_25` 구조적 결측 | 6,765행 | 5,452행 |
> | NaN 유지 피처 결측 (`avg_score_25` / `avg_submit_delay_25`) | 10,016 / 10,010 | 8,355 / 8,348 |
> | 대안 A/B/C PR-AUC (4개 학기 CV) | 0.3903 / 0.3902 / 0.3902 | 0.3858 / 0.3850 / 0.3858 |
> | 12.1 PCA 고유값 PC1 / PC2 / PC3 (누적) | 3.4100 / 1.4457 / 0.1340 (97.11%) | 3.4032 / 1.4352 / 0.1509 (96.76%) |
> | 12.2 Logistic 채택안 / PCA 95% / PCA 11 / PCA 8 / PCA 2 | 0.3903 / 0.3906 / 0.3904 / 0.3763 / 0.3427 (채택안 수치형 11) | 0.3857 / 0.3860 / 0.3863 / 0.3752 / 0.3510 (수치형 12) |
> | 12.3 RandomForest 채택안 / PCA 8 | 0.3798 / 0.3728 | 0.3796 / 0.3717 |
>
> - 대안 A 채택, VLE 3종 유지, `presentation_period`, `gender`·`code_module` 유지, PCA 미채택 결론은 모두 그대로다(갱신 후에도 PCA는 성분을 거의 다 살려야 채택안과 동점이고, 줄이면 성능이 떨어진다).
> - 아래 본문 수치는 결정 당시 실행 값이다. 현재 노트북 출력은 위 표의 갱신 값과 같다.
> - 4개 학기 CV 수치가 낮아진 원인(BBB 2014J 가중치 0 평가 점수의 혼입)과 개발 세트 CV에서는 개선됨(0.3962 → 0.3994)은 0913_01 5절 참고.
> - `gender` × `code_module`은 `03_Landmark25_EDA` 10절에서 **심슨의 역설**(전체 M−F +2.2%p, 과목 내 가중 평균 −2.2%p)로 확인됐다.
> - 분야 구분 출처: Kuzilek, Hlosta & Zdrahal (2017), *Scientific Data* 4:170171, Table 1.

## 상태

- 결정일: 2026-09-12
- 상태: 최종 확정
- 적용 범위: `Notebooks/02_Window_Integration/04_Collinearity_Recheck.ipynb` 및 이후 모든 모델링
- 근거 노트북: `Notebooks/02_Window_Integration/04_Collinearity_Recheck.ipynb` (전체)
- 선행 문서: [[0912_01_missing_value_policy]], [[0912_02_outlier_policy]]
- 대응 계획: `work_process/reports/04_next_steps.md` P3

## 1. 배경

`model_df_clean`(27,654행, 양성 5,246건)을 대상으로 최종 모델 피처를 확정한다. Logistic
계수를 해석하기 전에 반드시 끝내야 하는 단계다.

기존 `04_Collinearity_Recheck.ipynb`는 2026-08-02 커밋(`c5f6793`) 이후 **0바이트 파일**로
남아 있었다(JSON 파싱 불가). 내용을 새로 작성했다.

## 2. 수학적 종속성 — 항등식 검증 결과 (위반 0건)

| 항등식 | 위반 건수 |
|---|---:|
| `n_submitted_25 + n_missing_25 = n_opportunity_25` | 0 |
| `submission_rate_25 = n_submitted_25 / n_opportunity_25` (`n_opportunity_25 > 0`) | 0 |
| `no_assessment_opportunity_25 = 1{n_opportunity_25 == 0}` | 0 |
| `submission_rate_25` 결측 == 기회 없음 | 0 |
| `no_vle_activity_25 = 1{total_click_25 == 0}` | 0 |

따라서 평가 행동 5개 컬럼의 **자유도는 2개**다. 5개를 모두 회귀에 넣으면
`n_opportunity_25`/`n_submitted_25`/`n_missing_25`의 **VIF가 `inf`로 발산**한다(선형 항등식
때문에 설계행렬이 특이해짐). `no_assessment_opportunity_25`의 VIF는 6.39다.

`n_opportunity_25`는 {0, 1, 2} 세 값만 갖는다. 25일까지 마감되는 `weight > 0` 비이월
TMA/CMA가 최대 2개라는 관측창 정의의 결과다.

## 3. 남길 2개 선택 — 세 대안 비교

`n_opportunity_25`는 "평가 기회 횟수"라는 분모이자 모듈·학기 일정에서 오는 외생 변수라 어떤
대안에서도 유지한다. 두 번째 자리만 선택지다.

| 대안 | 두 번째 피처 | PR-AUC (5-fold `StratifiedGroupKFold`) | 대치 필요 컬럼 | 해석 |
|---|---|---:|---:|---|
| **A (채택)** | `n_submitted_25` | 0.3903 ± 0.0128 | 0 | 낸 개수 |
| B | `submission_rate_25` | 0.3902 ± 0.0103 | 1 (6,765행) | 기회 대비 제출률 |
| C | `n_missing_25` | 0.3902 ± 0.0127 | 0 | 놓친 개수 |

### 3.1 성능으로는 구분되지 않는다 (의도된 결과)

세 대안의 PR-AUC가 소수 네 자리에서 동일하다. **세 대안이 같은 선형 부분공간을 span하므로
정보량이 수학적으로 동일**하기 때문이며, 이는 2절의 항등식이 실제로 성립한다는 실증적
재확인이기도 하다. 따라서 선택 기준은 성능이 될 수 없다.

### 3.2 A를 채택한 근거

1. **결측 처리 부담이 없다.** B는 `submission_rate_25`가 6,765행(24.5%) 구조적 결측이라
   Logistic/RandomForest에서 대치가 필요하다. 그런데 이 결측은 [[0912_01_missing_value_policy]]
   3.1절에서 확인한 "평가 기회 자체가 없었음"이고, 중앙값으로 채우면 *기회가 없던 학생이
   평균만큼 제출한 것처럼* 보여 신호가 왜곡된다. 같은 문서 5.2절이 경고한 위험을 A·C는
   애초에 발생시키지 않는다.
2. **개입 설계와 방향이 맞는다.** A는 "많이 낼수록 잔류", C는 "많이 놓칠수록 이탈"로 부호만
   반대이고 정보는 같다. P5 개입 전략의 행동안이 "평가 전 알림으로 제출을 유도한다"이므로
   제출 쪽을 주 피처로 두는 A가 서술과 자연스럽게 이어진다.

### 3.3 B·C를 택했을 경우 달라지는 점 (기록용)

- **B**: 성능은 동일하지만 `submission_rate_25` 대치 방식을 별도로 정해야 하고, 대치값 선택이
  모델 간 비교 조건을 흐린다. XGBoost는 NaN을 그대로 쓰고 Logistic은 대치하므로 "같은 정보를
  본다"는 전제가 약해진다. 해석 문장은 "제출률 10%p 상승 시 이탈 확률 X% 감소"로 가장
  직관적이지만, 분모가 1 또는 2뿐이라 실제로는 {0, 0.5, 1} 세 값밖에 나오지 않아
  "비율"이라는 표현의 이점이 크지 않다.
- **C**: A와 완전히 대등하다. 결측도 없고 VIF도 같다. "놓친 개수"를 위험 신호로 직접
  제시하고 싶다면 C가 더 낫다. 다만 `n_opportunity_25`와 함께 보면 A로부터 `n_missing_25`를
  즉시 계산할 수 있어(`n_opportunity - n_submitted`) 해석 단계에서 필요하면 파생해 보고하면
  된다. 즉 C의 이점은 A를 유지한 채로도 확보 가능하다.

### 3.4 파생 플래그 2종을 다르게 처리하는 이유

두 컬럼 모두 다른 컬럼에서 완전히 복원되는 0/1 플래그지만 판단이 갈린다.

- **`no_assessment_opportunity_25` 제외**: `1{n_opportunity_25 == 0}`이고 `n_opportunity_25`는
  값이 {0, 1, 2} 세 개뿐이다. 원-핫이든 트리 분기든 "기회 0" 상태가 이미 완전히 표현되므로
  플래그는 순수 중복이며 VIF만 6.39로 올린다.
- **`no_vle_activity_25` 유지**: `1{total_click_25 == 0}`인데 `total_click_25`는 0~5,818의
  연속형이다. 선형 모델은 계수 하나로 "0 → 1"과 "3,000 → 3,001"을 같게 취급하므로
  **"활동이 아예 없음"이라는 불연속 상태를 표현할 수 없다.** 이 플래그는 중복이 아니라
  선형 모델이 놓치는 꺾임을 보완한다. VIF도 1.21로 낮다. 실증적으로도 무활동 1,302명의
  이탈률이 26.1%로 활동 있는 집단 18.6%보다 뚜렷하게 높다.

## 4. VLE 활동 3종 — 모두 유지

| 피처 | 상관(최대) | VIF |
|---|---:|---:|
| `total_click_25` | 0.74 (vs `active_days_25`) | 2.52 |
| `active_days_25` | 0.74 | 2.92 |
| `distinct_resources_25` | 0.70 (vs `active_days_25`) | 2.42 |

상관이 0.66~0.74지만 **셋이 서로를 결정하지는 않는다.** 각각 다른 행동을 측정한다(총량 /
꾸준함 / 학습자료 범위). VIF가 전부 3 미만이라 Logistic 계수 해석을 방해할 수준이 아니므로
세 개 모두 유지한다.

축소 피처셋(종속 파생 3개 제거 후)의 **최대 VIF는 `n_submitted_25`의 3.11**로, 엄격 기준인
5도 넘지 않는다.

## 5. 범주형 연관성 — `gender` × `code_module`

Cramér's V 행렬에서 `gender` × `code_module`이 **0.601**로 유일하게 두드러진다. 모듈별 성비가
극단적으로 갈리는 실제 구조(OULAD 모듈이 STEM/사회과학 등 서로 다른 분야)다.
나머지 조합은 전부 0.25 미만이다(`code_module` × `code_presentation` 0.253이 두 번째).

완전 공선성이 아니므로 **두 피처 모두 유지한다.** 다만 해석 단계(P5)에서 다음을 반드시
명시한다.

> Logistic의 `gender` 계수는 "성별 자체의 효과"가 아니라 "모듈 구성으로 설명되지 않는 잔여
> 성별 효과"이며, `code_module` 계수와 서로 흡수 관계다. 성별 효과를 단독으로 주장하려면
> 모듈별 층화 분석이나 permutation importance로 교차 확인해야 한다.

`work_process/reports/04_next_steps.md` P3의 "재수강과 `is_banked`의 구조적 관계" 항목은
해당 없음으로 처리한다. `is_banked`는 통합 테이블 생성 단계에서 이월 평가를 제외하는 필터로만
쓰였고(`02_Integrated_Table.ipynb`) `landmark25_all_cohorts.csv`에 컬럼으로 남아 있지 않다.

## 6. `code_presentation` → `presentation_period` 파생

최종 평가를 **마지막 학기(`2014J`) holdout**으로 하기로 확정했으므로, `code_presentation`을
원본 그대로 원-핫 인코딩하면 holdout 학기 더미를 학습에서 한 번도 본 적이 없게 되어 평가가
왜곡되고 실제 배포 상황(새 학기 예측)도 재현하지 못한다.

대신 `presentation_period = code_presentation.str[-1]`(B = 2월 개강, J = 10월 개강)만 파생해서
쓴다.

| 구분 | 행 수 | 이탈률 |
|---|---:|---:|
| 2013B | 4,274 | 22.1% |
| 2013J | 7,692 | 16.0% |
| 2014B | 6,538 | 20.7% |
| 2014J | 9,150 | 18.8% |
| **B (2월 개강)** | 10,812 | **21.3%** |
| **J (10월 개강)** | 16,842 | **17.5%** |

연도가 아니라 **개강 시기가 일관된 방향**을 만든다(2013·2014 두 해 모두 B > J, 약 3.8%p 차).
따라서 `presentation_period`만 남겨도 학기 효과의 재현 가능한 부분은 보존된다. 반대로 연도
차이는 다음 학기 예측에 적용할 근거가 없어 학습해선 안 되는 정보에 가깝다.

`code_presentation` 원본은 **입력 피처에서 제외하되 학기 holdout 분할 키로는 사용**한다.
분할 키와 입력 피처는 다른 역할이다.

## 7. 최종 피처 목록 (수치형 11 + 범주형 8 = 19개)

정본은 `CSV_files/통합 버전/feature_spec_n25.json`이며 04 노트북이 생성한다.

### 수치형 11개

| 피처 | 구분 | 비고 |
|---|---|---|
| `num_of_prev_attempts` | 학생 배경 | |
| `studied_credits` | 학생 배경 | |
| `date_registration` | 학생 배경 | 결측 7행은 03에서 제외 완료 |
| `total_click_25` | VLE | |
| `active_days_25` | VLE | |
| `distinct_resources_25` | VLE | |
| `no_vle_activity_25` | VLE | 3.4절 근거로 유지 |
| `n_opportunity_25` | 평가 | |
| `n_submitted_25` | 평가 | 대안 A |
| `avg_score_25` | 평가 | **NaN 유지** (10,016행) |
| `avg_submit_delay_25` | 평가 | **NaN 유지** (10,010행) |

### 범주형 8개

`gender`, `region`, `highest_education`, `imd_band`(`Unknown` 포함), `age_band`,
`disability`, `code_module`, `presentation_period`

### 보조 컬럼 (피처 아님)

- `id_student`: `StratifiedGroupKFold`의 `groups`
- `code_presentation`: 학기 holdout 분할 키

## 8. 제외 피처와 사유

| 제외 컬럼 | 사유 |
|---|---|
| `id_student` | 그레인 식별자 (단 `groups`로 사용) |
| `landmark_day` | 상수(25) |
| `eligible_at_25` | 상수(1) — 모델 대상 필터링 결과 |
| `cohort_status_25` | 상수(`model_eligible`) |
| `final_result` | **누수** — 타깃이 여기서 직접 파생 |
| `date_unregistration` | **누수** — 25일 이후 시점 정보 |
| `target_churn_after_25` | 타깃 |
| `n_missing_25` | 항등식 1로 완전 복원. VIF `inf` |
| `submission_rate_25` | 항등식 2로 완전 복원. VIF `inf` + 6,765행 대치 부담 |
| `no_assessment_opportunity_25` | 항등식 3으로 완전 복원. VIF 6.39 |
| `code_presentation` | 학기 holdout과 충돌 — 파생으로 대체, 분할 키로만 사용 |

## 9. 모델별 인코딩·스케일링 방침 (확정)

[[0912_01_missing_value_policy]] 5절과 [[0912_02_outlier_policy]] 4절을 최종 피처 목록에
적용한 결과다.

| 처리 | Logistic Regression | Random Forest | XGBoost |
|---|---|---|---|
| 수치형 결측(`avg_score_25`, `avg_submit_delay_25`) | `SimpleImputer` + `add_indicator=True` | 동일 | **대치 안 함**(NaN 그대로) |
| 수치형 스케일링 | `RobustScaler` | 불필요 | 불필요 |
| 범주형 인코딩 | `OneHotEncoder(drop='first', handle_unknown='ignore')` | `OneHotEncoder(handle_unknown='ignore')` | `OneHotEncoder(handle_unknown='ignore')` |
| 불균형 대응 | `class_weight='balanced'` | `class_weight='balanced'` | `scale_pos_weight` |

- Logistic만 `drop='first'`를 쓰는 이유는 원-핫 더미 합이 1이 되어 상수항과 완전 공선이 되는
  것(dummy variable trap)을 막기 위함이다. 트리 모델은 상수항이 없어 불필요하다.
- 대치는 반드시 `Pipeline`/`ColumnTransformer` 안에서 수행해 **각 fold의 학습 부분에서만
  `fit`**되게 한다.
- 대안 A 채택의 부수 효과로, 모델별 분기가 필요한 구조적 결측 피처는 원래 3개에서
  **`avg_score_25`·`avg_submit_delay_25` 2개로 줄었다.**

## 10. 검증 분할 방식 확정 (열린 이슈 해소)

기존 열린 이슈("Group split과 학기 기반 holdout 중 최종 검증 방식")를 **둘 다 사용**으로
확정한다.

- **모델 비교·튜닝**: `StratifiedGroupKFold(n_splits=5, shuffle=True, random_state=42)`,
  `groups=id_student`. 24,947명이 27,654행을 만들고 그중 2,588명이 두 과목·학기 이상 수강(추가 행 2,707)하므로, 같은 학생이
  학습·검증에 동시에 들어가는 낙관 편향을 막아야 한다.
- **최종 평가**: `code_presentation == '2014J'`(9,150행)를 holdout으로 분리해 챔피언 모델만
  평가한다. "과거 학기로 학습해 다음 학기를 예측한다"는 실제 배포 시나리오를 재현한다.
- 학기가 4개뿐이라 학기 단위 CV는 fold가 부족하므로, 학기는 CV가 아니라 최종 holdout으로만
  쓴다.
- `StratifiedGroupKFold` 객체는 **한 번만 만들어 모든 모델에 재사용**한다
  ([[0912_01_missing_value_policy]] 5.4절 원칙).

## 11. 검증

- 04 노트북 전체 재실행, 에러 0건 (`uv run --with nbclient --with nbformat --with ipykernel`)
- 항등식 5종 위반 0건 (assert)
- 상수 주장 컬럼 3개의 유일값이 실제로 1개임을 assert로 확인
- `final_result` × 타깃 교차표에서 `Withdrawn` 5,246건 ↔ 타깃 1이 완전 대응(누수 근거)
- 축소 피처셋 최대 VIF 3.11 < 5 (assert)
- 최종 피처 목록에 누수·상수·식별자·종속 파생이 없음을 assert로 확인
- NaN 보유 피처가 정확히 `avg_score_25`·`avg_submit_delay_25` 2개임을 assert로 확인
- `feature_spec_n25.json` 라운드트립 검증 통과 (피처 19개)
- `model_df_clean_n25.csv` 라운드트립 검증 통과 (03 노트북 6.1절, 27,654행/양성 5,246건,
  결측 패턴 동일)
- 부록 A(PCA 대안 검토) 셀도 동일 실행에 포함, 12절의 고유값·PR-AUC 수치는 결정 당시(2026-09-12) 노트북
  출력에서 그대로 가져온 값이다(재실행 후 값은 상단 갱신 안내 표)

## 12. 검토했으나 채택하지 않은 대안 — PCA

다중공선성의 교과서적 해법 중 하나가 PCA다. 4.3절에서 VIF가 `inf`까지 발산했으므로 당연히
후보였다. 근거 노트북 **부록 A**에 실행 가능한 형태로 남겼고, 결론은 **채택하지 않음**이다.

### 12.1 PCA는 비선형 종속을 찾지 못한다

평가 행동 5개 컬럼(`submission_rate_25` 결측은 PCA가 요구하는 완전데이터를 위해 0 대치)에
PCA를 적용한 고유값이다.

| 성분 | 고유값 | 설명비율 | 누적 |
|---|---:|---:|---:|
| PC1 | 3.4100 | 68.20% | 68.20% |
| PC2 | 1.4457 | 28.91% | 97.11% |
| PC3 | 0.1340 | 2.68% | 99.79% |
| PC4 | 0.0104 | 0.21% | 100.00% |
| PC5 | **0.0000** | 0.00% | 100.00% |

**고유값이 정확히 0인 성분은 1개뿐**이다. 2절의 항등식 3개 중
`n_submitted + n_missing = n_opportunity` 하나만 *선형*이기 때문이다. 나머지 둘은
나눗셈(`submission_rate`)과 지시함수(`no_assessment_opportunity`)라 PCA가 완전 종속으로
인식하지 못하고, PC3(2.7%)·PC4(0.2%)에 작은 분산으로 흩어진다.

즉 **PCA만으로는 "자유도가 2개"라는 결론에 도달할 수 없다.** "누적 95% 유지" 규칙을 쓰면
PC1+PC2(97.11%)로 우연히 2차원이 되지만, 그건 임계값을 그렇게 잡은 결과이지 종속 구조를
이해한 결과가 아니다. 반면 항등식을 직접 검증하면 위반 0건을 `assert`로 고정할 수 있고
제외 근거를 문서로 설명할 수 있다.

### 12.2 성능 이득이 없다

3절과 동일한 조건(같은 `StratifiedGroupKFold(5, random_state=42)`, `groups=id_student`,
PR-AUC, 범주형 8개는 양쪽 모두 원-핫)에서 Logistic Regression으로 비교했다. PCA안은 종속
파생을 제거하지 않고 수치형 14개를 전부 넣은 뒤 `StandardScaler` → `PCA`를 적용한다.

| 방식 | 수치형 차원 | PR-AUC |
|---|---:|---:|
| **채택안** (종속 3개 제거 + `RobustScaler`) | 11 | **0.3903 ± 0.0129** |
| PCA 누적 분산 95% 유지 | — | 0.3906 ± 0.0118 |
| PCA `n_components=11` | 11 | 0.3904 ± 0.0120 |
| PCA `n_components=8` | 8 | 0.3763 ± 0.0151 |
| PCA `n_components=6` | 6 | 0.3659 ± 0.0139 |
| PCA `n_components=4` | 4 | 0.3513 ± 0.0127 |
| PCA `n_components=2` | 2 | 0.3427 ± 0.0136 |

두 가지가 동시에 확인된다.

1. **성분을 거의 다 살려야 동점이다.** 11성분이나 95% 유지는 채택안과 PR-AUC가 소수 세 자리까지
   같다. PCA가 성능을 올려주지 않는다.
2. **차원을 줄이면 단조롭게 나빠진다.** 11 → 2로 갈수록 PR-AUC가 계속 떨어진다.

2번이 핵심이다. PCA는 **비지도** 방법이라 분산이 큰 방향을 남기는데, 그게 타깃과 관련된
방향이라는 보장이 없다. 버려진 저분산 성분에 이탈 신호가 있었다는 뜻이다. 애초에
27,654행 × 19피처는 n ≫ p라서 차원을 줄여 분산을 낮출 필요가 없고, 줄이면 신호만 잃는다.

### 12.3 트리 모델에는 해롭다

RandomForest(`n_estimators=200`, `class_weight='balanced'`)로 같은 조건에서 비교했다.

| 방식 | PR-AUC |
|---|---:|
| 채택안 (원본 피처, 스케일링 없음) | **0.3798 ± 0.0174** |
| PCA `n_components=8` | 0.3728 ± 0.0156 |

트리는 `total_click_25 == 0`, `n_submitted_25 <= 0` 같은 의미 있는 임계값에서 분기한다.
PCA로 축을 회전시키면 그 경계가 여러 성분에 흩어지고, 축에 평행한 분할만 하는 트리는 같은
경계를 재현하려 훨씬 많은 분기를 써야 한다. 더 나아가 PCA는 완전데이터를 요구하므로
`avg_score_25`·`avg_submit_delay_25`를 강제 대치해야 하고, **XGBoost가 결측 방향을 스스로
학습하게 두는 전략([[0912_01_missing_value_policy]] 5.3절)이 무력화된다.**

Logistic에만 PCA를 적용하면 9절의 "세 모델이 같은 정보를 본다"는 비교 조건도 깨진다.

### 12.4 결론

| 판단 기준 | 채택안 (컬럼 제거) | PCA |
|---|---|---|
| 성능(PR-AUC) | 0.390 | 동점(11성분) 또는 하락(축소 시) |
| 종속 구조 규명 | 항등식 3개 전부, `assert` 고정 | 선형 1개만 탐지 |
| 계수 해석 | "제출 1건 ↑ → 이탈 오즈 X배" | "PC3 1 ↑ → …" — 개입 불가 |
| 구조적 결측 | NaN 유지 가능 | 대치 강제 |
| 트리 모델 | 그대로 사용 | 성능 하락 |
| 잔여 VIF | 최대 3.11 | (문제 없음) |

성능 이득이 없고, 해석을 잃고, 결측 전략과 트리 모델을 동시에 망친다. 결정적으로 이
프로젝트의 목표는 P5 개입 전략이라 **계수를 행동으로 번역할 수 있어야 한다.** "PC3이 1
증가하면 이탈 오즈가 X배"는 개입안이 될 수 없다.

게다가 종속 파생 3개를 제거한 뒤 최대 VIF가 3.11로 이미 기준(5) 안에 들어왔으므로
**해결할 문제가 남아 있지 않다.**

### 12.5 PCA가 답이었을 조건 (기록용)

- **상관된 피처가 수십 개인 경우.** VLE 로그를 활동유형별로 쪼개 클릭수 피처를 20~30개
  만들었다면 압축할 실익이 생긴다. 이 프로젝트는 총량·활동일수·자원 수 3개로 집약했고
  VIF도 3 미만이라 해당하지 않는다.
- **해석을 포기하고 성능만 보는 경우.** P5가 목표인 이상 해당하지 않는다.
- **종속 파생 제거 후에도 VIF가 10~15 이상 남는 경우.**

단 그런 상황에서도 **PCA보다 ridge/elastic-net 정규화가 보통 먼저다.** 원본 피처 이름을
유지한 채 계수 크기만 줄이므로 해석을 잃지 않는다. PCA는 "해석을 포기한다"는 결정을 먼저
내린 뒤에 쓰는 도구다.

## 13. 다음 작업

`work_process/reports/04_next_steps.md` P4 재현 가능한 모델링(`Notebooks/03_Modeling/`).

1. `2014J` holdout 분리 → 나머지 3개 학기로 `StratifiedGroupKFold` 5-fold 교차검증
2. 더미(`DummyClassifier`) → Logistic → RandomForest → XGBoost 순 비교, 주 지표 PR-AUC
3. Recall·Precision·F1·ROC-AUC·confusion matrix를 함께 보고 개입 비용에 맞는 임계값 선택
4. 챔피언 모델만 재학습해 `2014J` holdout 평가, 마일스톤 스냅샷 보존
