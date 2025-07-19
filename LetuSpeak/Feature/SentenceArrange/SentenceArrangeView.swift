//
//  SentenceArrangeView.swift
//  LetuSpeak
//
//  Created by Importants on 7/19/25.
//


import SwiftUI

// MARK: - 난이도 레벨 열거형
enum SentenceDifficulty: String, CaseIterable {
    case beginner = "초급"
    case intermediate = "중급"
    case advanced = "고급"
    
    var description: String {
        switch self {
        case .beginner:
            return "간단한 문장 10개"
        case .intermediate:
            return "일반 문장 200개"
        case .advanced:
            return "복합 문장 300개"
        }
    }
    
    var color: Color {
        switch self {
        case .beginner:
            return .blue
        case .intermediate:
            return .orange
        case .advanced:
            return .purple
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

// MARK: - 문장 배열 데이터 관리 클래스
@Observable
class SentenceArrangeDataManager {
    @ObservationIgnored
    @AppStorage("completedSentences") private var completedSentencesData: Data = Data()
    @ObservationIgnored
    @AppStorage("sentenceTotalScore") var totalScore: Int = 0
    @ObservationIgnored
    @AppStorage("sentenceConsecutiveDays") var consecutiveDays: Int = 0
    @ObservationIgnored
    @AppStorage("sentenceLastStudyDate") private var lastStudyDateString: String = ""
    
    var completedSentences: Set<String> = []
    
    init() {
        loadCompletedSentences()
        updateConsecutiveDays()
    }
    
    private func loadCompletedSentences() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: completedSentencesData) {
            completedSentences = decoded
        }
    }
    
    private func saveCompletedSentences() {
        if let encoded = try? JSONEncoder().encode(completedSentences) {
            completedSentencesData = encoded
        }
    }
    
    func addCompletedSentence(_ sentence: String) {
        completedSentences.insert(sentence)
        saveCompletedSentences()
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
            consecutiveDays = 1
            lastStudyDateString = todayString
        } else if let lastDate = formatter.date(from: lastStudyDateString) {
            let dayDiff = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if dayDiff == 0 {
                return
            } else if dayDiff == 1 {
                consecutiveDays += 1
                lastStudyDateString = todayString
            } else {
                consecutiveDays = 1
                lastStudyDateString = todayString
            }
        }
    }
    
    func markTodayAsStudied() {
        updateConsecutiveDays()
    }
    
    var accuracy: Int {
        guard completedSentences.count > 0 else { return 0 }
        return min(98, 75 + (completedSentences.count * 2))
    }
}

// MARK: - 메인 문장 배열 뷰
struct SentenceArrangeView: View {
    @State private var dataManager = SentenceArrangeDataManager()
    @State private var selectedDifficulty: SentenceDifficulty? = nil
    @State private var showGame = false
    @State private var showPremiumAlert = false
    
    var body: some View {
        NavigationStack {
            if showGame, let difficulty = selectedDifficulty {
                SentenceArrangeGameView(
                    difficulty: difficulty,
                    showGame: $showGame,
                    dataManager: dataManager
                )
            } else {
                SentenceArrangeHomeView(
                    selectedDifficulty: $selectedDifficulty,
                    showGame: $showGame,
                    showPremiumAlert: $showPremiumAlert,
                    dataManager: dataManager
                )
            }
        }
        .alert("프리미엄 기능", isPresented: $showPremiumAlert) {
            Button("취소", role: .cancel) { }
            Button("구매하기") {
                print("프리미엄 구매 페이지로 이동")
            }
        } message: {
            Text("중급과 고급 단계는 프리미엄 구독이 필요합니다.\n더 복잡한 문장으로 실력을 향상시켜보세요!")
        }
    }
}

// MARK: - 문장 배열 홈 화면
struct SentenceArrangeHomeView: View {
    @Binding var selectedDifficulty: SentenceDifficulty?
    @Binding var showGame: Bool
    @Binding var showPremiumAlert: Bool
    @Bindable var dataManager: SentenceArrangeDataManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 헤더 섹션
                VStack(spacing: 15) {
                    Image(systemName: "text.line.first.and.arrowtriangle.forward")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("단어들을 올바른 순서로 배열하여\n완전한 문장을 만들어보세요!")
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
                    SentenceStatCard(
                        title: "완성한 문장",
                        value: "\(dataManager.completedSentences.count)",
                        icon: "checkmark.circle.fill",
                        color: .blue
                    )
                    SentenceStatCard(
                        title: "정확도",
                        value: "\(dataManager.accuracy)%",
                        icon: "target",
                        color: .green
                    )
                    SentenceStatCard(
                        title: "연속 학습",
                        value: "\(dataManager.consecutiveDays)일",
                        icon: "flame.fill",
                        color: .orange
                    )
                    SentenceStatCard(
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
                        ForEach(SentenceDifficulty.allCases, id: \.self) { difficulty in
                            SentenceDifficultyCard(
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
                
                // 연습 시작 버튼
                Button(action: {
                    if selectedDifficulty != nil {
                        withAnimation(.spring()) {
                            showGame = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("연습 시작하기")
                            .fontWeight(.semibold)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        selectedDifficulty != nil
                        ? LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
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
                        color: selectedDifficulty != nil ? .blue.opacity(0.3) : .clear,
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
        .navigationTitle("문장 배열")
    }
    
    private func handleDifficultySelection(_ difficulty: SentenceDifficulty) {
        if difficulty.isPremium {
            showPremiumAlert = true
        } else {
            if selectedDifficulty == difficulty {
                selectedDifficulty = nil
            } else {
                selectedDifficulty = difficulty
            }
        }
    }
}

// MARK: - 문장 배열 게임 화면
struct SentenceArrangeGameView: View {
    let difficulty: SentenceDifficulty
    @Binding var showGame: Bool
    @Bindable var dataManager: SentenceArrangeDataManager
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var arrangedWords: [String] = []
    @State private var shuffledWords: [String] = []
    @State private var isCorrect: Bool? = nil
    @State private var showResult = false
    @State private var gameCompleted = false
    @State private var aiItem: SentenceQuestion?
    
    // 난이도별 문장 데이터
    private var sentences: [SentenceQuestion] {
        switch difficulty {
        case .beginner:
            return [
                SentenceQuestion(english: "I love you", korean: "나는 너를 사랑해"),
                SentenceQuestion(english: "She is happy", korean: "그녀는 행복해"),
                SentenceQuestion(english: "We are friends", korean: "우리는 친구야"),
                SentenceQuestion(english: "He likes cats", korean: "그는 고양이를 좋아해"),
                SentenceQuestion(english: "They play soccer", korean: "그들은 축구를 해"),
                SentenceQuestion(english: "I eat apples", korean: "나는 사과를 먹어"),
                SentenceQuestion(english: "She reads books", korean: "그녀는 책을 읽어"),
                SentenceQuestion(english: "We watch movies", korean: "우리는 영화를 봐"),
                SentenceQuestion(english: "He drives cars", korean: "그는 차를 운전해"),
                SentenceQuestion(english: "I drink water", korean: "나는 물을 마셔")
            ]
        case .intermediate:
            return [
                SentenceQuestion(english: "I am going to school", korean: "나는 학교에 가고 있어"),
                SentenceQuestion(english: "She will visit her grandmother", korean: "그녀는 할머니를 방문할 거야"),
                SentenceQuestion(english: "We have been studying English", korean: "우리는 영어를 공부해오고 있어"),
                SentenceQuestion(english: "He can play the piano", korean: "그는 피아노를 칠 수 있어"),
                SentenceQuestion(english: "They should finish their homework", korean: "그들은 숙제를 끝내야 해"),
                SentenceQuestion(english: "I would like some coffee", korean: "나는 커피를 좀 마시고 싶어"),
                SentenceQuestion(english: "She has been working hard", korean: "그녀는 열심히 일해왔어"),
                SentenceQuestion(english: "We must leave early tomorrow", korean: "우리는 내일 일찍 떠나야 해"),
                SentenceQuestion(english: "He might come to the party", korean: "그는 파티에 올지도 몰라"),
                SentenceQuestion(english: "I had finished my work", korean: "나는 일을 끝냈었어")
            ]
        case .advanced:
            return [
                SentenceQuestion(english: "If I had known earlier I would have helped", korean: "내가 더 일찍 알았더라면 도와줬을 거야"),
                SentenceQuestion(english: "Despite being tired she continued working", korean: "피곤함에도 불구하고 그녀는 계속 일했어"),
                SentenceQuestion(english: "The book which I bought yesterday is interesting", korean: "내가 어제 산 책은 흥미로워"),
                SentenceQuestion(english: "Having finished his homework he went to bed", korean: "숙제를 끝내고 나서 그는 잠자리에 들었어"),
                SentenceQuestion(english: "Not only is she smart but also kind", korean: "그녀는 똑똑할 뿐만 아니라 친절하기도 해"),
                SentenceQuestion(english: "The more you practice the better you become", korean: "더 많이 연습할수록 더 잘하게 돼"),
                SentenceQuestion(english: "What surprised me most was his honesty", korean: "나를 가장 놀라게 한 것은 그의 정직함이었어"),
                SentenceQuestion(english: "Unless you hurry you will miss the train", korean: "서둘지 않으면 기차를 놓칠 거야"),
                SentenceQuestion(english: "The reason why he left remains unclear", korean: "그가 떠난 이유는 여전히 불분명해"),
                SentenceQuestion(english: "Were I you I would accept the offer", korean: "내가 너라면 그 제안을 받아들일 거야")
            ]
        }
    }
    
    var currentSentence: SentenceQuestion {
        sentences[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if gameCompleted {
                SentenceResultView(
                    difficulty: difficulty,
                    score: score,
                    totalQuestions: sentences.count,
                    onRestart: restartGame,
                    onExit: { showGame = false }
                )
            } else {
                // 난이도 및 점수 표시
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
                
                // 프로그레스
                VStack(spacing: 10) {
                    HStack {
                        Text("문장 \(currentQuestionIndex + 1)/\(sentences.count)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    ProgressView(value: Double(currentQuestionIndex + 1), total: Double(sentences.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: difficulty.color))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal)
                }
                
                // 한글 문장 (힌트)
                VStack(spacing: 15) {
                    Text("다음 문장을 영어로 배열하세요")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text(currentSentence.korean)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(difficulty.color.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 배열된 문장 영역
                VStack(alignment: .leading, spacing: 10) {
                    Text("배열된 문장:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(arrangedWords.indices, id: \.self) { index in
                                Button(action: {
                                    if isCorrect == nil { // 문장 확인 전에만 누를 수 있음
                                        removeWordFromArrangement(at: index)
                                    }
                                }) {
                                    Text(arrangedWords[index])
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(difficulty.color)
                                        .cornerRadius(8)
                                }
                                .disabled(isCorrect != nil) // 문장 확인 후 비활성화
                            }
                            
                            if arrangedWords.isEmpty {
                                Text("여기에 단어를 배열하세요")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 결과 표시 (가운데)
                if let correct = isCorrect {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(correct ? .green : .red)
                            
                            Text(correct ? "정답입니다!" : "틀렸습니다!")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(correct ? .green : .red)
                        }
                        
                        if !correct {
                            Text("정답: \(currentSentence.english)")
                                .font(.body)
                                .italic()
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .transition(.scale.combined(with: .opacity))
                    
                    Button {
                        aiItem = currentSentence
                    } label: {
                        Label("다른 표현 보기", systemImage: "apple.intelligence")
                            .padding()
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 단어 선택 영역 (하단)
                VStack(alignment: .leading, spacing: 10) {
                    if !shuffledWords.isEmpty {
                        Text("단어 선택:")
                            .font(.headline)
                            .padding(.horizontal)
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 10) {
                        ForEach(shuffledWords, id: \.self) { word in
                            Button(action: {
                                if isCorrect == nil { // 문장 확인 전에만 누를 수 있음
                                    addWordToArrangement(word)
                                }
                            }) {
                                Text(word)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .disabled(isCorrect != nil) // 문장 확인 후 비활성화
                        }
                    }
                }
                .padding()
                
                // 확인 버튼
                if arrangedWords.count == currentSentence.english.components(separatedBy: " ").count && isCorrect == nil {
                    Button(action: checkAnswer) {
                        Text("문장 확인")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(difficulty.color)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                // 다음 버튼
                if let _ = isCorrect {
                    Button(action: nextQuestion) {
                        Text(currentQuestionIndex == sentences.count - 1 ? "결과 보기" : "다음 문장")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(difficulty.color)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
        .navigationTitle("\(difficulty.rawValue) 문장배열")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("나가기") {
                    showGame = false
                }
            }
        }
        .sheet(item: $aiItem) { item in
            SentenceExpressionsSheetView(sentenceQuestion: item)
        }
        .onAppear {
            setupNewQuestion()
        }
    }
    
    private func setupNewQuestion() {
        arrangedWords = []
        shuffledWords = currentSentence.english.components(separatedBy: " ").shuffled()
        isCorrect = nil
    }
    
    private func addWordToArrangement(_ word: String) {
        if let index = shuffledWords.firstIndex(of: word) {
            arrangedWords.append(word)
            shuffledWords.remove(at: index)
        }
    }
    
    private func removeWordFromArrangement(at index: Int) {
        let word = arrangedWords[index]
        arrangedWords.remove(at: index)
        shuffledWords.append(word)
    }
    
    private func checkAnswer() {
        let userSentence = arrangedWords.joined(separator: " ")
        let correct = userSentence == currentSentence.english
        
        isCorrect = correct
        
        if correct {
            score += 100 // 고정 점수
            dataManager.addCompletedSentence(currentSentence.english)
        }
    }
    
    private func nextQuestion() {
        guard isCorrect != nil else { return }
        
        if currentQuestionIndex < sentences.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
                setupNewQuestion()
                isCorrect = nil
            }
        } else {
            dataManager.addScore(score)
            dataManager.markTodayAsStudied()
            gameCompleted = true
            isCorrect = nil
        }
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        score = 0
        gameCompleted = false
        setupNewQuestion()
    }
}

// MARK: - 통계 카드
struct SentenceStatCard: View {
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

// MARK: - 난이도 카드
struct SentenceDifficultyCard: View {
    let difficulty: SentenceDifficulty
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 결과 화면
struct SentenceResultView: View {
    let difficulty: SentenceDifficulty
    let score: Int
    let totalQuestions: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    
    private var correctAnswers: Int {
        min(totalQuestions, max(0, score / 100))
    }
    
    private var percentage: Int {
        Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Label(difficulty.rawValue + " 완료!", systemImage: difficulty.icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(difficulty.color)
            
            Image(systemName: percentage >= 80 ? "star.circle.fill" : percentage >= 60 ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(percentage >= 80 ? .yellow : percentage >= 60 ? .green : .red)
            
            VStack(spacing: 10) {
                Text("연습 완료!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("수고하셨습니다!")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
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
                        Text("정확도")
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
    SentenceArrangeView()
//    MainTabView()
}
