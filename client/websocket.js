const exampleSocket = new WebSocket("ws://localhost:2345");

exampleSocket.onopen = function (event) {
    // exampleSocket.send("Can you hear me?");
    console.log("opened websocket")
};
exampleSocket.onmessage = function (event) {
    console.log(event.data);

    const screen_obj = JSON.parse(event.data);
    document.getElementById("price").innerHTML = screen_obj.price;
    document.getElementById("symbol").innerHTML = screen_obj.symbol;
    document.getElementById("currency-code").innerHTML = screen_obj.currency_code;
    document.getElementById("net-percentage").innerHTML = screen_obj.net_percentage;
    document.getElementById("duration").innerHTML = screen_obj.duration;
};
exampleSocket.onerror = function (event) {
    console.log('WebSocket error: ', event);
};
exampleSocket.onclose = function (event) {
    console.log("closed websocket: ", event)
};
