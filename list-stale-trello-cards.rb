require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'

Dotenv.load

trello_api_key, trello_app_token = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')

trello_board_id = 'yTEJzPb8'

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

board = Trello::Board.find(trello_board_id)
open_cards = board.cards(filter: :open)

open_cards.sort_by do |card|
  card.last_activity_date
end.reverse.each do |card|
  puts "* #{card.last_activity_date} - [#{card.name}](#{card.short_url})"
end
