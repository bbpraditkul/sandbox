#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import psycopg2
import sys
import psycopg2.extras #gives dictionary cursors
conn = None

try:
    conn = psycopg2.connect(database='testdb', user='testuser')
    #curs = conn.cursor() #Standard cursor where fields are returned as a column number
    curs = conn.cursor(cursor_factory=psycopg2.extras.DictCursor) # using the "extras" module, return the rows by column names

    curs.execute('select version()')
    ver = curs.fetchone()
    print (ver)

    #curs.execute("CREATE TABLE toys(id SERIAL PRIMARY KEY, name VARCHAR(20), price INT)")

    my_toys = { 'Tonka Truck': 50,
                'RC Car': 400,
                'Stuffed Animal': 4
                }

    #get existing rows
    curs.execute("SELECT * FROM toys")

    existing_toys = {}

    rows = curs.fetchall()

    for row in rows:
        existing_toys[row['name']] = row['price']

    for key,value in existing_toys.items():
        print ("already in db: %20s  price: %5d" % (key,value))

    print ("="*50)

    for key,value in sorted(my_toys.items()):
        if key in existing_toys.keys():
            if existing_toys[key] == value:
                print ("already in db: %20s  skipping..." % key)
            else:
                print ("updating price: %20s  price: %5d" % (key,value))
                curs.execute("UPDATE toys SET price = %s WHERE name = %s", (value,key))
        else:
            print ("inserting toy: %20s  price: %5d" % (key,value))
            curs.execute("INSERT INTO toys(name,price) VALUES (%s,%s)", (key,value))

    conn.commit()


except psycopg2.DatabaseError as e:
    if conn:
        conn.rollback()
    print ('Error %s' % e)
    sys.exit(1)

finally:
    if conn:
        conn.close()