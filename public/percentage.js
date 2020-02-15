export default function Percentage(input) {
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
