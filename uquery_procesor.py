# -*- coding: utf-8 -*-
"""
Created on Sun Sep 03 14:27:07 2017


"""

import MySQLdb,requests
from flask import Flask, render_template,request
from credientials import host,passwd,user,db

app = Flask(__name__)
db = MySQLdb.connect(host,user,passwd,db)
cur = db.cursor()

@app.route("/result",methods=["POST"])
def result():

    source = request.form['source']
    destination = request.form['destination']
    print(source)
    print(destination)
    ids = intersect(source,destination);

    cur.execute("SELECT station_name FROM `station_info` WHERE station_id = '" + str(source) + "';")
    usr_loc = cur.fetchone()
    global stamp
    stamp = usr_loc[0]
    print(stamp)

    result = []
    for id in ids:
        cur.execute("SELECT * FROM `main` WHERE bus_id = '" + str(id) + "';")
        temp = cur.fetchone()
        temp = list(temp)
        data = wp_format(temp)
        result.append(data)
    print(result)

    return render_template('result_page.html', values=result)

def intersect(source,destination):
    cur.execute("SELECT allocated_buses FROM `station_info` WHERE station_id = '" + str(source) + "';")
    print("SELECT allocated_buses FROM `station_info` WHERE station_id = '" + str(source) + "';")
    a = cur.fetchone()  # get the specific one row value
    s_id = a[0].split(",")

    cur.execute("SELECT allocated_buses FROM `station_info` WHERE station_id = '" + str(destination) + "';")
    print("SELECT allocated_buses FROM `station_info` WHERE station_id = '" + str(destination) + "';")
    b = cur.fetchone()  # get the specific one row value
    d_id = b[0].split(",")

    final_id = set(s_id).intersection(d_id)                      # common_buses_between_stations
    return final_id

def wp_format(data):
    cur.execute("SELECT bus_no FROM `bus_info` WHERE bus_id = '" + str(data[0]) + "';")
    print("SELECT bus_no FROM `bus_info` WHERE bus_id = '" + str(data[0]) + "';")
    a = cur.fetchone()
    data.insert(1,a[0])

    cur.execute("SELECT station_name FROM `station_info` WHERE station_id = '" + str(data[2]) + "';")
    b = cur.fetchone()
    data[2] = b[0]
    print(data)

    ttime = travel_time(data[2],stamp)
    print(stamp)
    data.insert(4,ttime)
    print(data)

    return data

def travel_time(src,dest):
    r = requests.get("http://maps.googleapis.com/maps/api/distancematrix/json?origins={0}&destinations={1}&mode=driving&language=en-EN&sensor=false".format(str(src),str(dest)))
    json_result = r.text
    print(json_result)

    json_object = r.json()
    time = str(json_object["rows"][0]["elements"][0]["duration"]["text"])
    print(time)
    return time
    time = "28"
    return time

@app.route("/")
def index():
    return render_template('home.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8040, debug=True)

