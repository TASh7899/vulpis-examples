// server.js
const WebSocket = require('ws');

// Start a WebSocket server on port 8080
const wss = new WebSocket.Server({ port: 8080 });

console.log("Vulpis Chat Server running on ws://localhost:8080");

wss.on('connection', function connection(ws) {
    console.log("A new Vulpis client connected!");

    // When the server receives a message from ANY client...
    ws.on('message', function incoming(message) {
        const msgString = message.toString();
        console.log("Received: " + msgString);

        // ...Broadcast it to ALL OTHER connected clients
        wss.clients.forEach(function each(client) {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
                client.send(msgString);
            }
        });
    });

    ws.on('close', () => {
        console.log("A Vulpis client disconnected.");
    });
});
