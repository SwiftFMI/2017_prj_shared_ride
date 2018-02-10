// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');
// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
const express = require('express');
var cors = require('cors')

admin.initializeApp(functions.config().firebase);

const app = express();

// Automatically allow cross-origin requests
app.use(cors({ origin: true }));

// https://us-central1-shared-together.cloudfunctions.net/api/joinRide
app.post('/joinRide', (req, res) => {
  const rideId = req.body.rideId
  const rideOwnerId = req.body.rideOwnerId
  const joinUserId = req.body.joinUserId

  //TODO: handle empry fields

  const ownerUser = admin.database().ref(`/users/${rideOwnerId}`).once('value');
  const joiningUser = admin.database().ref(`/users/${joinUserId}`).once('value');
  const ride = admin.database().ref(`/rides/${rideId}`)

  Promise.all([ownerUser, joiningUser, ride]).then(results => {
    const ownerUser = results[0].val();
    const joinUser = results[1].val();
    const ride = results[2].val();

    //TODO: update ride

    const payload = {
        notification: {
            title: 'Join event',
            body: joinUser.name + ' has join your ride',
            icon: null
        }
    };

    // var ref = event.data.ref;
    // ref.update({
    //     "isVerified": true
    // });
    admin.messaging().sendToDevice(ownerUser.notificationsToken, payload)
        .then(function (response) {
            console.log("Successfully sent message:", response);
        })
        .catch(function (error) {
            console.log("Error sending message:", error);
        });
  });

  res.send("Widgets.create()")
});

app.post('/leaveRide', (req, res) => {
  const rideId = req.body.rideId
  const rideOwnerId = req.body.rideOwnerId
  const leaveUserId = req.body.joinUserId

  //TODO: handle empry fields

  const ownerUser = admin.database().ref(`/users/${rideOwnerId}`).once('value');
  const leaveUser = admin.database().ref(`/users/${leaveUserId}`).once('value');
  const ride = admin.database().ref(`/rides/${rideId}`)

});

// Expose Express API as a single Cloud Function:
exports.api = functions.https.onRequest(app);

exports.chatNotifications = functions.database.ref('/rideGroups/{groupId}/messages')
    .onWrite(event => {
//       // Only edit data when it is first created.
//       if (event.data.previous.exists()) {
//         return null;
//       }
//       // Exit when the data is deleted.
//       if (!event.data.exists()) {
//         return null;
//       }
//       // Grab the current value of what was written to the Realtime Database.
//       const original = event.data.val();
//       console.log('Uppercasing', event.params.pushId, original);
//       const uppercase = original.toUpperCase();
//       // You must return a Promise when performing asynchronous tasks inside a Functions such as
//       // writing to the Firebase Realtime Database.
//       // Setting an "uppercase" sibling in the Realtime Database returns a Promise.
//       return event.data.ref.parent.child('uppercase').set(uppercase);
// index.js

});
