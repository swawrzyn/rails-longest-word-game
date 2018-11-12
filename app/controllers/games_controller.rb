require 'json'
require 'open-uri'
require 'time'

class GamesController < ApplicationController
  def new
    @letters = Array.new(10) { ('A'..'Z').to_a.sample }
    @start_time = Time.now
    session[:scores] ||= []
  end

  def score
    @word = params['word']
    url = open("https://wagon-dictionary.herokuapp.com/#{@word.downcase}").read
    @letters = params['letters'].split
    @total_time = (Time.now - Time.parse(params['start_time'])).round(2)
    @score = 0

    def canBuild?(letters, guess)
      letter_hash = Hash.new(0)
      letters.each { |letter| letter_hash[letter.to_sym] += 1 }
      guess.upcase.split('').each { |guess_letter| letter_hash[guess_letter.to_sym] -= 1 }
      letter_hash.none? { |_key, value| value.negative? }
    end

    @real_word = JSON.parse(url)['found']
    @can_build = canBuild?(@letters, @word)
    @score = (((@word.length**2) * (1 / @total_time)) * 100).floor if @real_word && @can_build

    session[:scores].unshift(@score)
    @scores = session[:scores].sort.reverse
  end
end
