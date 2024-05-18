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

admin.initializeApp({});

const db = admin.firestore();


exports.betsChecker = onRequest(async (request, response) => {
  try{
    checkIfBetsCompleted();
    checkPoolsBets();

    const dt = getDateTime()
    response.send("success date: " + dt[0] + "time: " + dt[1] );
    
  }catch(exception){
    response.send("Error");
  }
  
});

checkIfBetsCompleted();
checkPoolsBets();

async function getAllIncompleteBets() {
  const collectionRef = db.collection("Users");
  const snapshot = await collectionRef.get();
  var collectionData = {};

  for (const userdoc of snapshot.docs) {
    const incompleteBetsRef = userdoc.ref.collection("Incomplete Bets");
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


            if(parseInt(actualTemp).toString() === parseInt(bet["predictedTemp"]).toString()){

              console.log("Predicted temp: " + parseInt(bet["predictedTemp"]).toString())
              console.log("Actual temp: " + parseInt(actualTemp).toString())

              console.log("Bets exactly matched.");
              changeBetsStatus(bet, true, actualTemp);

            }else{
              changeBetsStatus(bet, false, actualTemp);

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

function changeBetsStatus(bet , betsMatched , actualtemp){

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
      "actualTemp": actualtemp,
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


async function checkPoolsBets(){

  const incompletePoolRef = await db.collection("IncompletePools").get();
  console.log("Incomplete pools info: \n")

  const date = getDateTime();
    const currentDate = date[0]; // Get the current date
    const currentTime = date[1]; // Get the current time

  incompletePoolRef.docs.forEach(async doc => {

    
    var poolInfo = doc.data();
    if(currentDate == poolInfo["date"]  && currentTime == poolInfo["time"]    ){ 

    const zipcode = poolInfo["zipCode"]
    var allBets = poolInfo["userTemp"]
    const tempNow = getTempForSpecificBet(zipcode);

    var sortedBets = await sortMap(zipcode, allBets,tempNow)
    var allWinners = await findMin(sortedBets)

      if(allWinners != null){

        var winnings = poolInfo["totalWins"]
        winnings = winnings / allWinners.size;
        console.log("Total winngs: " + winnings)
        var allWinnersKeys = allWinners.keys()

        for(var winners of allWinnersKeys) {
          console.log("Winner id: " + winners)
          editCoins(winnings,winners)
          allWinners.set(winners, winnings); 
        }

      }else{
        console.log("No winnes at the map is empty after sorting and finding min")
      }

      console.log("All the winners information: ")
      console.log(allWinners)
      
      await moveToCompletePool(allWinners, poolInfo , winnings)

      console.log("Deleting the bet now: ")
      console.log("Doc id: " + doc.id)
      await db.collection("IncompletePools").doc(doc.id).delete()

      
    }else{

      console.log("For bet id: " + doc.id + " bets time has not matched")
      console
      .log("Given data: " + poolInfo["date"] + " Time is : " + poolInfo["time"])
    }

  });
}

function moveToCompletePool(winner, poolInfo, tempNow){

  const winnerData = Object.fromEntries(winner);

  db.collection("CompletedPools").add({

   "actualTemp":tempNow,
   "winners": winnerData,
   "date" : poolInfo["date"],
   "time" : poolInfo["time"],
   "totalWins" : poolInfo["totalWins"],
   "userMoney" : poolInfo["userMoney"],
   "userTemp" : poolInfo["userTemp"],
   "zipCode": poolInfo["zipCode"],
  })


}


function sortMap(zipcode, bets, tempNow ){ 
    const betMap = new Map();

      for(var userid in bets){
        betMap[userid] = Math.abs(parseInt(bets[userid]) - tempNow)
      }
      console.log(betMap)
      const entriesArray = Object.entries(betMap);
      const sortedArray = entriesArray.sort((a, b) => a[1] - b[1]);
      const sortedMap = new Map(sortedArray);
      console.log(sortedMap);
      return sortedArray; // Returning the sorted array, you might want to return sortedMap instead
      
}


async function findMin(map) {
  // Initialize variables to store the minimum value and pairs with that minimum value
  let minValue = Infinity;
  const minPairs = [];

  // Find the minimum value
  for (const [key, value] of map) {
    if (value < minValue) {
        minValue = value;    
    }
  }

  // Collect pairs with the minimum value
  for (const [key, value] of map) {
    if (value === minValue) {
      minPairs.push([key, value]);
    }
  }

  // Create a Map from the pairs with the minimum value
  const minPairsMap = new Map(minPairs);

  // Log the minPairsMap for debugging
  console.log("Min pairs map:", minPairsMap);
  return minPairsMap;
}




