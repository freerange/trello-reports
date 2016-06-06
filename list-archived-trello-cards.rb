require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'

Dotenv.load

trello_api_key, trello_app_token = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')

trello_board_id, date_from, date_to = ARGV

date_from = Date.parse(date_from) rescue nil
date_to = Date.parse(date_to) rescue nil

unless trello_api_key && trello_app_token && trello_board_id && date_from && date_to
  puts "Usage: #{__FILE__} <trello-developer-token> <trello-application-token> <trello-board-id> <date-from> <date-to>"
  exit 1
end

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

board = Trello::Board.find(trello_board_id)
archived_cards = board.cards(filter: :closed)

archived_cards.sort_by do |card|
  card.last_activity_date
end.reverse.reject do |card|
  card.last_activity_date < date_from or
  card.last_activity_date > date_to
end.each do |card|
  puts "* #{card.last_activity_date} - [#{card.name}](#{card.short_url})"
end
