## Trello archived cards

Ruby script that displays Trello cards archived within a given date range.

We use it to get an overview of the cards that we completed in the last week.

### Prerequisites

1. Get your Trello developer key

        # Copy the Key and store in an environment variable
        $ open "https://trello.com/1/appKey/generate"
        $ export TRELLO_KEY=<your-trello-key>

2. Generate an Application Token

        # Grant read-only access to the app, copy the Token and store in an environment variable
        $ open "https://trello.com/1/authorize?key=$TRELLO_KEY&name=gfr-trello-archived-cards&expiration=never&response_type=token&scope=read"
        $ export TRELLO_TOKEN=<your-trello-token>

### Usage

1. Get the ID of the board you're interested in

        $ open "https://trello.com"
        # Navigate to the board you want to backup and copy the board ID from the URL
        # The structure of the URL should be trello.com/b/<board-ID>/<board-name>

2. Execute:

        $ ruby list-archived-trello-cards.rb $TRELLO_KEY $TRELLO_TOKEN <trello-board-id> <date-from> <date-to>
