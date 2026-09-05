# Current Status

## 현재 단계

**단계 4: 결측·이상치 처리 및 검증 설계 단계**

예측 시간 구조는 “N일 재학생의 N일 이후 이탈 예측”으로 확정했고 랜드마크는 N=25일로 결정했다.
25일 전체 코호트 단일 통합 테이블 구축과 데이터 계약 검증까지 완료했다.

여기까지가 스터디 공동 진행 범위이며, 통합 테이블 확정부터는 개인 작업으로 진행한다. `reference_materials/personal_prework`의 자료는 공동 작업 중 후속 단계를 미리 확인하기 위한 개인 참고자료다.

## 상태표

| 영역 | 상태 | 근거/산출물 |
|---|---|---|
| 프로젝트 기획 | 완료 | `docs/OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx`, `README.md` |
| 데이터 사전 | 완료 | `docs/데이터_사전.md` |
| 단일 테이블 EDA | 완료 | 공동 작업: `Notebooks/01_EDA_Basic/01~03`; 개인 선행 참고: `reference_materials/personal_prework/01~05` |
| 선택적 조인·가설 검증 | 완료 | `01_EDA_Basic/04~06`, 가설 Q1~Q10 |
| 관측창 후보 분석 | 완료 | `02_Window_Integration/01_Window_Definition.ipynb` |
| 예측 시간 구조 | 완료 | N일 재학생의 N일 이후 이탈 예측 |
| 랜드마크 N 결정 | 완료 | 2026-09-02 N=25일 최종 확정 |
| 과거 통합 SQL/CSV | 폐기 완료 | `label_churn_28d`가 새 타깃과 불일치하여 정본에서 제거 |
| 최종 통합 노트북 | 완료 | `02_Integrated_Table.ipynb`, pandas 통합 및 검증 구현 |
| 전체 코호트 정본 | 완료 | `CSV_files/통합 버전/landmark25_all_cohorts.csv` |
| 결측·이상치 처리 | 미착수 | `03_Missing_Outlier.ipynb`가 비어 있음 |
| 통합 후 공선성 재검증 | 미착수 | `04_Collinearity_Recheck.ipynb`가 비어 있음 |
| 정식 모델 비교 | 미완료 | 초기 RF 실험만 존재 |
| 모델 해석·검증 | 미착수 | SHAP, 임계값, 오류 분석 필요 |
| 발표/대시보드/보고서 | 미착수 | 중간 PPT 외 최종 산출물 없음 |

## 현재 자산

- 원본 CSV 7종: `CSV_files/`
- 25일 전체 코호트 정본: `CSV_files/통합 버전/landmark25_all_cohorts.csv`
- 데이터 사전: `docs/데이터_사전.md`
- 공동 분석 노트북: `Notebooks/01_EDA_Basic`
- 개인 선행 참고자료: `reference_materials/personal_prework`
- 관측창/통합 작업 공간: `Notebooks/02_Window_Integration`

## 현재 데이터 경계

1. 전체 32,593행 중 `eligible_at_25 == 1`인 모델 대상은 27,661행이다.
2. 모델 대상의 양성(`target_churn_after_25 == 1`)은 5,247건이다.
3. 초기 이탈 4,819건, 취소일 없는 Withdrawn 93건, 25일 이후 등록 20건은 `cohort_status_25`로 구분한다.
4. 복합 키 `(code_module, code_presentation, id_student)` 중복은 0건이다.
5. `final_result`, `date_unregistration`, 코호트·타깃 파생값과 25일 이후 행동은 모델 피처에서 제외한다.

## 지금 해결해야 할 핵심 질문

- 취소일이 없는 Withdrawn 93건의 민감도 분석 방식을 정할 것
- `imd_band`, `date_registration`과 평가 관련 구조적 결측의 처리 방식을 정할 것
- 클릭 수와 제출 지연의 극단값이 오류인지 정상 롱테일인지 판단할 것
- 동일 학생 Group split과 학기 기반 holdout을 비교해 최종 검증 방식을 정할 것
