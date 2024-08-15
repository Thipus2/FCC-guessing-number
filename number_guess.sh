#!/bin/bash

NUMBER_TO_FIND=$((1 + $RANDOM % 1000))
echo $NUMBER_TO_FIND
GUESS_NUMBER=0
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#echo $($PSQL "TRUNCATE users")
SHOW_START(){
echo "Enter your username:"
read USERNAME
TEST_NAME
PLAY
}
TEST_NAME(){
if [[ -z $USERNAME ]]
then
echo "Empty is not a username"
SHOW_START
else
USERNAME_LENGTH=$((${#USERNAME}))
  if (( $USERNAME_LENGTH > 22 ))
  then
  echo "Username too long."
  SHOW_START
  else
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
    if [[ -z $USER_ID ]]
    then
    NEW='OUI';
    INSERT_NAME_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    fi
  export USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  export USERNAME=$($PSQL "SELECT name FROM users WHERE user_id=$USER_ID")
  export GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  export BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
    if [[ $NEW = 'OUI' ]]
    then  
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi

  fi
fi
}
PLAY(){
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  SOLVE_PLAY
}

SOLVE_PLAY(){
  if [[ $GUESS =~ ^[0-9]+$  ]]
  then
    GUESS_NUMBER=$(($GUESS_NUMBER+1))
    if [[ $GUESS -eq $NUMBER_TO_FIND ]]
    then
    echo "You guessed it in $GUESS_NUMBER tries. The secret number was $NUMBER_TO_FIND. Nice job!"
    GAMES_PLAYED=$(($GAMES_PLAYED+1))
    INSERT_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE name='$USERNAME'")  
      if (($GUESS_NUMBER > $BEST_GAME && $BEST_GAME != 0))
      then
      exit 0
      else
      INSERT_GAMES_PLAYED=$($PSQL "UPDATE users SET best_game=$GUESS_NUMBER WHERE name='$USERNAME'")
      exit 0
      fi
    else
      if [[ $GUESS -gt $NUMBER_TO_FIND ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
        SOLVE_PLAY
      fi
      if [[ $GUESS -lt $NUMBER_TO_FIND ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS
        SOLVE_PLAY
      fi
    fi
  else
  echo "That is not an integer, guess again:"
  PLAY
  fi
}

SHOW_START