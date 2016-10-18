## Trello Reports

Ruby scripts for generating reports for a Trello board.

We created these scripts to help us work out which cards we've finished or worked on in a given week to help us write the week notes.

### Prerequisites

1. Get your Trello developer key

        # Copy the Key and store in an environment variable
        $ open "https://trello.com/1/appKey/generate"
        $ export TRELLO_KEY=<your-trello-key>

2. Generate an Application Token

        # Grant read-only access to the app, copy the Token and store in an environment variable
        $ open "https://trello.com/1/authorize?key=$TRELLO_KEY&name=gfr-trello-archived-cards&expiration=never&response_type=token&scope=read"
        $ export TRELLO_TOKEN=<your-trello-token>

To avoid having to set these every time, you can store these environment variables in a `.env` file:

    TRELLO_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    TRELLO_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

### Usage

1. Get the ID of the board you're interested in

        $ open "https://trello.com"
        # Navigate to the board you want to backup and copy the board ID from the URL
        # The structure of the URL should be trello.com/b/<board-ID>/<board-name>

2. Listing archived cards:

This will list all archived cards that have had some activity between <date-from> and <date-to>.

        $ ruby list-archived-trello-cards.rb <trello-board-id> <date-from> <date-to>

3. Listing all cards with activity within the date range:

        $ ruby list-trello-cards-with-activity.rb <trello-board-id> <date-from> <date-to>
