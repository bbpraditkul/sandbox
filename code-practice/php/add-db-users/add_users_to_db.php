<?php

#assumptions:
#1 json format: {"name":"","id":0,"value":"","timestamp":""}
#2 id and name are unique
#3 need the following cronjob to run every minute
# * * * * * /usr/local/bin/php add_users_to_db.php http://devopsdemo.dev.<domain>/users > /dev/null 2>&1 

#JSON formatted data structure of:
# name, id, value(attribute), and timestamp
#$users_list = <<<EOF
#[
#  {"name":"Foobar","id":0,"value":"blah","timestamp":"2013-06-01"},
#  {"name":"F","id":9,"value":"blah","timestamp":"2013-06-01"}
#]
#EOF;
$users_list = file_get_contents($_SERVER['argv'][1]);

$dbconn=mysqli_connect("localhost","devops","devops","usersdb");
if (mysqli_connect_errno()) {
    echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

#convert JSON to an easier to manage php data structure
$decoded = json_decode($users_list, true);

#dereference the data into simple associative array
foreach ($decoded as $val) {
    $user["name"] 	= print_r($val["name"], true);
    $user["id"] 	= print_r($val["id"], true);
    $user["value"] 	= print_r($val["value"], true);
    $user["timestamp"] 	= print_r($val["timestamp"], true);

    #crude error check -- skip if name/id are invalid
    if ($user["name"] == "" OR ($user["id"] == "")) {
        continue;
    }

    #debug -- check our new objects
    print_r($user);

    #add the objects into a db table
    mysqli_query($dbconn,"INSERT INTO my_users (name, id, value, timestamp) VALUES (\"$user[name]\",\"$user[id]\",\"$user[value]\",\"$user[timestamp]\")");

}

mysqli_close($dbconn);

?>
