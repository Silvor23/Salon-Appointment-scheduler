#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#Welcome Window
WELCOME(){
  #if there is argument with call:
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi
  #Title
  echo -e "\n~~~~~ Welcome To Silver Touch Salon ~~~~~\n"
  #Offer to Choose
  echo -e "\nHere are our services please choose one:\n"
  #List of Services
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
    do
      echo -e "$SERVICE_ID) $SERVICE\n"
    done
  #Get service number
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED ]]
    then
      GET_APPOINTMENT "$SERVICE_ID_SELECTED"
  fi
}
GET_APPOINTMENT(){
  #Get Service's name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1")
  #In case its not a number:
  if [[ ! $1 =~ ^[0-9]+$ ]]
    then
      # send to welcome
      WELCOME "That is not a valid service number!!!."
      #In case its not from the list:
    elif [[ -z $SERVICE_NAME ]]
      then
        # send to welcome
        WELCOME "That is not a valid service number!!!."
    else
      # Ask for phone number
      echo -e "\nCould you please enter your phone number:"
      read CUSTOMER_PHONE
      # Get customer name if its regestired
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #if customer didnt exist:
      if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME
          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
      # now i have phone number, name and service we need date:
      echo -e "\nHi $CUSTOMER_NAME, Enter time using hh:mm style with 24 hours standart"
      read SERVICE_TIME
      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #Add appointment:
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$1', '$SERVICE_TIME')")
      #Conclusion message:
      echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
WELCOME