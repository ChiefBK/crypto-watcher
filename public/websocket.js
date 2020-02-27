import Formatter from "./formatter.js";
import Percentage from "./percentage.js";

export function start(animation_enabled) {
    console.log('starting');
    const exampleSocket = new WebSocket("ws://localhost:2345");
    console.log('connected to websocket');

    exampleSocket.onopen = function (event) {
        console.log("opened websocket")
    };
    exampleSocket.onmessage = function (event) {
        const screen_obj = JSON.parse(event.data);

        if(screen_obj == null) {
            return;
        }

        if (animation_enabled) {
            hideAnimation();
            setTimeout(function () {
                changeContent(screen_obj, animation_enabled);
            }, 1000);
            setTimeout(function () {
                showAnimation(screen_obj);
            }, 1500);
        }
        else {
            changeContent(screen_obj, animation_enabled);
        }
    };
    exampleSocket.onerror = function (event) {
        console.log('WebSocket error: ', event);
    };
    exampleSocket.onclose = function (event) {
        console.log("closed websocket: ", event)
    };
}

function hideAnimation() {
    console.log("hiding animation");
    const ids = ["rank", "price", "symbol", "currency-code", "net-percentage", "duration"];

    for(const id of ids) {
        document.getElementById(id).classList.add('animated');
        document.getElementById(id).classList.remove('bounceInUp');
        document.getElementById(id).classList.add('bounceOutUp');
        hideArrows();
        setTimeout(function () {
            document.getElementById(id).classList.remove('animated');
            document.getElementById(id).classList.add('not-animated');
        }, 1000)
    }


}

function showAnimation({ net_percentage }) {
    console.log("showing animation");
    const percentChange = Percentage(net_percentage);
    const ids = ["rank", "price", "symbol", "currency-code", "net-percentage", "duration"];

    for(const id of ids) {
        document.getElementById(id).classList.remove('bounceOutUp');
        document.getElementById(id).classList.remove('not-animated');
        document.getElementById(id).classList.add('bounceInUp');
        document.getElementById(id).classList.add('animated');
    }

    setTimeout(function () {
        changeArrow(percentChange)
    }, 500)
}

function changeContent({ net_percentage, rank, price, symbol, currency_code, duration }, animationEnabled) {
    const percentChange = Percentage(net_percentage);

    document.getElementById("rank").innerHTML = rank;
    document.getElementById("price").innerHTML = Formatter(price).currency();
    document.getElementById("symbol").innerHTML = symbol;
    document.getElementById("currency-code").innerHTML = currency_code;
    document.getElementById("net-percentage").innerHTML = percentChange.toString();
    document.getElementById("duration").innerHTML = duration;

    if (!animationEnabled) {
        changeArrow(percentChange)
    }
}

function hideArrows() {
    const arrowUpElement = document.getElementById("arrow-up");
    const arrowDownElement = document.getElementById("arrow-down");

    arrowDownElement.style.visibility = "hidden";
    arrowUpElement.style.visibility = "hidden";
}

function changeArrow(percentage) {
    const arrowUpElement = document.getElementById("arrow-up");
    const arrowDownElement = document.getElementById("arrow-down");

    if (percentage.isPositive()) {
        arrowUpElement.style.visibility = "visible";
        arrowDownElement.style.visibility = "hidden";
    }
    else {
        arrowUpElement.style.visibility = "hidden";
        arrowDownElement.style.visibility = "visible";
    }
}
