#! /bin/bash

source .env;

PSQL="psql --username=$POSTGRES_USERNAME --dbname=$POSTGRES_DATABASE --no-align --tuples-only -c"

statement="
  SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
  FROM elements as e
  JOIN properties as p
  ON e.atomic_number = p.atomic_number
  JOIN types as t
  ON p.type_id = t.type_id
"

if [ -z "$1" ]; then
  echo "Please provide an element as an argument.";
  exit 0;
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then

  statement="
  ${statement}

  WHERE
    e.symbol = '$1'
  OR 
    e.name = '$1'
  ";

else

  statement="
  ${statement}
  
  WHERE
    e.atomic_number = $1
  "

fi

db_element="$($PSQL"${statement};")";

if [ -z "$db_element" ]; then
  echo "I could not find that element in the database.";
  exit 0;
fi


IFS='|' 
# Read the data into variables 
read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< "$db_element";

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius.";
