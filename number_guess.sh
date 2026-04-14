#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --quiet -t --no-align -c"

# initialize DB and table if not exists
psql --username=freecodecamp --dbname=postgres --quiet -t --no-align -c "SELECT 1 FROM pg_database WHERE datname='number_guess'" | grep -q 1 || psql --username=freecodecamp --dbname=postgres --quiet -c "CREATE DATABASE number_guess"

$PSQL "SET client_min_messages TO WARNING; CREATE TABLE IF NOT EXISTS users (username VARCHAR(22) PRIMARY KEY, games_played INT NOT NULL DEFAULT 0, best_game INT)"

echo "Enter your username:"
read USERNAME

USER_DATA=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_DATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 0, NULL)"
  GAMES_PLAYED=0
  BEST_GAME=0
else
  GAMES_PLAYED=$(echo "$USER_DATA" | cut -d'|' -f1)
  BEST_GAME=$(echo "$USER_DATA" | cut -d'|' -f2)
  if [[ -z $BEST_GAME ]]; then
    BEST_GAME=0
  fi
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  if ! read GUESS; then
    # end of input stream when non-interactive runner finishes
    exit 0
  fi

  if ! [[ $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((GUESS_COUNT++))

  if (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
    continue
  elif (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
    continue
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi

done

NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ $BEST_GAME -eq 0 ]]; then
  NEW_BEST=$GUESS_COUNT
else
  if (( GUESS_COUNT < BEST_GAME )); then
    NEW_BEST=$GUESS_COUNT
  else
    NEW_BEST=$BEST_GAME
  fi
fi

$PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED, best_game=$NEW_BEST WHERE username='$USERNAME'"