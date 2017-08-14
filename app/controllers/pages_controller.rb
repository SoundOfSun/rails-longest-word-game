require 'open-uri'
require 'json'

# We can call a method an Time.now
# Time is an object

class PagesController < ApplicationController
  # public methods associated to a route
  def game
    @grid = generate_grid(9).join(" ")
    @start_time = Time.now

  end

  # raise shows an error & brings a console
  def score
    @end_time = Time.now
    @answer = params[:user_shot]
    @grid = params[:grid]
    @start_time = Time.parse(params[:start_time])
    result = {}
    if english_word?(@answer)
      if matches?(@answer.upcase, @grid)
        result[:message] = "Well done"
        # score = length / time
        result[:score] = ((@answer.length / total_time(@start_time, @end_time)) * 1000).to_i
      else
        result[:message] = "Not in the grid"
        result[:score] = 0
      end
    else
      result[:score] = 0
      result[:message] = "not an english word"
    end
    result[:time] = total_time(@start_time, @end_time)
    @result_time = result[:time]
    @result_score = result[:score]
    @result_message = result[:message]
    return result # {time: 1.5, score: 10, messqge: "well done"}
  end

  private
  # help principal methods
  # generate a random grid, allows duplicates of numbers
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = Array.new(grid_size) { ("A".."Z").to_a.sample }
    return grid
  end

  # check attemps matches the grid letters
  def matches?(attempt, grid)
    # condition booleans user_attempt and generated grid
    attempt.chars.all? { |letter| attempt.count(letter) <= grid.count(letter) }
  end

  # check attempt is a real word : english_word? (API)
  def english_word?(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    serialized_word = open(url).read
    word = JSON.parse(serialized_word)
    return word["found"] == true
    # boolean
  end

  # find the time it took for answering
  def total_time(start_time, end_time)
    # time new - time now
    total_time = end_time - start_time
    return total_time
  end
end
