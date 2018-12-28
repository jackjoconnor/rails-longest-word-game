require 'open-uri'
require 'time'

class GamesController < ApplicationController
  VOWELS = %w[A E I O U]
  CONSONANTS = (('A'..'Z').to_a - VOWELS)

  def new
    @letters = Array.new(5) { VOWELS.sample }

    @letters += Array.new(4) { CONSONANTS.sample }
    @letters.shuffle!

    @start_time = Time.now
  end

  def score
    @letters = params[:letters].split
    @attempt = params[:attempt].upcase

    @included = included?(@attempt, @letters)
    @english_word = english_word?(@attempt)

    @start = Time.parse(params[:start_time])
    @end = Time.parse(Time.now.to_s)
    @time = (@end - @start)
    @score = calculate_score(@attempt, @time)
  end

  private

  def included?(attempt, letters)
    attempt.chars.all? { |letter| attempt.count(letter) <= letters.count(letter) }
  end

  def english_word?(attempt)
    reponse_serialized = open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    json_hash = JSON.parse(reponse_serialized)
    return json_hash["found"]
  end

  def calculate_score(attempt, time_taken)
    time_taken > 30.0 ? 0 : (attempt.length * (1.0 - time_taken / 60.0)).round
  end
end
