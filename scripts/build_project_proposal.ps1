param(
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'docs\OULAD_학습자_중도이탈_예측_프로젝트_기획서.docx')
)

$ErrorActionPreference = 'Stop'
$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
$projectRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $PSScriptRoot))
if (-not $outputFullPath.StartsWith($projectRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Output path must stay inside the project workspace.'
}

$word = $null
$doc = $null

function Add-Paragraph {
    param(
        [Parameter(Mandatory)][string]$Text,
        [object]$Style = -1,
        [int]$SpaceAfter = 6,
        [int]$Alignment = 0
    )
    $p = $doc.Paragraphs.Add()
    $p.Range.Text = $Text
    try { $p.Range.Style = $Style } catch { }
    $p.Format.SpaceAfter = $SpaceAfter
    $p.Alignment = $Alignment
    $p.Range.InsertParagraphAfter()
}

function Add-Bullets {
    param([string[]]$Items)
    foreach ($item in $Items) {
        $p = $doc.Paragraphs.Add()
        $p.Range.Text = $item
        $p.Range.ListFormat.ApplyBulletDefault()
        $p.Format.SpaceAfter = 3
        $p.Range.InsertParagraphAfter()
    }
}

function Add-Numbered {
    param([string[]]$Items)
    foreach ($item in $Items) {
        $p = $doc.Paragraphs.Add()
        $p.Range.Text = $item
        $p.Range.ListFormat.ApplyNumberDefault()
        $p.Format.SpaceAfter = 3
        $p.Range.InsertParagraphAfter()
    }
}

function Add-Table {
    param(
        [string[]]$Headers,
        [object[]]$Rows,
        [double[]]$Widths = @()
    )
    $range = $doc.Content
    $range.Collapse(0)
    $table = $doc.Tables.Add($range, $Rows.Count + 1, $Headers.Count)
    $table.Style = -155
    $table.Rows.Item(1).Range.Bold = 1
    $table.Rows.Item(1).Shading.BackgroundPatternColor = 14277081
    for ($c = 1; $c -le $Headers.Count; $c++) {
        $table.Cell(1, $c).Range.Text = $Headers[$c - 1]
    }
    for ($r = 1; $r -le $Rows.Count; $r++) {
        for ($c = 1; $c -le $Headers.Count; $c++) {
            $table.Cell($r + 1, $c).Range.Text = [string]$Rows[$r - 1][$c - 1]
        }
    }
    if ($Widths.Count -eq $Headers.Count) {
        for ($c = 1; $c -le $Widths.Count; $c++) { $table.Columns.Item($c).PreferredWidth = $Widths[$c - 1] }
    }
    $table.Range.Font.Name = '맑은 고딕'
    $table.Range.Font.Size = 9
    $table.Range.ParagraphFormat.SpaceAfter = 2
    $after = $doc.Content
    $after.Collapse(0)
    $after.InsertParagraphAfter()
}

try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    $word.DisplayAlerts = 0
    $doc = $word.Documents.Add()

    $doc.PageSetup.TopMargin = $word.CentimetersToPoints(2.0)
    $doc.PageSetup.BottomMargin = $word.CentimetersToPoints(2.0)
    $doc.PageSetup.LeftMargin = $word.CentimetersToPoints(2.2)
    $doc.PageSetup.RightMargin = $word.CentimetersToPoints(2.2)

    $normal = $doc.Styles.Item(-1)
    $normal.Font.Name = '맑은 고딕'
    $normal.Font.Size = 10
    $normal.ParagraphFormat.LineSpacingRule = 1
    $normal.ParagraphFormat.SpaceAfter = 6

    foreach ($styleName in @(-63, -75, -2, -3, -4)) {
        try { $doc.Styles.Item($styleName).Font.Name = '맑은 고딕' } catch { }
    }

    Add-Paragraph -Text 'OULAD 학습자 중도이탈 예측 프로젝트 기획서' -Style -63 -SpaceAfter 12 -Alignment 1
    Add-Paragraph -Text '개강 후 25일 시점 재학생의 이후 이탈 예측과 데이터 기반 개입 전략' -Style -75 -SpaceAfter 18 -Alignment 1
    Add-Table -Headers @('항목', '내용') -Rows @(
        @('프로젝트 유형', '개인 데이터 분석·머신러닝 프로젝트'),
        @('현재 단계', 'EDA 및 관측시점 후보 분석 완료, 모델링 데이터 계약 확정 단계'),
        @('핵심 데이터', 'OULAD(Open University Learning Analytics Dataset)'),
        @('분석 단위', '학생-과목-학기(student-course-presentation)'),
        @('문서 기준일', '2026-08-29'),
        @('문서 상태', '통합 정본 v1.1 — 랜드마크 25일 확정')
    ) -Widths @(90, 340)

    Add-Paragraph -Text '문서 목적' -Style -2
    Add-Paragraph -Text '본 문서는 기존 1~3차 기획 자료, 스터디 공동 EDA 결과, 개인 선행 검토 및 최신 예측 목표 결정을 하나로 통합한 프로젝트 정본 기획서다. 프로젝트 범위·타깃·평가 기준·로드맵을 일관되게 관리하고, 이후 분석과 발표의 기준으로 사용한다.'

    Add-Paragraph -Text '1. Executive Summary' -Style -2
    Add-Paragraph -Text '온라인 학습에서는 중도이탈이 최종 결과에 기록된 뒤에야 확인되는 경우가 많아 실제 개입 시기를 놓치기 쉽다. 본 프로젝트는 OULAD의 인구통계, 등록, 평가 제출 및 VLE 클릭 로그를 활용해 특정 시점에 여전히 수강 중인 학생의 향후 이탈 위험을 예측한다.'
    Add-Paragraph -Text '핵심 예측 질문' -Style -3
    Add-Paragraph -Text '“개강 후 25일 시점에 아직 재학 중인 학생 가운데, 그 이후 최종적으로 중도이탈할 가능성이 높은 학생은 누구인가?”'
    Add-Paragraph -Text '예측 시점과 대상자를 일치시키기 위해 25일까지 이미 이탈한 학생은 주 모델에서 제외한다. 모델은 최초 25일까지 실제로 알 수 있는 정보만 사용하며, 예측 결과는 고위험군 선별과 상담·접속 유도·평가 알림 등 개입 전략 설계에 연결한다.'

    Add-Paragraph -Text '2. 프로젝트 배경과 문제 정의' -Style -2
    Add-Paragraph -Text '2.1 배경' -Style -3
    Add-Bullets -Items @(
        '온라인 학습자는 학습 활동 감소, 평가 미제출, 등록 패턴 등 다양한 신호를 남기지만 이 정보가 사전 개입에 체계적으로 활용되지 않을 수 있다.',
        '최종 이탈자 전체를 단순 분류하면 이미 떠난 학생이 예측 대상에 포함되어 실제 운영 시점과 모델의 대상이 불일치한다.',
        'OULAD는 학생 특성, 등록·취소, 평가 및 약 1,066만 건의 VLE 행동 로그를 제공해 시점 기반 이탈 예측을 검증하기에 적합하다.'
    )
    Add-Paragraph -Text '2.2 기존 접근의 문제' -Style -3
    Add-Table -Headers @('문제', '영향', '조정 방향') -Rows @(
        @('N일 행동으로 N일 이내 이탈 예측', '이미 발생한 사건을 같은 기간 정보로 맞혀 시간적 모순 발생', 'N일 재학생의 N일 이후 이탈로 타깃 변경'),
        @('초기 이탈자의 낮은 활동량 포함', '위험 신호와 짧은 관측기간 효과가 혼합', 'N일 이전 이탈자는 별도 EDA로 분리'),
        @('평가 기회 없음과 미제출 혼합', '과목별 커리큘럼 차이로 위험을 과대평가', 'N일까지 실제 마감된 유효 평가를 분모로 사용'),
        @('전체 기간 행동값 사용 가능성', '예측 시점 이후 정보로 인한 타깃 누수', 'N일까지 생성 가능한 피처만 허용')
    ) -Widths @(130, 160, 160)

    Add-Paragraph -Text '3. 프로젝트 목표와 범위' -Style -2
    Add-Paragraph -Text '3.1 핵심 목표' -Style -3
    Add-Numbered -Items @(
        '25일 시점 재학생의 이후 중도이탈 위험을 예측하는 이진 분류 모델을 구축한다.',
        '최초 25일까지 확보 가능한 행동·평가·학생 특성 중 유효한 조기 위험 신호를 규명한다.',
        '고위험 학생을 놓치지 않는 것을 우선해 운영 가능한 분류 임계값을 제안한다.',
        '모델 해석 결과를 교육 담당자가 실행할 수 있는 시점별 개입 전략으로 변환한다.'
    )
    Add-Paragraph -Text '3.2 현재 핵심 범위' -Style -3
    Add-Bullets -Items @(
        'OULAD 7개 테이블의 정합성 검증 및 랜드마크 통합 테이블 구축',
        '25일 랜드마크 코호트와 모델링 통합 테이블 구축',
        'Logistic Regression, Random Forest, XGBoost 계열 모델 비교',
        'Recall, Precision, F1, PR-AUC, ROC-AUC 및 임계값 분석',
        'SHAP 또는 동등한 해석 방법과 하위집단별 오류 분석',
        '4주 전후 개입을 가정한 위험군 관리 전략 제안'
    )
    Add-Paragraph -Text '3.3 후속 확장 범위' -Style -3
    Add-Paragraph -Text '국내 직업훈련 공공데이터 분석, 실시간 대시보드, 정책 효과 검증 및 실제 서비스 배포는 현재 데이터 확보와 개인 프로젝트 일정상 핵심 범위에서 제외한다. OULAD 모델과 분석 보고서를 완성한 뒤 별도 확장 과제로 검토한다.'

    Add-Paragraph -Text '4. 핵심 연구 질문' -Style -2
    Add-Table -Headers @('ID', '연구 질문', '검증 방향') -Rows @(
        @('RQ1', '최초 25일까지의 VLE 활동량과 활동 지속성이 이후 이탈을 구분하는가?', '클릭 합계·활동일·최근 활동·주차별 변화'),
        @('RQ2', '최초 25일까지의 평가 참여와 성과가 이후 이탈을 구분하는가?', '평가 기회 대비 제출률·미제출률·점수·지연'),
        @('RQ3', '학생·과정 특성은 행동 신호를 통제한 뒤에도 유효한가?', '과정 코드·재수강·학력·빈곤지수·장애 등'),
        @('RQ4', '25·28·32일 중 조기성과 구분력의 균형이 가장 좋은 시점은 언제인가?', '대상 규모·양성률·커버리지·교차검증 성능 비교'),
        @('RQ5', '어떤 임계값이 위험 학생 누락과 과도한 개입의 균형을 이루는가?', 'Recall-Precision 및 개입 비용 시나리오')
    ) -Widths @(40, 230, 180)

    Add-Paragraph -Text '5. 데이터 구성' -Style -2
    Add-Table -Headers @('테이블', '역할', '주요 변수') -Rows @(
        @('studentInfo', '학생·과정 기본 정보와 최종 결과', '인구통계, 재수강, 학점, final_result'),
        @('studentRegistration', '등록과 취소 시점', 'date_registration, date_unregistration'),
        @('courses', '과목-학기 메타데이터', 'module_presentation_length'),
        @('assessments', '평가 계획', '유형, 마감일, 배점'),
        @('studentAssessment', '학생별 제출 결과', '제출일, 점수, is_banked'),
        @('vle', '학습 콘텐츠 메타데이터', 'activity_type, 제공 주차'),
        @('studentVle', '학생별 VLE 행동 로그', '날짜, 자료, sum_click')
    ) -Widths @(100, 170, 180)
    Add-Paragraph -Text '기본 그레인은 (id_student, code_module, code_presentation)당 1행이다. 동일 학생이 여러 과정·학기에 등장할 수 있으므로 모델 검증 시 학생 단위 중복을 고려한다.'

    Add-Paragraph -Text '6. 예측 데이터 계약' -Style -2
    Add-Paragraph -Text '6.1 랜드마크 코호트' -Style -3
    Add-Table -Headers @('구분', '정의', '처리') -Rows @(
        @('모델 대상', '25일 시점에 재학 중이며 상태 판정이 가능한 학생', '통합 테이블 포함'),
        @('양성 타깃', '모델 대상 중 25일 이후 최종 Withdrawn', 'target_churn_after_25 = 1'),
        @('음성 타깃', '모델 대상 중 Pass, Distinction 또는 Fail', 'target_churn_after_n = 0'),
        @('초기 이탈', 'date_unregistration <= N', '주 모델 제외, 별도 EDA'),
        @('판정 불명', 'Withdrawn이지만 date_unregistration 결측인 93건', '주 분석 제외, 민감도 분석')
    ) -Widths @(90, 230, 130)
    Add-Paragraph -Text '6.2 랜드마크 25일 선정 결정' -Style -3
    Add-Table -Headers @('후보', '장점', '한계') -Rows @(
        @('25일', '더 많은 미래 이탈자를 개입 대상으로 유지', '평가 행동 신호가 상대적으로 약할 수 있음'),
        @('28일', '4주 단위로 설명·운영하기 쉽고 기존 자산 활용 가능', '데이터상 유일한 절단점은 아님'),
        @('32일', '평가 및 행동 신호가 더 강함', '이미 이탈한 학생이 늘어 개입 대상 감소')
    ) -Widths @(60, 210, 180)
    Add-Paragraph -Text '동일한 랜드마크 정의로 대상자 수, 이후 이탈자 수, 평가 기회 커버리지와 Logistic 기준 모델을 비교한 결과 25일이 가장 많은 향후 이탈자를 보존하고 PR-AUC도 가장 높았다. 이에 2026-09-02 랜드마크를 25일로 최종 확정했다.'

    Add-Paragraph -Text '7. 피처 설계' -Style -2
    Add-Table -Headers @('영역', '후보 피처', '핵심 처리 원칙') -Rows @(
        @('학생·과정', '과정, 학기, 학력, 연령대, IMD, 장애, 재수강, 학점, 등록시점', '범주형 인코딩; 과정과 학생 구성 효과를 함께 해석'),
        @('VLE', '클릭 합계, 활동일, 자료 수, 최초·최근 활동, 주차별 변화, 활동유형 비중', '중복 행 수가 아닌 sum_click 합산; 무활동을 0과 플래그로 구분'),
        @('평가', '평가 기회 수, 제출·미제출 수/비율, 평균 점수, 평균 지연', '25일까지 마감된 weight>0 비이월 TMA/CMA만 사용'),
        @('상태 플래그', '평가 기회 없음, VLE 무활동, 등록일 결측', '구조적 결측과 데이터 결측을 구분')
    ) -Widths @(75, 230, 165)
    Add-Paragraph -Text '7.1 누수 방지' -Style -3
    Add-Bullets -Items @(
        'final_result, date_unregistration, label_churn 및 코호트·타깃 파생값은 입력 피처에서 제외한다.',
        '25일 이후의 클릭, 제출, 점수와 전체 기간 집계값을 사용하지 않는다.',
        '전처리·대치·스케일링·리샘플링은 학습 fold 안에서만 수행한다.',
        '전체 학기 전반/후반 클릭 감소는 사용하지 않고 N일 내부의 주차 변화로 다시 정의한다.'
    )

    Add-Paragraph -Text '8. 데이터 품질 및 전처리 원칙' -Style -2
    Add-Table -Headers @('확인 사항', '현재 발견', '처리 원칙') -Rows @(
        @('이탈 라벨 정합성', 'Withdrawn-취소일 불일치 존재', '이탈 여부와 이탈 시점의 역할 분리'),
        @('VLE 중복', '동일 학생-자료-날짜에 복수 로그', 'sum_click 합계로 집계'),
        @('VLE 미접속', '행 자체가 없는 학생 존재', 'roster left join 후 0 및 별도 플래그'),
        @('is_banked', 'date_submitted=-1은 플레이스홀더', '제출 시점·지연 계산에서 제외'),
        @('평가 기회', '과목별 첫 마감일 편차가 큼', '기회 없음과 미제출 구분'),
        @('롱테일', '클릭과 활동량 극단값 존재', '오류 여부 검증 후 로그변환·강건 처리 비교')
    ) -Widths @(95, 175, 200)

    Add-Paragraph -Text '9. 모델링 및 검증 계획' -Style -2
    Add-Paragraph -Text '9.1 모델 후보' -Style -3
    Add-Table -Headers @('모델', '역할', '선정 이유') -Rows @(
        @('Dummy Classifier', '최소 기준선', '클래스 분포만 반영한 성능과 비교'),
        @('Logistic Regression', '해석 가능한 기준 모델', '계수 방향과 선형 기준선 제공'),
        @('Random Forest', '비선형 앙상블 비교', '상호작용·비선형 관계 대응'),
        @('XGBoost 계열', '성능 최적화 후보', '불균형 표형 데이터에서 강한 기준 제공')
    ) -Widths @(120, 130, 220)
    Add-Paragraph -Text '9.2 검증 설계' -Style -3
    Add-Bullets -Items @(
        '동일 학생이 학습·검증 데이터에 동시에 들어가는 것을 막기 위한 Group split을 우선 검토한다.',
        '실제 미래 일반화를 확인하기 위해 가능한 경우 학기 기반 holdout을 함께 비교한다.',
        'N 선택과 하이퍼파라미터 선택은 최종 테스트 세트를 보지 않고 수행한다.',
        '클래스 가중치와 임계값 조정을 우선하고, 리샘플링은 학습 fold 내부에서만 적용한다.'
    )
    Add-Paragraph -Text '9.3 평가 지표' -Style -3
    Add-Table -Headers @('지표', '용도') -Rows @(
        @('Recall', '실제 이탈 위험 학생을 얼마나 놓치지 않는지 평가하는 우선 지표'),
        @('Precision', '개입 대상 중 실제 위험 학생의 비율'),
        @('F1', 'Recall과 Precision의 균형'),
        @('PR-AUC', '불균형 타깃에서 전반적인 탐지 품질 평가'),
        @('ROC-AUC', '임계값 전반의 순위 구분력 보조 평가'),
        @('Confusion Matrix', '개입 누락과 과잉 개입 규모를 실인원으로 확인'),
        @('Calibration', '예측확률을 위험도로 사용할 수 있는지 확인')
    ) -Widths @(120, 350)

    Add-Paragraph -Text '10. 모델 해석과 개입 전략' -Style -2
    Add-Paragraph -Text '모델은 위험 학생을 표시하는 데서 끝나지 않고, 담당자가 행동할 수 있는 신호를 제공해야 한다. Logistic 계수, permutation importance 또는 SHAP을 사용하되 상관된 피처와 과정 효과를 고려해 인과관계로 과장하지 않는다.'
    Add-Table -Headers @('위험 신호 예시', '가능한 개입', '주의') -Rows @(
        @('VLE 무활동·활동일 부족', '접속 확인, 기술 문제 점검, 초기 상담', '과목별 VLE 의존도 차이 통제'),
        @('최근 활동 감소', '개별 메시지, 학습계획 점검', 'N일 내부 변화만 사용'),
        @('평가 미제출·지연', '마감 전 알림, 보충 일정 안내', '평가 기회가 있는 학생만 적용'),
        @('재수강·등록 이상 신호', '선행학습 수준과 수강부담 상담', '낙인 효과 방지'),
        @('과정별 높은 기본위험', '과정별 임계값·운영 개선 검토', '개인 책임으로 단정 금지')
    ) -Widths @(130, 180, 160)

    Add-Paragraph -Text '11. 실행 로드맵' -Style -2
    Add-Table -Headers @('단계', '핵심 작업', '완료 기준') -Rows @(
        @('M1 목표·N 확정', '25/28/32일 랜드마크 코호트 재비교', '완료 — 25일 확정 및 근거 문서화'),
        @('M2 통합 테이블', '코호트·타깃·N일 피처 구현', '키 유일성·행 수·누수 검증 통과'),
        @('M3 전처리', '결측·이상치·인코딩·공선성 처리', '컬럼별 처리 근거와 최종 피처 확정'),
        @('M4 모델링', '기준선 및 3개 모델 비교', '교차검증과 holdout 결과 확보'),
        @('M5 해석·개입', '중요 신호·하위집단·임계값 분석', '실행 가능한 위험군 기준 제안'),
        @('M6 최종화', 'README, 보고서, 발표자료 정리', '재현 가능한 실행 순서와 최종 결론')
    ) -Widths @(80, 220, 170)

    Add-Paragraph -Text '12. 산출물' -Style -2
    Add-Numbered -Items @(
        '25·28·32일 랜드마크 비교표 및 25일 확정 의사결정 기록',
        '학생-과목-학기 단위 모델링 통합 테이블과 데이터 사전',
        '재현 가능한 전처리·모델링 파이프라인',
        '모델 성능 및 임계값 비교 보고서',
        '주요 위험 신호 해석과 개입 전략',
        '최종 README, 기획서 및 발표자료'
    )

    Add-Paragraph -Text '13. 리스크와 대응' -Style -2
    Add-Table -Headers @('리스크', '영향', '대응') -Rows @(
        @('N 이전 이탈자 제외', '전체 이탈의 일부만 예측', '초기 이탈 EDA를 별도 결과로 제시'),
        @('취소일 결측 Withdrawn 93건', '코호트 판정 불명확', '주 분석 제외 후 포함 민감도 분석'),
        @('과정별 커리큘럼 차이', '평가·VLE 피처의 의미가 달라짐', '과정 통제, 기회 플래그, 과정별 성능 확인'),
        @('관찰 데이터의 인과 한계', '중요 피처를 원인으로 오해', '예측 연관성으로 표현하고 개입 실험 필요성 명시'),
        @('동일 학생 복수 수강', '무작위 분할 시 성능 과대평가', 'Group split 또는 시간 기반 검증'),
        @('개인 프로젝트 범위 확대', '완성도 저하와 일정 지연', '공공데이터·대시보드를 후속 범위로 유지')
    ) -Widths @(130, 155, 185)

    Add-Paragraph -Text '14. 성공 기준' -Style -2
    Add-Bullets -Items @(
        '예측 시점과 타깃 시점이 분리되고 25일 이후 정보가 입력에 포함되지 않는다.',
        '통합 테이블의 그레인과 키 유일성이 검증된다.',
        'Dummy 및 Logistic 기준선 대비 모델의 탐지 성능이 개선된다.',
        'Recall을 높일 때 발생하는 과잉 개입 규모를 Precision과 실인원으로 설명할 수 있다.',
        '과정·학기 및 주요 하위집단별 성능 편차를 보고한다.',
        '위험 신호가 담당자의 구체적인 개입 행동과 연결된다.',
        '다른 환경에서 데이터 준비부터 평가까지 재현할 수 있다.'
    )

    Add-Paragraph -Text '15. 현재 진행 상황' -Style -2
    Add-Table -Headers @('영역', '상태', '비고') -Rows @(
        @('기획·데이터 이해', '완료', '스터디 공동 진행'),
        @('개별 및 조인 EDA', '완료', '스터디 공동 진행'),
        @('가설·관측시점 후보 분석', '완료', '25/28/32일 후보 도출'),
        @('예측 시간 구조', '완료', 'N일 재학생의 이후 이탈로 확정'),
        @('최종 N', '완료', '2026-09-02 랜드마크 25일 확정'),
        @('25일 통합 테이블 이후', '미착수', '개인 작업 범위')
    ) -Widths @(160, 90, 220)

    Add-Paragraph -Text '16. 최종 의사결정 요약' -Style -2
    Add-Paragraph -Text '본 프로젝트는 “전체 이탈자를 사후적으로 잘 분류하는 모델”보다 “25일 시점에 실제로 개입 가능한 학생의 미래 이탈을 예측하는 모델”을 지향한다. 따라서 25일 이전 이탈자는 별도 분석으로 분리하고, 25일 재학생 코호트에서 이후 이탈을 예측한다. 현재는 OULAD 기반 핵심 모델 완성을 우선하며, 공공데이터와 대시보드는 결과의 완성도와 데이터 확보 상황에 따라 확장한다.'

    $tocRange = $doc.Range(0, 0)
    $tocRange.InsertBefore("목차`r")
    $tocRange.Collapse(0)
    $tocRange.InsertBreak(7)
    $tocRange = $doc.Range(0, 0)
    $doc.TablesOfContents.Add($tocRange, $true, 1, 3) | Out-Null

    $footer = $doc.Sections.Item(1).Footers.Item(1).Range
    $footer.Text = 'OULAD 학습자 중도이탈 예측 프로젝트 기획서'
    $footer.ParagraphFormat.Alignment = 1
    $footer.Font.Name = '맑은 고딕'
    $footer.Font.Size = 8

    $doc.Fields.Update() | Out-Null
    $doc.SaveAs2($outputFullPath, 16)
    Write-Output "Created: $outputFullPath"
}
finally {
    if ($doc) { $doc.Close($false); [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($doc) }
    if ($word) { $word.Quit(); [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}



