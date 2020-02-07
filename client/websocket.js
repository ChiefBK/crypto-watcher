function Formatter(input) {
    const formatter = Object.create(Formatter.prototype);
    formatter.input = input;

    return formatter;
}

Formatter.prototype.currency = function () {
    return this.input.toFixed(2);
};

function Percentage(input) {
    const percentage = Object.create(Percentage.prototype)
    percentage.input = input;

    return percentage;
}

Percentage.prototype.isPositive = function () {
    return this.input > 0;
};

Percentage.prototype.toString = function () {
    return `${Math.abs(this.input).toFixed(2)}%`;
};

const exampleSocket = new WebSocket("ws://localhost:2345");

exampleSocket.onopen = function (event) {
    // exampleSocket.send("Can you hear me?");
    console.log("opened websocket")
};
exampleSocket.onmessage = function (event) {
    console.log(event.data);

    const screen_obj = JSON.parse(event.data);

    if(screen_obj == null) {
        return;
    }

    const percentChange = Percentage(screen_obj.net_percentage);

    document.getElementById("price").innerHTML = Formatter(screen_obj.price).currency();
    document.getElementById("symbol").innerHTML = screen_obj.symbol;
    document.getElementById("currency-code").innerHTML = screen_obj.currency_code;
    document.getElementById("net-percentage").innerHTML = percentChange.toString();
    document.getElementById("duration").innerHTML = screen_obj.duration;
};
exampleSocket.onerror = function (event) {
    console.log('WebSocket error: ', event);
};
exampleSocket.onclose = function (event) {
    console.log("closed websocket: ", event)
};
