require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'

Dotenv.load

trello_api_key, trello_app_token = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')

trello_board_id, number_of_weeks_until_considered_stale = ARGV

unless trello_api_key && trello_app_token && trello_board_id && number_of_weeks_until_considered_stale
  puts "Usage: TRELLO_KEY=<trello-api-key> TRELLO_TOKEN=<trello-token> #{__FILE__} <trello-board-id> <number-of-weeks-until-considered-stale>"
  exit 1
end

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

date_before_which_considered_stale = Date.today - (number_of_weeks_until_considered_stale.to_i * 7)

board = Trello::Board.find(trello_board_id)
open_cards = board.cards(filter: :open)

open_cards.sort_by do |card|
  card.last_activity_date
end.reverse.select do |card|
  card.last_activity_date < date_before_which_considered_stale
end.each do |card|
  puts "* #{card.last_activity_date} - [#{card.name}](#{card.short_url})"
end
