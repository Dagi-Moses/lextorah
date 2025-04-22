flutter build web --release `
  --dart-define="API_KEY=AIzaSyC-qy0KKnH8RsmvbYov2hSq0wqBQh0PFaA" `
  --dart-define="SERVER_URL=https://lextorah-server.onrender.com"

  
cd build/web
vercel --prod
