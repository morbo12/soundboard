const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = 3000;
// Initialize an index counter
let currentIndex = 0;

// Middleware to log IP and request URI to the console
app.use((req, res, next) => {
  console.log(`Client IP: ${req.ip}, Request URI: ${req.originalUrl}`);
  next();
});
const matchFilePath  = path.join(__dirname, 'resources', '1364829.json');
const eventsFilePath = path.join(__dirname, 'resources', 'events.json');

// Read the match data from 1364829.json
const matchRawData = fs.readFileSync(matchFilePath);
const matchData = JSON.parse(matchRawData);

// Read the events data from events.json
const eventsRawData = fs.readFileSync(eventsFilePath);
const eventsData = JSON.parse(eventsRawData);

app.get('/v2/api/matches/1364829', (req, res) => {
  console.log('Event Lenght: ', eventsData.Events.length)
  matchData.Events = Array.isArray(matchData.Events) ? matchData.Events : [];

  // Append one item at a time from events.json to the Events array
  if (currentIndex < eventsData.Events.length) {
    // matchData.Events = [...matchData.Events, eventsData[currentIndex]];

    // Create a new object with modified Events array
    matchData.Events = [...matchData.Events, eventsData.Events[currentIndex]];

    // Increment the index for the next request
    currentIndex++;
    console.log("currentIndex:", currentIndex)
    // Send the modified data to the browser
    res.json(matchData);
  } else {
    currentIndex = 0;
    matchData.Events = [];

    // If all items from events.json are appended, send a message or handle accordingly
    res.json({ message: 'All events appended.' });
    console.log("currentIndex:", currentIndex)
  }
});

app.get('/StatsAppApi/api/startkit', (req, res) => {
    // Read the JSON file
    const filePath = path.join(__dirname, 'resources', 'WebStartKit.json');
    const rawdata = fs.readFileSync(filePath, 'utf8');
    const startkit = JSON.parse(rawdata);

    // Modify the 'Events' array based on the current timestamp
    const timestamp = new Date(Date.now() + 2 * 60 * 1000).toISOString();
    
startkit.accessTokenExpiration=timestamp;
    // Send the modified JSON as the response
    res.json(startkit);

});

app.get('/v2/api/seasons/', (req, res) => {
  // Send the "resources/seasons" file as the response
  const seasonsPath = path.join(__dirname, 'resources', 'seasons.json');
  res.sendFile(seasonsPath);
});

app.get('/v2/api/seasons/41/venues/3455/matches', (req, res) => {
  // Send the "resources/seasons" file as the response
  const seasonsPath = path.join(__dirname, 'resources', 'matches.json');
  res.sendFile(seasonsPath);
});
app.get('v2/api/matches/1364829/lineups', (req, res) => {
  // Send the "resources/seasons" file as the response
  const seasonsPath = path.join(__dirname, 'resources', 'lineups.json');
  res.sendFile(seasonsPath);
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
