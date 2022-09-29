# frozen_string_literal: false

# show intro, outro, and manage the whole game
class Hangman
  attr_reader :answer, :player
  attr_accessor :input, :input_history, :choices, :life, :teaser, :game_end

  def initialize(dictionary)
    @player = Player.new
    @input = ''
    @input_history = []
    @choices = ('a'..'z').to_a
    @answer = dictionary.random_word.split('')
    @teaser = Array.new(answer.length, '_')
    @life = 6
    @game_end = false
  end

  def run
    intro
    process_turn
  end

  def intro
    puts 'Please enter a character.'
  end

  def process_turn
    until game_end
      prompt
      input = player.choose_char

      unless valid_input?(input)
        puts 'Invalid input, please try again.'
        process_turn
      end

      choices.delete(input)
      input_history << input
      answer.include?(input) ? update_teaser(input) : reduce_life
      check_outcome
    end

    outro
  end

  def prompt
    puts "\n\n"
    puts "Input history: #{input_history}"
    puts ''
    puts "Remaining life: #{life}."
    puts ''
    p teaser
    puts "\n\n"
  end

  def update_teaser(input)
    answer.each_with_index { |char, i| teaser[i] = input if char == input } 
  end

  def reduce_life
    @life -= 1
  end

  def valid_input?(input)
    input.downcase!
    input.length == 1 && choices.include?(input)
  end

  def check_outcome
    @game_end = true if life.zero? || teaser == answer
  end

  def outro
    if life.zero?
      puts "The answer is #{answer}."
      puts 'Better luck next time.'
    else
      puts 'Congratulations, you win the game.'
    end

    # start a new game?
  end
end

# Load from given file and choose a random suitable secret word
class Dictionary
  attr_reader :file

  def initialize(path)
    @file = File.new(path, 'r')
  end

  def random_word
    suitable_words.sample
  end

  def suitable_words
    file_data_arr.select { |word| word.length.between?(5, 12) }
  end

  def file_data_arr
    file.read.split
  end
end

# Could choose a character
class Player
  def choose_char
    gets.chomp
  end
end

dictionary = Dictionary.new('./asset/google-10000-english-no-swears.txt')
hangman = Hangman.new(dictionary)
hangman.run
