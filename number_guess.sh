#!/bin/bash
PSQL="psql --username=freecodecamp -X --dbname=number_guess --tuples-only -c"

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=0

echo -e "Enter your username:"
read USER_NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")

if [[ -z $USER_ID ]]; then
  echo -e "\nWelcome, $USER_NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USER_NAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM game WHERE user_id='$USER_ID'")
  BEST_GAME=$($PSQL "SELECT MIN(best_game) FROM game WHERE user_id='$USER_ID'")
  echo -e "\nWelcome back, $(echo "$USER_NAME" | sed -r 's/^ *| *$//g')! You have played $(echo "$GAMES_PLAYED" | sed -r 's/^ *| *$//g') games, and your best game took $(echo "$BEST_GAME" | sed -r 's/^ *| *$//g') guesses."
fi

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi

  read USER_GUESS
  ((GUESS_COUNT++))

  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]; then
    MAIN_MENU "That is not an integer, guess again:"
  elif [[ $USER_GUESS =~ $SECRET_NUMBER ]]; then
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USER_NAME'")
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO game(user_id,best_game) VALUES($USER_ID,$GUESS_COUNT)")
    echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
  else
    while [ $USER_GUESS -ne $SECRET_NUMBER ]; do
      if [[ $USER_GUESS > $SECRET_NUMBER ]]; then
        MAIN_MENU "It's lower than that, guess again:"
      elif [[ $USER_GUESS < $SECRET_NUMBER ]]; then
        MAIN_MENU "It's higher than that, guess again:"
      fi
    done
  fi
}

MAIN_MENU
