#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo -e "Enter your username:"
read USERNAME_INPUT

USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$USERNAME_INPUT'")

if [[ -z $USER_INFO ]]
then

  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."

else

  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE username='$USERNAME_INPUT'")
  BEST_GAME_TRIES=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE username='$USERNAME_INPUT'") 
  echo "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_TRIES guesses."

fi

echo "Guess the secret number between 1 and 1000:"
read GUESS_INPUT

TRIES=1
while true; do
  if [[ $GUESS_INPUT =~ ^[0-9]+$ ]] #if input is an integer, continue
  then
    if [[ $GUESS_INPUT -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS_INPUT
      TRIES=$(( $TRIES+1 ))
    else
      if [[ $GUESS_INPUT -lt $NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS_INPUT
        TRIES=$(( $TRIES+1 ))
      else
        
        echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
        INSERT_GAME_INFO=$($PSQL "INSERT INTO games(number_of_guesses, username) VALUES($TRIES, '$USERNAME_INPUT')")
        break
      fi
    fi
  else    
    echo "That is not an integer, guess again:"
    read GUESS_INPUT
  fi
done