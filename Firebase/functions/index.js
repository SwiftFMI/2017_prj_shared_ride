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
  const rideChatId = req.body.rideChatId

  if(!rideId){
    return res.status(400).json({ message: 'RideId must not be empty' })
  }

  if(!rideOwnerId){
    return res.status(400).json({ message: 'RideOwnerId must not be empty' })
  }

  if(!joinUserId){
    return res.status(400).json({ message: 'JoinUserId must not be empty' })
  }

  if(!rideChatId){
    return res.status(400).json({ message: 'RideChatId must not be empty' })
  }

  const ownerUserRef = admin.database().ref(`/users/${rideOwnerId}`);
  const joiningUserRef = admin.database().ref(`/users/${joinUserId}`);
  const rideRef = admin.database().ref(`/rides/${rideId}`);
  const chatRef = admin.database().ref(`/ridesGroups/${rideChatId}`);

  const ownerPromise = ownerUserRef.once('value');
  const joiningPromise = joiningUserRef.once('value');
  const ridePromise = rideRef.once('value');
  const chatPromise = chatRef.once('value');

  Promise.all([ownerPromise, joiningPromise, ridePromise, chatPromise]).then(results => {
    const ownerUser = results[0].val();
    const joinUser = results[1].val();
    const ride = results[2].val();
    const chat = results[3].val();

    //TODO: check if user is not joined in the ride
    const freePlaces = parseInt(ride.freePlaces);
    if (freePlaces < 1) {
      return res
        .status(400)
        .json({ message: `Ride to ${ride.destination} dose not have availabel places` });
    }

    const newFreePlaces = freePlaces - 1
    rideRef.update({
      freePlaces: newFreePlaces.toString()
    })

    var joiningUserDict = {};
    joiningUserDict[rideId] = true;
    joiningUserRef.child('joinedRides').update(joiningUserDict)


    var chatDict = {};
    chatDict[joinUserId] = joinUser.name;
    chatRef.child('chatMembers').update(chatDict)

    const payload = {
        notification: {
            title: 'Join ride',
            body:  `${joinUser.name} has join your ride`
            // icon: null
        }
    };

    admin.messaging().sendToDevice(ownerUser.notificationsToken, payload)
        .then(response => { return res.status(200).json({result: 'Notification send'}) })
        .catch(error => {
          console.log(`error while sending notification to ${joinUserId} for event ${rideId} with error: ${error}`)
          return res.status(400).json({message: 'Something went wrong'})
        });
  })
  .catch(error => {
    console.log("error: " + error)
    return res.status(400).json({message: 'Something went wrong'})
  });
});

app.post('/leaveRide', (req, res) => {
  const rideId = req.body.rideId
  const rideOwnerId = req.body.rideOwnerId
  const leaveUserId = req.body.leaveUserId
  // const rideChatId = req.body.rideChatId

  if(!rideId){
    return res.status(400).json({ message: 'RideId must not be empty' })
  }

  if(!rideOwnerId){
    return res.status(400).json({ message: 'RideOwnerId must not be empty' })
  }

  if(!leaveUserId){
    return res.status(400).json({ message: 'LeaveUserId must not be empty' })
  }

  // if(!rideChatId){
  //   return res.status(400).json({ message: 'RideChatId must not be empty' })
  // }

  const ownerUserRef = admin.database().ref(`/users/${rideOwnerId}`);
  const leavingUserRef = admin.database().ref(`/users/${leaveUserId}`);
  const rideRef = admin.database().ref(`/rides/${rideId}`);
  // const chatRef = admin.database().ref(`/ridesGroups/${rideChatId}`);

  const ownerPromise = ownerUserRef.once('value');
  const leavingPromise = leavingUserRef.once('value');
  const ridePromise = rideRef.once('value');
  // const chatPromise = chatRef.once('value');

  Promise.all([ownerPromise, leavingPromise, ridePromise]).then(results => {
    const ownerUser = results[0].val();
    const leavingUser = results[1].val();
    const ride = results[2].val();
    // const chat = results[3].val();

    //TODO: check if user is joined in the ride
    const freePlaces = parseInt(ride.freePlaces);

    const newFreePlaces = freePlaces + 1
    rideRef.update({
      freePlaces: newFreePlaces.toString()
    })

    var leavingUserDict = {};
    leavingUserDict[rideId] = false;
    leavingUserRef.child('joinedRides').update(leavingUserDict);

    const payload = {
        notification: {
            title: 'Leave ride',
            body: `${leavingUser.name} has left your ride`
            // icon: null
        }
    };

    admin.messaging().sendToDevice(ownerUser.notificationsToken, payload)
        .then(response => { return res.status(200).json({result: 'Notification send'}) })
        .catch(error => {
          console.log(`error while sending notification to ${joinUserId} for event ${rideId} with error: ${error}`)
          return res.status(400).json({message: 'Something went wrong'})
        });
  })
  .catch(error => {
    console.log("error: " + error)
    return res.status(400).json({message: 'Something went wrong'})
  });
});

// Expose Express API as a single Cloud Function:
exports.api = functions.https.onRequest(app);

exports.chatNotifications = functions.database.ref('/ridesGroups/{groupId}/messagess/{newMessageKey}')
    .onCreate(event => {
      console.log(`event val stringify: ${JSON.stringify(event.data.val())}`)
      console.log(`event params groupId: ${event.params.groupId}`)
      console.log(`event params valueKey: ${event.params.value}`)

      console.log(`event fromId: ${event.data.val().fromId}`);
      console.log(`event imageUrl: ${event.data.val().imageUrl}`);
      console.log(`event message: ${event.data.val().message}`);
      console.log(`event parent: ${JSON.stringify(event.data.ref.parent.child('chatMembers').val())}`);

      const messageGroupId = event.params.groupId
      const newMessageId = event.params.newMessageKey
      const imageUrl = event.data.val().imageUrl
      const fromId = event.data.val().fromId
      const message = event.data.val().message

      const payload = {
          notification: {
              title: `New Message in groupId ${groupId}`,
              body: `You have some new unread messages`
          },
          data: {
            chatGroupKey: messageGroupId,
            newMessageKey: messageGroupId
          }
      };

      return admin.messaging().sendToDevice(ownerUser.notificationsToken, payload)
          .then(response => { return res.status(200).json({result: 'Notification send'}) })
          .catch(error => {
            console.log(`error while sending notification to ${joinUserId} for event ${rideId} with error: ${error}`)
          });
      })
      .catch(error => {
        console.log("error: " + error)
      });


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
