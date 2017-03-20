require 'bundler/setup'
require 'trello'
require 'date'
require 'dotenv'
require 'json'

DONE_LIST_ID = "57ff9e77264fa210d79a2651"

Dotenv.load

trello_api_key, trello_app_token = ENV.fetch('TRELLO_KEY'), ENV.fetch('TRELLO_TOKEN')

trello_board_id, date_from, date_to = ARGV

date_from = Date.parse(date_from) rescue nil
date_to = Date.parse(date_to) rescue nil

if date_to.nil?
  date_to = Date.today
end

if date_from.nil?
  date_from = date_to - 7
end

unless trello_api_key && trello_app_token && trello_board_id && date_from && date_to
  puts "Usage: TRELLO_KEY=<trello-key> TRELLO_TOKEN=<trello-token> #{__FILE__} <trello-board-id> <date-from> <date-to>"
  exit 1
end

puts "Trello Items Completed between #{date_from} to #{date_to} (inclusive):"

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

card_actions = board_actions.reject {|a| a.data['card'].nil? }.select {|a| a.type == 'updateCard' }.reject {|a| a.data['listAfter'].nil?}.select {|a| a.data['listAfter']['name'] == 'Done'}

card_actions.each do |a|
  puts "#{a.date.to_date} #{a.data['card']['name']}"
end
