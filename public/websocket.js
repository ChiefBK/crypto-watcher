import Formatter from "./formatter.js";
import Percentage from "./percentage.js";

export function start() {
    console.log('starting');
    const exampleSocket = new WebSocket("ws://localhost:2345");
    console.log('connected to websocket');

    exampleSocket.onopen = function (event) {
        console.log("opened websocket")
    };
    exampleSocket.onmessage = function (event) {
        console.log(event.data);

        const screen_obj = JSON.parse(event.data);

        if(screen_obj == null) {
            return;
        }

        const percentChange = Percentage(screen_obj.net_percentage);

        document.getElementById("rank").innerHTML = screen_obj.rank;
        document.getElementById("price").innerHTML = Formatter(screen_obj.price).currency();
        document.getElementById("symbol").innerHTML = screen_obj.symbol;
        document.getElementById("currency-code").innerHTML = screen_obj.currency_code;
        document.getElementById("net-percentage").innerHTML = percentChange.toString();
        document.getElementById("duration").innerHTML = screen_obj.duration;

        const arrowUpElement = document.getElementById("arrow-up");
        const arrowDownElement = document.getElementById("arrow-down");

        if (percentChange.isPositive()) {
            arrowUpElement.style.visibility = "visible";
            arrowDownElement.style.visibility = "hidden";
        }
        else {
            arrowUpElement.style.visibility = "hidden";
            arrowDownElement.style.visibility = "visible";
        }
    };
    exampleSocket.onerror = function (event) {
        console.log('WebSocket error: ', event);
    };
    exampleSocket.onclose = function (event) {
        console.log("closed websocket: ", event)
    };
}
