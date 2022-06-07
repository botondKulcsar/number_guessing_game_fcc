#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(($RANDOM % 1000 + 1))
#echo $SECRET_NUMBER

#prompt for username
echo "Enter your username:"
read USERNAME

#check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
#echo "user_id: $USER_ID"

#if user does not exist
if [[  -z $USER_ID  ]]
  then
  #create new user
  CREATE_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

  #get user_id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  #get username
  #USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID")
  #greet user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  #get username
  USERNAME=$($PSQL "SELECT username FROM users WHERE user_id=$USER_ID")

  #calculate GAMES_PLAYED
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  #echo "games_played: $GAMES_PLAYES"
  #calculate BEST_GAME guesses
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  #echo "best_game: $BEST_GAME"

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#prompt for guessing the secret number
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

while  [[ $GUESS != $SECRET_NUMBER ]]
do
  #check if input is an integer
  if [[ $GUESS =~ ^[0-9]+$  ]]
    then
    if [[ $SECRET_NUMBER < $GUESS ]]
      then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi

  read GUESS
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES + 1))
done

#insert into games
INSERT_INTO_GAMES_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
