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

def indent(text, amount)
  text.gsub(/^(?!$)/, ' ' * amount)
end

board_actions.select { |a| a.type == 'commentCard' }.group_by { |a| a.data['card']['id'] }.each do |card_id, actions|
  card = Trello::Card.find(card_id)
  puts "* [#{card.name}](#{card.short_url})"
  actions.sort_by { |a| a.date }.each do |action|
    puts indent("* @#{action.member_creator.username} at #{action.date.strftime('%H:%M on %a, %d %b')}", 2)
    text = action.data['text']
    if text.lines.length > 10
      text = (text.lines[0..7] + ["\n", "... truncated ...\n", "\n", "[Full comment](#{card.short_url}#comment-#{action.id})\n"]).join
    end
    puts indent(text, 4)
    puts
  end
  puts
end
