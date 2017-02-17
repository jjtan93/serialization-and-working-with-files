require 'yaml'

class Hangman
  def initialize
    # An array that holds all possible dictionary words
    @dictionary_array = []
    @secret_word = []
    # The word that is displayed to the user to be guessed
    # Blanks are replaced with the correct letter upon a correct guess
    @word_display = []
    # An array that holds all wrong letter guesses
    @wrong_guesses = []
    @guesses_left = -1
    @input = ""
    @game_over = false
  end
  
  def loadAndSelectWord
    @dictionary_array = File.readlines "5desk.txt"
    
    # Remove the newline character and downcase all dictionary words
    @dictionary_array.each do |word|
      word.strip!
      word.downcase!
    end
    
    # Select words that are between 5 and 12 chars long
    temp_array = @dictionary_array.select {|word| word.length >= 5 && word.length <= 12}
    temp_secret_word = temp_array.sample
    temp_secret_word.each_char {|letter| @secret_word << letter}
    @guesses_left = @secret_word.length
    
    (0..(@secret_word.length - 1)).each do
      @word_display << "_"
    end
    
    # Print the secret word for convenience purposes
    print "DISPLAY SECRET WORD: "
    @secret_word.each do |letter|
      print letter
    end
    puts ""
  end
  
  def prompt
    puts "Please choose: \n(a) Enter guess \n(b) Save game"
    choice = gets.chomp
    
    if(choice == "a")
      # Display the current state of the guessed secret word
      @word_display.each do |letter|
        print letter
      end
      puts " (#{@secret_word.length} letters)\n#{@guesses_left} incorrect guesses left."
      # TODO add previous wrong guesses here
      print "Previous wrong guesses: "
      @wrong_guesses.each do |letter|
        print "#{letter} "
      end
      print "\nPlease enter your letter guess: "
      @input = gets.chomp
      checkGuess
    elsif(choice == "b")
      puts ">>> Game state saved! <<<"
      saveGameState
    end
  end
  
  # Checks to see if the input/guess given is a match for any of the letters in the secret word
  def checkGuess
    # A repeated correct guess
    if(@word_display.include? @input)
      puts ">>> You have already guessed '#{@input}' correctly!"
      return
    # Correct guess
    elsif(!@word_display.include?(@input) && @secret_word.include?(@input))
      puts ">>> Correct guess!"
      @secret_word.each_with_index do |letter, index|
        @word_display[index] = @input if(@secret_word[index] == @input)
      end
    # Wrong guess
    else
      puts ">>> Wrong guess!"
      # TODO add to wrong guesses array
      @wrong_guesses << @input if(!@wrong_guesses.include? @input)
      @guesses_left -= 1
    end
  end
  
  def gameOver?
    match_count = 0
    
    if(@guesses_left == 0)
      @game_over = true
    else
      @secret_word.each_with_index do |letter, index|
        match_count += 1 if(letter == @word_display[index])
      end
      @game_over = true if(match_count == @secret_word.length)
    end
  end
  
  def saveGameState 
    File.open("save_state.yaml", "w") do |file|
      file.write(self.to_yaml)
    end
  end
  
  def loadGameState
    unless File.exists?("save_state.yaml")
      File.new("save_state.yaml", "w+")
    end
    loaded_data = YAML.load_file("save_state.yaml")
    
    # Not DRY!!!
    @secret_word = loaded_data.instance_variable_get(:@secret_word)
    @word_display = loaded_data.instance_variable_get(:@word_display)
    @wrong_guesses = loaded_data.instance_variable_get(:@wrong_guesses)
    @guesses_left = loaded_data.instance_variable_get(:@guesses_left)
    @game_over = loaded_data.instance_variable_get(:@game_over)
    @input = loaded_data.instance_variable_get(:@input)
    puts "New secret word: #{@secret_word}"
  end
  
  public
  
  def run
    puts "Please choose: \n(a) Start new game \n(b) Load a previously saved game"
    choice = gets.chomp
    
    if(choice == "a")
      loadAndSelectWord
    elsif(choice == "b")
      loadGameState
    end
    
    while(!@game_over && @guesses_left != 0)
      prompt
      gameOver?
      puts ""
    end
    
    puts ">>>>> You won! <<<<<" if(@guesses_left != 0)
    puts ">>>>> Game over! <<<<<" if(@guesses_left == 0)
    
  end
end

hm = Hangman.new
hm.run