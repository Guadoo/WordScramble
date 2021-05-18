//
//  ContentView.swift
//  WordScramble
//
//  Created by Guadoo on 2021/5/17.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var userScore = 0
    
    var body: some View {
        
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Your score is \(userScore)")
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                
            }
            .navigationTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startGame, label: {
                Text("New Game")
            }))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworn" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                userScore = 0
                usedWords.removeAll()
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        
        // If were are *here* then there was a problem - trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        // extra validation to come
        guard isOrignial(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up or use the same word, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word or shorter than three letters.")
            return
        }
        
        userScore += answer.count
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        
    }
    
    
    func isOrignial(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        if tempWord == word {
            return false
        } else {
            for letter in word {
                if let pos = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: pos)
                } else {
                    return false
                }
            }
            
            return true
        }
    }
    
    func isReal(word: String) -> Bool {
        
        if word.utf16.count >= 3 {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspelledRange.location == NSNotFound
        } else {
            return false
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
