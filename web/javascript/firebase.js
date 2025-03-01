// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBFcPhp7V5UesXjq2BIjTnMOV3EOHesWSU",
  authDomain: "token-mint-8f0e3.firebaseapp.com",
  projectId: "token-mint-8f0e3",
  storageBucket: "token-mint-8f0e3.firebasestorage.app",
  messagingSenderId: "923501902739",
  appId: "1:923501902739:web:30dd5f67ed72b980e80666",
  measurementId: "G-FR82KYJ5E3"
};
//firebase functions:config:set firebase.apikey="AIzaSyBFcPhp7V5UesXjq2BIjTnMOV3EOHesWSU" firebase.authdomain="token-mint-8f0e3.firebaseapp.com" firebase.projectid="token-mint-8f0e3" firebase.storagebucket="token-mint-8f0e3.firebasestorage.app" firebase.messagingsenderid="923501902739" firebase.appid="1:923501902739:web:30dd5f67ed72b980e80666" firebase.measurementid="G-FR82KYJ5E3"

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);