#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE TABLE games, teams;"

tail -n +2 games.csv | while IFS=, read year round winner opponent w_goals o_goals
do
  $PSQL "INSERT INTO teams(name) VALUES('$winner') ON CONFLICT(name) DO NOTHING;"
  $PSQL "INSERT INTO teams(name) VALUES('$opponent') ON CONFLICT(name) DO NOTHING;"
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $w_goals, $o_goals);"
done
