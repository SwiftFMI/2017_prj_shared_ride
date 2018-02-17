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

    var chatMembersDict = {};
    chatMembersDict[joinUserId] = true;
    admin.database().ref(`/chatNotifications/${rideChatId}`).update(chatMembersDict)

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
  const rideChatId = req.body.rideChatId

  if(!rideId){
    return res.status(400).json({ message: 'RideId must not be empty' })
  }

  if(!rideOwnerId){
    return res.status(400).json({ message: 'RideOwnerId must not be empty' })
  }

  if(!leaveUserId){
    return res.status(400).json({ message: 'LeaveUserId must not be empty' })
  }

  if(!rideChatId){
    return res.status(400).json({ message: 'RideChatId must not be empty' })
  }

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

    admin.database().ref(`/chatNotifications/${rideChatId}/${leaveUserId}`).remove()

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


app.post('/deleteRide', (req, res) => {
  const rideId = req.body.rideId
  const userId = req.body.userId
  const rideChatId = req.body.rideChatId

  if(!rideId){
    return res.status(400).json({ message: 'RideId must not be empty' })
  }

  if(!userId){
    return res.status(400).json({ message: 'UserId must not be empty' })
  }

  if(!rideChatId){
    return res.status(400).json({ message: 'RideChatId must not be empty' })
  }

  const rideRef = admin.database().ref(`/rides/${rideId}`);
  const chatNotificationsRef = admin.database().ref(`/chatNotifications/${rideChatId}`);

  const ridePromise = rideRef.once('value');
  const chatNotificationsPromise = chatNotificationsRef.once('value');
  // const chatPromise = chatRef.once('value');

  var rideFrom = ""
  var rideTo = ""

  Promise.all([ridePromise, chatNotificationsPromise]).then(results => {
    const ride = results[0].val();
    const chatNotifications = results[1].val();

    admin.database().ref(`/ridesGroups/${ride.groupChatId}`).remove()
    rideRef.remove()
    chatNotificationsRef.remove()

    rideFrom = ride.from
    rideTo = ride.destination

    if (ride.ownerId != userId) {
      res.status(400).json({ message: 'Only ride owner can make this changes' })
      return
    }

    console.log(`RideFrom ${rideFrom}`);
    console.log(`RideTo ${rideTo}`);

    var keys = []
    var promises = []
    for(var key in chatNotifications) {
        if(chatNotifications.hasOwnProperty(key)) {
            //key                 = keys,  left of the ":"
            //driversCounter[key] = value, right of the ":"
            keys.push(key)
            if (key !== userId) {
              const userPromise = admin.database().ref(`/users/${key}`).once('value')
              promises.push(userPromise)
            }
        }
    }
    console.log(`keyss ${keys}`)
    console.log(`loading user profiles ${promises.length}`);
    return Promise.all(promises)
  }).then(results => {
    console.log(`RideFrom ${rideFrom}`);
    console.log(`RideTo ${rideTo}`);

    const payload = {
        notification: {
            title: 'Ride canceled',
            body: `Ride from ${rideFrom} to ${rideTo} had been canceled.`
            // icon: null
        }
    };

    var messegingPromices = []

    results.forEach(user => {
      const notificationToken = user.val().notificationsToken
      console.log(`tokens ${notificationToken}`);
      const notificationPromise = admin.messaging().sendToDevice(notificationToken, payload)
      messegingPromices.push(notificationPromise)
    })
    console.log(`loading promices ${messegingPromices.length}`);

    return Promise.all(messegingPromices)
  }).then(results => {
    console.log("Success: " + results);
    return res.status(200).json({result: 'Notification send'})
  }).catch(error => {
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
      // console.log(`event parent: ${JSON.stringify(event.data.ref.parent.child('chatMembers').val())}`);

      const messageGroupId = event.params.groupId
      const newMessageId = event.params.newMessageKey
      const imageUrl = event.data.val().imageUrl
      const fromId = event.data.val().fromId
      const message = event.data.val().message

      const chatNotificationsRef = admin.database().ref(`/chatNotifications/${messageGroupId}`);
      const userSendRef = admin.database().ref(`/users/${fromId}`);

      const userSendPromise = userSendRef.once('value')
      const chatNotificationsPromise = chatNotificationsRef.once('value');

      var userName = ""

      console.log("StartPromice requests");
      return Promise.all([chatNotificationsPromise, userSendPromise]).then(results => {
        const chatNotifications = results[0].val();
        const sendUser = results[1].val();

        userName = sendUser.name

        var keys = []
        var promises = []
        for(var key in chatNotifications) {
            if(chatNotifications.hasOwnProperty(key)) {
                //key                 = keys,  left of the ":"
                //driversCounter[key] = value, right of the ":"
                keys.push(key)
                if (key !== fromId && chatNotifications[key]) {
                  const userPromise = admin.database().ref(`/users/${key}`).once('value')
                  promises.push(userPromise)
                }
            }
        }
        console.log(`keyss ${keys}`)
        console.log(`loading user profiles ${promises.length}`);
        return Promise.all(promises)
      }).then(results => {
        console.log(`Username send ${userName}`);
        console.log(`messagingGroup ${messageGroupId}`);

        const payload = {
            notification: {
                title: `New message`,
                body: `You have new unread message from ${userName}`
                // icon: null
            },
            data: {
              messageGroupId: `${messageGroupId}`
            }
        };

        var messegingPromices = []

        results.forEach(user => {
          const notificationToken = user.val().notificationsToken
          console.log(`tokens ${notificationToken}`);
          const notificationPromise = admin.messaging().sendToDevice(notificationToken, payload)
          messegingPromices.push(notificationPromise)
        })
        console.log(`loading promices ${messegingPromices.length}`);
        return Promise.all(messegingPromices)
      }).then(results => {
        console.log("success: " + results);
        // return res.status(200).json({result: 'Notification send'})
      }).catch(error => {
        console.log("error: " + error)
        // return res.status(400).json({message: 'Something went wrong'})
      });
      // Set the message as high priority and have it expire after 24 hours.
// var options = {
//   priority: 'high',
//   timeToLive: 60 * 60 * 24
// };
//
// admin.messaging().sendToTopic
      //
      // return admin.messaging().sendToDevice(ownerUser.notificationsToken, payload)
      //     .then(response => { return res.status(200).json({result: 'Notification send'}) })
      //     .catch(error => {
      //       console.log(`error while sending notification to ${joinUserId} for event ${rideId} with error: ${error}`)
      //     });
      // })
      // .catch(error => {
      //   console.log("error: " + error)
      // });


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
