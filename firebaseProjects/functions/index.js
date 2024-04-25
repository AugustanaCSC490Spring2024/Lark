/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require('firebase-admin');
const { user } = require("firebase-functions/v1/auth");
admin.initializeApp({

});
const db = admin.firestore();


exports.helloWorld = onRequest(async (request, response) => {
  try{
    
    checkIfBetsCompleted();
    const dt = getDateTime()
    response.send("success date: " + dt[0] + "time: " + dt[1] );
    
  }catch(exception){
    response.send("Error");
  }
  
});


async function getAllIncompleteBets() {
  const collectionRef = db.collection("Users");
  const snapshot = await collectionRef.get();
  var collectionData = {};

  for (const doc of snapshot.docs) {
    const incompleteBetsRef = doc.ref.collection("Incomplete Bets");
    const querySnapshot = await incompleteBetsRef.get();

    querySnapshot.forEach(incompleteBetDoc => {
      const data = incompleteBetDoc.data();

      //make this a map
      collectionData[incompleteBetDoc.id] = data;
    });
  }
  const jsonString = JSON.stringify(collectionData);
  console.log(jsonString);
  return collectionData;
}


async function checkIfBetsCompleted() {

  const incompleteBetsJson = await getAllIncompleteBets();
    const date = getDateTime();
    const currentDate = date[0]; // Get the current date
    const currentTime = date[1]; // Get the current time

    // Iterate over the incomplete bets
    for (const docId in incompleteBetsJson) {

    // Access the document name
    var bet = incompleteBetsJson[docId];
    console.log("docid : " + docId)

    if(currentDate == bet["date"] && currentTime == bet["timeOfWager"]){
          //get the zip and check for the temp
          const zipcode = bet["zipCode"];
          console.log("This is the zipcode: " + zipcode)
          const actualTemp = await getTempForSpecificBet(zipcode)
         
          console.log("Temp we get : " )
          console.log(actualTemp)

          console.log("Parsed Temp we get : ")
          console.log(parseInt(actualTemp).toString())


          if(parseInt(actualTemp).toString() == parseInt(bet["predictedTemp"]).toString()){

            console.log("Predicted temp: " + parseInt(bet["predictedTemp"]).toString())
            console.log("Actual temp: " + parseInt(actualTemp).toString())

            console.log("Bets exactly matched.");
            changeBetsStatus(bet, true);


          }else{
            changeBetsStatus(bet, false);

            console.log("Wrong prediction");
            console.log("Predicted temp: " +bet["predictedTemp"]);
          }

          deleteBet(bet["userid"], docId);

      }else{
        //Do nothing as bet time is not yet there though could update the expected winnings probability something like that
        console.log("Date has not hit yet");
        console.log("Date: " + currentDate + " Time: " + currentTime );
        console.log("Predicted Date: " + bet["date"] + " time:  " + bet["timeOfWager"]);

      }
     
    }
}


function deleteBet(userid,docid){

  db.collection("Users").doc(userid).collection("Incomplete Bets").doc(docid).delete();
  console.log("Bet id: " + docid)
  console.log("Sucessfully deleted bet")
}

function changeBetsStatus(bet , betsMatched){

  var winnings = 0;
  var userid = bet["userid"];


  if(betsMatched){
    winnings = bet["expectedEarning"];
    editCoins(winnings, userid);
  }

  console.log("User id : " + userid);

  db.collection("Users").doc(userid).collection("Complete Bets").add(
    {
      "date": bet["date"],
      "winnings": winnings,
      "predictedTemp": bet["predictedTemp"],
      "wager": bet["wager"],
      "timeOfWager": bet["timeOfWager"],
      "zipCode": bet["zipCode"],
      "result": betsMatched,
    }
    
  );
}


async function editCoins(coinValue, uid){

  const docref = await db.collection("Users").doc(uid);
  const coinsTotal = (await docref.get()).data().Coin + coinValue;
  await docref.update({
    'Coin': coinsTotal,
  });
}



function getDateTime(){

    const dateTimeData = [];
    const now = new Date();
    // Get the current time without seconds
    const options = { hour12: false, hour: '2-digit', minute: '2-digit' };
    const currentTime = now.toLocaleTimeString('en-US', options);
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0'); // Adding 1 to month since it is zero-based
    const day = String(now.getDate()).padStart(2, '0');
    const currentDate = `${year}-${month}-${day}`;

    dateTimeData.push(currentDate);
    dateTimeData.push(currentTime);
    return dateTimeData;

}


function getTempForSpecificBet(zipcode) {
  const apiUrl = "https://api.tomorrow.io/v4/weather/realtime?location="+ zipcode + "&apikey=Wd0DoXa1Tdi5pKtt0d2tdeNJwLQv2mRW";
  return fetch(apiUrl)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.json(); // Parse the response JSON
    })
    .then(data => {
      const jsonString = JSON.stringify(data);
      console.log(data)
      console.log("Temperature right now : " + data['data']['values']['temperature']);     
      var temp = data['data']['values']['temperature']
      return temp; // returns the actual temp for this specific time
    })
  }

