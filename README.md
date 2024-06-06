## About This Project

This is a poker project. The milestone documents are in the `milestones` folder

## How to run the frontend

Go into the `frontend` folder, and run `npm start`

## How to run the API

From the pyflask directory, run `flask --app __init__ run` (make sure you have Flask installed). If this doesn't work, you can also try `python -m flask --app __init__ run`.

## How to set up the Mysql database

There is a file `sql/init_db.sql`. You can run this file to set up the poker database. 

You will need to ensure there exists a mysql user `poker_admin`, with password `poker`.

## How to run the Tests

After running flask, open a new terminal, go into pyflask directory and run `pytest`
