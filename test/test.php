<?php

include_once 'vendor/autoload.php';


use Guzzle\Http\Client;

// Create a client and provide a base URL
$client = new Client('https://www.google.co.uk/');



for($j = 0; $j < 5; $j++) {

    $requests = array();

    for ($i = 0; $i < 10; $i++) {

        $request = $client->createRequest('GET', 'https://www.google.co.uk/');

        $requests[] = $request;


    }

    echo "Sending requests.\n";

    $client->send($requests);


    echo "Requests sent\n";

}

