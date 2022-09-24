#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:
read USERNAME

USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")
if [[ -z $USER ]]
then
 INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
 echo "Welcome, ${USERNAME// /}! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, ${USERNAME// /}! You have played ${GAMES_PLAYED// /} games, and your best game took ${BEST_GAME// /} guesses."
fi
echo "Guess the secret number between 1 and 1000:"

NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo $NUMBER

GUESS (){
read INPUT
if [[ ! $INPUT =~ ^[0-9]+$ ]]
then
 echo "That is not an integer, guess again:"
 GUESS
else
  if [[ $INPUT < $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    GUESSES=$(($GUESSES+1))
    GUESS
  elif [[ $INPUT > $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    GUESSES=$(($GUESSES+1))
    GUESS
  else
    echo "You guessed it in ${GUESSES// /} tries. The secret number was ${NUMBER// /}. Nice job!"
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    TOTAL=$(($GAMES_PLAYED+1))
    UPDATE_PLAYED=$($PSQL "UPDATE users SET games_played=$TOTAL WHERE username='$USERNAME';")
    if [[ -z $BEST_GAME || $BEST_GAME > $GUESSES ]]
    then
      UPDATE_BEST=$($PSQL "UPDATE users SET best_game='$GUESSES' WHERE username='$USERNAME';")
    fi
  fi
fi
} 

GUESSES=1
GUESS