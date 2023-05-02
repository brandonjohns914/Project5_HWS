//
//  ViewController.swift
//  Project5
//
//  Created by Brandon Johns on 4/24/23.
//

import UIKit

class ViewController: UITableViewController {
    
    var all_words: [String] = []
    var used_words: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(prompt_for_answer))
        
        if let start_words_URL = Bundle.main.url(forResource: "start" , withExtension: "txt")
        {
            if let start_words = try? String(contentsOf: start_words_URL)
            {
                all_words = start_words.components(separatedBy: "\n")
            }
        }
        
        if all_words.isEmpty                                    // if all words are empty fill it with Warriors
        {
            all_words = ["Warriors"]
        }
        
        start_game()
    }

    func start_game()
    {
        title = all_words.randomElement()                    // sets view controllers title to random word
        used_words.removeAll(keepingCapacity: true)                 // removes all values from used words array which used to store players answers
                                                                    // new word comes up removes previous guesses
        
        tableView.reloadData()                                      //reloads everything rows sections
    }
    
    // number of rows == number of user found words
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return used_words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
                                                                    // "Word" = reusable identify of the cells in storyboard
        
        cell.textLabel?.text = used_words[indexPath.row]            // used_words array is filled with all found words form the user thus far
        
        return cell
    }
    
    @objc func prompt_for_answer()                                  // called in navigation time right button
    {
        let alert_controller = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        alert_controller.addTextField()                             // adds text box to alert
                                                                    // where user types in their answers in the alert controller
        
            
        let submit_action = UIAlertAction(title: "Submit", style: .default)
        {
            [weak self, weak alert_controller] action in            // this is the input in the closure
                                                                    // in divides the closure into 2
                                                                    // before the in are the parameters coming into the closure
                                                                    // after the in what to do when the code is ran
            guard let answer = alert_controller?.textFields?[0].text else {return}
                                                                    // alert_controller?.textFields?[0].text tries to read out the value typed
            
            self?.submit(answer)                                    // checks if still there before closing the closure
        }
        
        alert_controller.addAction(submit_action)
        present(alert_controller, animated: true)                   // present puts it on the screen
    }
    
    func submit (_ answer: String)
    {
        let lower_answer = answer.lowercased()                      // forces all letters lower case
        
        let error_title: String
        let error_message: String
        
        if is_possible(word: lower_answer)
        {
            if is_original(word: lower_answer)
            {
                if is_real(word: lower_answer)
                {
                    used_words.insert(answer, at: 0)                // insert words
                                                                    // first postion in array and top of table view
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                                                                    // new row at certain spot in the array
                                                                    // .automatic reloads itself
                    
                    return                                          // all conductions pass this return allows it continue
                }
                else
                {
                    error_title = "Word not recognized"
                    error_message = "you cannot make up words "
                }
            }
            else
            {
                error_title = "word already used"
                error_message = "be more original"
            }
        }
        else
        {
            guard let title = title else { return}
            error_title = "word not possible"
            error_message = "word cannot be spelled using \(title.lowercased())"
        }
        
        let alert_controller = UIAlertController(title: error_title, message: error_message, preferredStyle: .alert)
        alert_controller.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert_controller, animated:  true)
    }
    
    func is_possible(word: String) -> Bool
    {
        guard var temp_word = title?.lowercased() else { return false }
        
        for letter in word                                          // loop over all letters in word
        {
            if let position = temp_word.firstIndex(of: letter)      // checks the first letter within the word moving down through the word
            {
                temp_word.remove(at: position)                      // removes the found letter from the temp word
            }
            else                                                    // cannot find the letter returns false
            {
                return false
            }
        }
        
        return true                                                 // all letters have been found and removed return true
    }
    
    func is_original(word: String) -> Bool
    {
        return !used_words.contains(word)
                                                                    // used word has word in return false because the word is not orginial
    }
    
    func is_real(word: String) -> Bool
    {
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count) // range of word to scan starting at 0
                                                                   // word.utf16.count for character count
        
        let misspelled_range = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
                                                                   // in: word = string to scan
                                                                   // range: range = how much of the word to scan
                                                                   // wrap: false = should not start at beginning of range if no misspelled words are found
                                                                   // en = english word
        if misspelled_range.location == NSNotFound
        {                                                         // NSNotFound = word is spelled right
                                                                  // returns where the misspelling
            return true
        }
        else
        {
            return false
        }
                                                                
    }
    
    
}

