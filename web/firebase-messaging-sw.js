importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCzaX2MBI2Uk8Qnil_AtqmxuHErBcK0qQQ",
  appId: "1:817332149423:web:ceee03f6beab6cc262c85a",
  messagingSenderId: "817332149423",
  projectId: "trade-wign-bd",
  authDomain: "trade-wign-bd.firebaseapp.com",
  storageBucket: "trade-wign-bd.firebasestorage.app",
  measurementId: "G-PY3ZQBHTC7"
});

const messaging = firebase.messaging();
