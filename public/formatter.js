export default function Formatter(input) {
    const formatter = Object.create(Formatter.prototype);
    formatter.input = input;

    return formatter;
}

Formatter.prototype.currency = function () {
    return this.input.toFixed(2);
};
