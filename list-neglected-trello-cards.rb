require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'

Dotenv.load

trello_api_key, trello_app_token = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')

trello_board_id, number_of_weeks_until_considered_neglected = ARGV

unless trello_api_key && trello_app_token && trello_board_id && number_of_weeks_until_considered_neglected
  puts "Usage: TRELLO_KEY=<trello-api-key> TRELLO_TOKEN=<trello-token> #{__FILE__} <trello-board-id> <number-of-weeks-until-considered-neglected>"
  exit 1
end

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

date_before_which_considered_neglected = Date.today - (number_of_weeks_until_considered_neglected.to_i * 7)

board = Trello::Board.find(trello_board_id)
open_cards = board.cards(filter: :open)

class Trello::Card
  def latest_comment
    comments.sort_by { |comment| comment.date }.last
  end
  def date_of_latest_comment
    latest_comment && latest_comment.date
  end
  def date_of_most_recent_interesting_activity
    [created_at, date_of_latest_comment].compact.max
  end
  def neglected_since?(date)
    date_of_most_recent_interesting_activity < date
  end
end

open_cards.select do |card|
  card.neglected_since?(date_before_which_considered_neglected)
end.sort_by do |card|
  card.date_of_most_recent_interesting_activity
end.each do |card|
  puts "* #{card.date_of_most_recent_interesting_activity} - [#{card.name}](#{card.short_url})"
end
