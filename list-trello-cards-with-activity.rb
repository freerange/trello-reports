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
  puts "Usage: TRELLO_KEY=<trello-key> TRELLO_TOKEN=<trello-token> #{__FILE__} <trello-board-id> <date-from> <date-to>"
  exit 1
end

# Add 1 day to the end date so that activity on the end date is also included in
# the search results.
date_to = date_to + 1

Trello.configure do |config|
  config.developer_public_key = trello_api_key
  config.member_token = trello_app_token
end

board = Trello::Board.find(trello_board_id)

action_options = {
  since: date_from.to_s,
  before: date_to.to_s,
  limit: 1000 # 1000 is the maximum we can request
}
board_actions = board.actions(action_options)

if board_actions.count == 1000
  message =<<-EOM
We've reached the maximum number of actions for this date range.
The list of cards displayed is probably not exhaustive.
EOM
  warn message
end

# I initially tried calling `Action#card` for each action but it takes a very
# long time. Presumably because it's making a request to the Trello API for each
# card. Collecting the card ID from the `data` hash and then using that to find
# the cards is much quicker.
card_ids = board_actions.reject { |a| a.data['card'].nil? }.reject { |a| a.type == 'deleteCard' }.map { |a| a.data['card']['id'] }.uniq

cards = card_ids.map do |card_id|
  Trello::Card.find(card_id)
end

cards.each do |card|
  puts "* [#{card.name}](#{card.short_url})"
end
