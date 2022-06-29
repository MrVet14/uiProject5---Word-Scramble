//
//  ContentView.swift
//  uiProject5 - Word Scramble
//
//  Created by Vitali Vyucheiski on 6/27/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    let newGameAlertTitle = "Start new game"
    let newGameAlertMessage = "The will erase all of your current progress.\nYou sure you want to start new game?"
    @State private var showNewGameAlert = false
    
    @State private var userScore = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("Restart Game", action: { showNewGameAlert = true })
            }
            .alert("New Game", isPresented: $showNewGameAlert) {
                HStack {
                    Button("Cancel", role: .cancel) {}
                    Button("Start New Game", role: .destructive) { startNewGame() }
                }
            } message: {
                Text("The will erase all of your current progress.\nYou sure you want to start new game?")
            }
            .safeAreaInset(edge: .bottom) {
                Text("Score: \(userScore)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.secondary)
                    .font(.system(size: 20))
            }
        }
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            retractingFromScore()
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell '\(answer)' from '\(rootWord)'")
            retractingFromScore()
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "you can't just make them up, you know")
            retractingFromScore()
            return
        }
        guard isTheSameAsRootWord(word: answer) else {
            wordError(title: "The same as given word", message: "You can's use root word as your answer")
            retractingFromScore()
            return
        }
        guard is3OrMoreLetters(word: answer) else {
            wordError(title: "Word is less than 3 letter", message: "You have to use words with 3 or more letters")
            retractingFromScore()
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        userScore += answer.count + usedWords.count
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isTheSameAsRootWord(word: String) -> Bool {
        word != rootWord
    }
    
    func is3OrMoreLetters(word: String) -> Bool {
        word.count >= 3
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func startNewGame() {
        newWord = ""
        userScore = 0
        usedWords.removeAll()
        startGame()
    }
    
    func retractingFromScore() {
        userScore -= 2
        if userScore < 0 { userScore = 0 }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro Max")
    }
}
