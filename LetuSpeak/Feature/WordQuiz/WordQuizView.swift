//
//  WordQuizView.swift
//  LetuSpeak
//
//  Created by 심성곤 on 7/19/25.
//

import SwiftUI

// MARK: - 난이도 레벨 열거형
enum DifficultyLevel: String, CaseIterable {
    case beginner = "초급"
    case intermediate = "중급"
    case advanced = "고급"
    
    var description: String {
        switch self {
        case .beginner:
            return "기초 단어 10개"
        case .intermediate:
            return "일상 단어 200개"
        case .advanced:
            return "고급 단어 300개"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner:
            return .green
        case .intermediate:
            return .orange
        case .advanced:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .beginner:
            return false
        case .intermediate, .advanced:
            return true
        }
    }
}

// MARK: - 데이터 관리 클래스
@Observable
class WordQuizDataManager {
    @ObservationIgnored
    @AppStorage("learnedWords") private var learnedWordsData: Data = Data()
    @ObservationIgnored
    @AppStorage("totalScore") var totalScore: Int = 0
    @ObservationIgnored
    @AppStorage("consecutiveDays") var consecutiveDays: Int = 0
    @ObservationIgnored
    @AppStorage("lastStudyDate") private var lastStudyDateString: String = ""
    
    var learnedWords: Set<String> = []
    
    init() {
        loadLearnedWords()
        updateConsecutiveDays()
    }
    
    private func loadLearnedWords() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: learnedWordsData) {
            learnedWords = decoded
        }
    }
    
    private func saveLearnedWords() {
        if let encoded = try? JSONEncoder().encode(learnedWords) {
            learnedWordsData = encoded
        }
    }
    
    func addLearnedWord(_ word: String) {
        learnedWords.insert(word)
        saveLearnedWords()
    }
    
    func addScore(_ points: Int) {
        totalScore += points
    }
    
    private func updateConsecutiveDays() {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)
        
        if lastStudyDateString.isEmpty {
            // 첫 학습
            consecutiveDays = 1
            lastStudyDateString = todayString
        } else if let lastDate = formatter.date(from: lastStudyDateString) {
            let dayDiff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if dayDiff == 0 {
                // 오늘 이미 학습함
                return
            } else if dayDiff == 1 {
                // 연속 학습
                consecutiveDays += 1
                lastStudyDateString = todayString
            } else {
                // 연속 학습 끊어짐
                consecutiveDays = 1
                lastStudyDateString = todayString
            }
        }
    }
    
    func markTodayAsStudied() {
        updateConsecutiveDays()
    }
    
    var correctRate: Int {
        guard learnedWords.count > 0 else { return 0 }
        // 간단한 정답률 계산 (실제로는 더 복잡한 로직 필요)
        return min(95, 70 + (learnedWords.count * 2))
    }
}

// MARK: - 메인 단어 퀴즈 뷰
struct WordQuizView: View {
    @State private var dataManager = WordQuizDataManager()
    @State private var selectedDifficulty: DifficultyLevel? = nil
    @State private var showQuiz = false
    @State private var showPremiumAlert = false
    
    var body: some View {
        NavigationStack {
            if showQuiz, let difficulty = selectedDifficulty {
                WordQuizGameView(
                    difficulty: difficulty,
                    showQuiz: $showQuiz,
                    dataManager: dataManager
                )
            } else {
                WordQuizHomeView(
                    selectedDifficulty: $selectedDifficulty,
                    showQuiz: $showQuiz,
                    showPremiumAlert: $showPremiumAlert,
                    dataManager: dataManager
                )
            }
        }
        .alert("프리미엄 기능", isPresented: $showPremiumAlert) {
            Button("취소", role: .cancel) { }
            Button("구매하기") {
                // 결제 로직 구현
                print("프리미엄 구매 페이지로 이동")
            }
        } message: {
            Text("중급과 고급 단계는 프리미엄 구독이 필요합니다.\n더 많은 단어를 학습하고 실력을 향상시켜보세요!")
        }
    }
}

// MARK: - 퀴즈 홈 화면
struct WordQuizHomeView: View {
    @Binding var selectedDifficulty: DifficultyLevel?
    @Binding var showQuiz: Bool
    @Binding var showPremiumAlert: Bool
    @Bindable var dataManager: WordQuizDataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 헤더 섹션
                VStack(spacing: 15) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("영어 단어를 학습하고 퀴즈를 통해 실력을 확인해보세요!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // 통계 카드들
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatCard(
                        title: "학습한 단어",
                        value: "\(dataManager.learnedWords.count)",
                        icon: "book.fill",
                        color: .blue
                    )
                    StatCard(
                        title: "정답률",
                        value: "\(dataManager.correctRate)%",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    StatCard(
                        title: "연속 학습",
                        value: "\(dataManager.consecutiveDays)일",
                        icon: "flame.fill",
                        color: .orange
                    )
                    StatCard(
                        title: "총 점수",
                        value: "\(dataManager.totalScore)",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
                .padding(.horizontal)
                
                // 난이도 선택
                VStack(alignment: .leading, spacing: 15) {
                    Text("난이도 선택")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { difficulty in
                            DifficultyCard(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty,
                                onTap: {
                                    handleDifficultySelection(difficulty)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 퀴즈 시작 버튼
                Button(action: {
                    if selectedDifficulty != nil {
                        withAnimation(.spring()) {
                            showQuiz = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("퀴즈 시작하기")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedDifficulty != nil
                        ? LinearGradient(
                            gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [.gray, .gray.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .shadow(
                        color: selectedDifficulty != nil ? .green.opacity(0.3) : .clear,
                        radius: 10,
                        x: 0,
                        y: 5
                    )
                }
                .disabled(selectedDifficulty == nil)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("단어 퀴즈")
    }
    
    private func handleDifficultySelection(_ difficulty: DifficultyLevel) {
        if difficulty.isPremium {
            showPremiumAlert = true
        } else {
            // 이미 선택된 난이도를 다시 누르면 해제
            if selectedDifficulty == difficulty {
                selectedDifficulty = nil
            } else {
                selectedDifficulty = difficulty
            }
        }
    }
}

// MARK: - 퀴즈 게임 화면
struct WordQuizGameView: View {
    let difficulty: DifficultyLevel
    @Binding var showQuiz: Bool
    @Bindable var dataManager: WordQuizDataManager
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String? = nil
    @State private var timeRemaining = 30
    @State private var timer: Timer? = nil
    @State private var quizCompleted = false
    
    // 난이도별 샘플 퀴즈 데이터 (10개로 확장)
    private var questions: [QuizQuestion] {
        switch difficulty {
        case .beginner:
            return [
                QuizQuestion(word: "Apple", meaning: "사과", options: ["사과", "바나나", "오렌지", "포도"]),
                QuizQuestion(word: "Cat", meaning: "고양이", options: ["개", "고양이", "새", "물고기"]),
                QuizQuestion(word: "Book", meaning: "책", options: ["펜", "책", "종이", "연필"]),
                QuizQuestion(word: "Water", meaning: "물", options: ["물", "우유", "주스", "커피"]),
                QuizQuestion(word: "House", meaning: "집", options: ["학교", "집", "공원", "병원"]),
                QuizQuestion(word: "Sun", meaning: "태양", options: ["달", "별", "태양", "구름"]),
                QuizQuestion(word: "Dog", meaning: "개", options: ["개", "고양이", "새", "토끼"]),
                QuizQuestion(word: "Car", meaning: "자동차", options: ["자전거", "자동차", "기차", "비행기"]),
                QuizQuestion(word: "Tree", meaning: "나무", options: ["꽃", "나무", "풀", "잎"]),
                QuizQuestion(word: "Moon", meaning: "달", options: ["태양", "달", "별", "구름"])
            ]
        case .intermediate:
            return [
                QuizQuestion(word: "Beautiful", meaning: "아름다운", options: ["아름다운", "못생긴", "크다", "작다"]),
                QuizQuestion(word: "Computer", meaning: "컴퓨터", options: ["텔레비전", "컴퓨터", "냉장고", "세탁기"]),
                QuizQuestion(word: "Elephant", meaning: "코끼리", options: ["사자", "호랑이", "코끼리", "기린"]),
                QuizQuestion(word: "Freedom", meaning: "자유", options: ["자유", "감옥", "규칙", "법률"]),
                QuizQuestion(word: "Journey", meaning: "여행", options: ["여행", "집", "일", "휴식"]),
                QuizQuestion(word: "Mountain", meaning: "산", options: ["바다", "강", "산", "평야"]),
                QuizQuestion(word: "Kitchen", meaning: "부엌", options: ["침실", "부엌", "화장실", "거실"]),
                QuizQuestion(word: "Weather", meaning: "날씨", options: ["시간", "날씨", "계절", "온도"]),
                QuizQuestion(word: "Library", meaning: "도서관", options: ["병원", "학교", "도서관", "은행"]),
                QuizQuestion(word: "Rainbow", meaning: "무지개", options: ["번개", "천둥", "무지개", "바람"])
            ]
        case .advanced:
            return [
                QuizQuestion(word: "Magnificent", meaning: "웅장한", options: ["웅장한", "작은", "조용한", "빠른"]),
                QuizQuestion(word: "Philosophy", meaning: "철학", options: ["과학", "철학", "수학", "역사"]),
                QuizQuestion(word: "Extraordinary", meaning: "비범한", options: ["평범한", "비범한", "일반적인", "보통의"]),
                QuizQuestion(word: "Unprecedented", meaning: "전례 없는", options: ["전례 없는", "흔한", "일상적인", "예상된"]),
                QuizQuestion(word: "Sophisticated", meaning: "정교한", options: ["단순한", "정교한", "거친", "기본적인"]),
                QuizQuestion(word: "Phenomenon", meaning: "현상", options: ["현상", "원인", "결과", "과정"]),
                QuizQuestion(word: "Catastrophe", meaning: "재앙", options: ["축복", "재앙", "기회", "행운"]),
                QuizQuestion(word: "Enthusiasm", meaning: "열정", options: ["무관심", "열정", "피로", "슬픔"]),
                QuizQuestion(word: "Intimidate", meaning: "위협하다", options: ["격려하다", "도와주다", "위협하다", "칭찬하다"]),
                QuizQuestion(word: "Resilience", meaning: "회복력", options: ["약함", "회복력", "포기", "절망"])
            ]
        }
    }
    
    var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if quizCompleted {
                QuizResultView(
                    difficulty: difficulty,
                    score: score,
                    totalQuestions: questions.count,
                    onRestart: restartQuiz,
                    onExit: { showQuiz = false }
                )
            } else {
                // 난이도 표시
                HStack {
                    Label(difficulty.rawValue, systemImage: difficulty.icon)
                        .font(.headline)
                        .foregroundColor(difficulty.color)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(score)")
                            .fontWeight(.bold)
                    }
                    .font(.headline)
                }
                .padding(.horizontal)
                
                // 프로그레스와 문제 번호
                VStack(spacing: 10) {
                    HStack {
                        Text("문제 \(currentQuestionIndex + 1)/\(questions.count)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: difficulty.color))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal)
                }
                
                // 타이머
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                    Text("\(timeRemaining)초")
                        .fontWeight(.bold)
                        .foregroundColor(timeRemaining <= 10 ? .red : .orange)
                }
                .font(.title3)
                
                Spacer()
                
                // 단어 카드
                VStack(spacing: 20) {
                    Text(currentQuestion.word)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(difficulty.color.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(difficulty.color.opacity(0.3), lineWidth: 2)
                        )
                    
                    Text("이 단어의 뜻은?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 선택지들
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(currentQuestion.options, id: \.self) { option in
                        Button(action: {
                            selectAnswer(option)
                        }) {
                            Text(option)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(selectedAnswer == option ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    selectedAnswer == option
                                    ? (option == currentQuestion.meaning ? Color.green : Color.red)
                                    : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(
                                            selectedAnswer == option
                                            ? Color.clear
                                            : Color.gray.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        }
                        .disabled(selectedAnswer != nil)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 다음 버튼
                if selectedAnswer != nil {
                    Button(action: nextQuestion) {
                        Text(currentQuestionIndex == questions.count - 1 ? "결과 보기" : "다음 문제")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(difficulty.color)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .navigationTitle("\(difficulty.rawValue) 퀴즈")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("나가기") {
                    showQuiz = false
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
        timer?.invalidate()
        
        if answer == currentQuestion.meaning {
            let points = timeRemaining * 10
            score += points
            // 정답인 경우 학습한 단어로 추가
            dataManager.addLearnedWord(currentQuestion.word)
        }
        
        // 1.5초 후 자동으로 다음 문제로 (버튼을 누르지 않은 경우에만)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !quizCompleted && selectedAnswer != nil {
                nextQuestion()
            }
        }
    }
    
    private func nextQuestion() {
        // 이미 다음 문제로 넘어간 상태라면 중복 실행 방지
        guard selectedAnswer != nil else { return }
        
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
                selectedAnswer = nil // 여기서 nil로 만들어서 asyncAfter 중복 실행 방지
                timeRemaining = 30
                startTimer()
            }
        } else {
            // 퀴즈 완료 시 데이터 저장
            dataManager.addScore(score)
            dataManager.markTodayAsStudied()
            quizCompleted = true
            selectedAnswer = nil // 완료 상태에서도 nil로 설정
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 시간 초과
                selectAnswer("") // 빈 답으로 처리
            }
        }
    }
    
    private func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        timeRemaining = 30
        quizCompleted = false
        startTimer()
    }
}

// MARK: - 퀴즈 질문 모델
struct QuizQuestion {
    let word: String
    let meaning: String
    let options: [String]
}

// MARK: - 통계 카드
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 난이도 카드 (클릭 가능)
struct DifficultyCard: View {
    let difficulty: DifficultyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: difficulty.icon)
                        .font(.title2)
                        .foregroundColor(difficulty.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(difficulty.rawValue)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if difficulty.isPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(difficulty.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(difficulty.color)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                isSelected
                ? difficulty.color.opacity(0.1)
                : Color.white
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? difficulty.color : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 퀴즈 결과 화면
struct QuizResultView: View {
    let difficulty: DifficultyLevel
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    
    private var correctAnswers: Int {
        // 임시로 점수 기반 계산
        min(totalQuestions, max(0, score / 200))
    }
    
    private var percentage: Int {
        Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 난이도 표시
            Label(difficulty.rawValue + " 완료!", systemImage: difficulty.icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(difficulty.color)
            
            // 결과 아이콘
            Image(systemName: percentage >= 80 ? "star.circle.fill" : percentage >= 60 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(percentage >= 80 ? .yellow : percentage >= 60 ? .green : .red)
            
            VStack(spacing: 10) {
                Text("퀴즈 완료!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("수고하셨습니다!")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            // 점수 카드
            VStack(spacing: 20) {
                HStack(spacing: 40) {
                    VStack {
                        Text("\(correctAnswers)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("정답")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(totalQuestions - correctAnswers)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("오답")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    VStack {
                        Text("\(percentage)%")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("정답률")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Text("총 점수: \(score)점")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(15)
            
            // 버튼들
            VStack(spacing: 15) {
                Button(action: onRestart) {
                    Text("다시 도전하기")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(difficulty.color)
                        .cornerRadius(15)
                }
                
                Button(action: onExit) {
                    Text("메뉴로 돌아가기")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(difficulty.color)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(difficulty.color.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - 프리뷰
#Preview {
    WordQuizView()
}
