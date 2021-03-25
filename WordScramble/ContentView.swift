//
//  ContentView.swift
//  WordScramble
//
//  Created by Sandra Quel on 2/17/21.
//

import SwiftUI
/*
 Add a left bar button item that calls startGame(), so users can restart with a new word whenever they want to.
 
 Disallow answers that are shorter than three letters or are just our start word. For the three-letter check, the easiest thing to do is put a check into isReal() that returns false if the word length is under three letters. For the second part, just compare the start word against their input word and return false if they are the same.
 */
struct ContentView: View {
    @State private var useWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var erroMessage = ""
    @State private var  showingError = false
    @State private var isLessThanThreeLetters = false
    @State private var userScore = 0

    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your work", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()

                List(useWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                    
                }
                
                Text("Score \(userScore)")
                
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading: Button(action: {
                startGame()
            }, label: {
                Text("Start Over")
            } ))
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError, content: {
                Alert(title: Text(errorTitle), message: Text(erroMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else {
            return
        }
        
        guard isDuplicate(word: answer) else {
            wordError(title: "Word already used", message: "Be more original")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Can't use the same root word", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word")
            return
        }
        useWords.insert(newWord, at: 0)
        calculateScore(answer.count)
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
//        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        guard answer.count > 0 else {
//            return 0
//        }
        
       // let wordScore = score

    func calculateScore(_ score: Int)  {
         userScore += score
    }
    func isDuplicate(word: String) -> Bool {
        !useWords.contains(word)
    }
    
    func isOriginal(word: String) -> Bool {
        let checkWord = rootWord
        if word.compare(checkWord, options: .caseInsensitive) == .orderedSame {
            return false
        } else {
            return true
        }
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
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
        let wordLength = word.utf16.count

        let range = NSRange(location: 0, length: wordLength)
        
        if wordLength < 3 {
            return  (NSNotFound != 0)
        }
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        erroMessage = message
        errorTitle = title
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
