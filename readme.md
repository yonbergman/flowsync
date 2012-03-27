FlowSync
=======
A tool for syncing chat rooms across teams working together
-----

Flowdock is a great tool for keeping in sync on what's going on in your team,  
but we wanted to be able to chat across the entire company and still  
keep different flows with different data per team.  
That's what FlowSync does, it listens to all the flows (chat rooms) and publishes messages written in one room to all the others

Setup
----
Setup is really easy, setting up FlowSync is a two step process and then deploying to Heroku is easy as pie :)

###Step 1: Initial setup & getting the USERS hash
* Copy config.example.rb to config.rb
* Edit config.rb and fill the first three parameters
    * TOKEN with your token from the top of the [token page](https://www.flowdock.com/account/tokens)
    * ORGANIZATION with your organization name
    * FLOWS should be a lits of your flow names that you want to sync (we currently support only flows under the same org)
* Run 'foreman start'
* If you filled the details correctly you should see a post in the first flow containing an empty hash with all your flow's users

###Step 2: Fill all the users tokens
* Copy the USERS hash to the config.rb file
* Ask each user to go the [token page](https://www.flowdock.com/account/tokens) and send you his token.
* Make sure every person on the list has permissions to view and post in all the flows or it won't work
* You can remove people from the list and they won't be synced.
* run 'foreman start' again and it should start syncing the chat :)

###Step 3: Deploy to Heroku
Create a new Heroku project in the cedar stack and deploy the code as a worker

    heroku create --stack cedar
    git push heroku master
    heroku ps:scale worker=1
