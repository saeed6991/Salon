#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~ Services Salon ~~~~"

MAIN_MENU() {
  if [[ $1 ]] 
  then 
    echo -e "\n$1\n"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services;")
  echo "$SERVICES" | while read SERVICE BAR SERVICE_NAME
  do
    if [[ $SERVICE =~ ^[0-9]+$ ]] 
    then
      echo -e "$SERVICE) $SERVICE_NAME"
    fi
  done
  echo "4) Exit"
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in 
    1) TAKE_PHONE_NUMBER ;;
    2) TAKE_PHONE_NUMBER ;;
    3) TAKE_PHONE_NUMBER ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option..." ;;
  esac
}

TAKE_PHONE_NUMBER() {
  echo -e "\nPlease Enter your Phone Number:\n"
  read CUSTOMER_PHONE
  PHONE_EXISTS=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';") 
  PHONE_EXISTS_FORMATTED=$(echo $PHONE_EXISTS | sed -n 's/[^0-9]*\([0-9]\+\).*/\1/p')
  if [[ $PHONE_EXISTS_FORMATTED == 0 ]]
  then
    echo -e "\nYou're new by us, Please enter your name:\n"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    if [[ $INSERT_CUSTOMER_NAME == "INSERT 0 1" ]]
    then
      echo -e "\nName Successfully added!\n"
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | sed -n 's/[^0-9]*\([0-9]\+\).*/\1/p')
      BOOK_AN_APPOINTMENT
    fi
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/.*------ \(.*\) (.*/\1/')
    SHOW_APPOINTMENTS 
  fi
}

SHOW_APPOINTMENTS() {
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | sed -n 's/[^0-9]*\([0-9]\+\).*/\1/p')
  APPOINTMENTS=$($PSQL "SELECT services.name, appointments.time FROM appointments LEFT JOIN services USING(service_id) WHERE customer_id=$CUSTOMER_ID_FORMATTED;")
  echo -e "\nList of your Current Appointments:"
  echo "$APPOINTMENTS"
  BOOK_AN_APPOINTMENT
}

BOOK_AN_APPOINTMENT() {
  echo -e "\nPlease enter the desired time:\n"
  read SERVICE_TIME
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/.*------ \(.*\) (.*/\1/')
  BOOK_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_FORMATTED, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

EXIT() {
  echo "Exit successful!"
}

MAIN_MENU 
