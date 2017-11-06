require 'open-uri'
require 'json'

# We can call a method an Time.now
# Time is an object

class PagesController < ApplicationController
  # public methods associated to a route
  def game
    # 1. Generate a grid of 9 random letters
    # 2. Join the result array
    @grid = generate_grid(9).join(" ")
    # 3. Get the starting time on the game page
    @start_time = Time.now
  end

  # raise shows an error & brings a console
  def score
    # 1. Get start time from /game page (hidden input)
    @start_time = Time.parse(params[:start_time])
    # 2. Get end time from /score page
    @end_time = Time.now
    # 3. Get user's answer from form (input's name)
    @answer = params[:user_shot]
    # 4. Get the grid from form /game page (hidden input)
    @grid = params[:grid]
    # 5. Empty hash to store the result (time taken, score, is it an english word)
    result = {}
    # 6. Conditional - 3 differents cases
    # Case 1: If the word is an English word
    if english_word?(@answer)
      # Case 2: AND If the word matches letters in grid
      if matches?(@answer.upcase, @grid)
        result[:message] = "Well done"
        # score = length / time
        result[:score] = ((@answer.length / total_time(@start_time, @end_time)) * 1000).to_i
      else
        # Case 2-b: Does not match the grid
        result[:message] = "Not in the grid"
        result[:score] = 0
      end
      # Case 3: If the word is not an English word
      # (don't need to calculate a score)
    else
      result[:score] = 0
      result[:message] = "not an english word"
    end
    # 7. Call the method to calculate time taken
    result[:time] = total_time(@start_time, @end_time)
    # 8. Assign time, score, and message to var to display on the /score page
    @result_time = result[:time]
    @result_score = result[:score]
    @result_message = result[:message]
    return result # {time: 1.5, score: 10, messqge: "well done"}
  end

  private
  # PRIVATE METHODS help principal methods
  def generate_grid(grid_size)
    # TODO: generate random grid of letters, allows duplicate of letters
    # 1. Create new array of 9 elements
    # 2. In the range A to Z for each element of the array, take a sample
    # (so by default, it allows duplicates)
    grid = Array.new(grid_size) { ("A".."Z").to_a.sample }
    return grid
  end

  def matches?(attempt, grid)
    # TODO: check that the attempt matches the grid letters
    # 1. For an attempt, check each characters with .all?
    # 2. Compare the letters in attempt to equal up to max grid's letters
    attempt.chars.all? { |letter| attempt.count(letter) <= grid.count(letter) }
  end

  # check attempt is a real word : english_word? (API)
  def english_word?(word)
    # TODO: use API to check that an attempt is a real word
    # 1. Interpolate user's word in the url path
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    # 2. Read the content of url
    serialized_word = open(url).read
    # 3. parse JSON
    word = JSON.parse(serialized_word)
    # 4. Boolean (when you open the url, 1st key is :found : true/false)
    return word["found"]
  end

  def total_time(start_time, end_time)
    # TODO: find the time it took for answering
    # The calculation is : time new - time now
    total_time = end_time - start_time
    return total_time
  end
end
