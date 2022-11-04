// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Car.sol";
import "forge-std/Test.sol";

contract MadCarDev is Car, Test {
    constructor(Monaco _monaco) Car(_monaco) {}

    function updateBalance(Monaco.CarData memory ourCar, uint cost) pure internal {
        ourCar.balance -= uint24(cost);
    }

    function hasEnoughBalance(Monaco.CarData memory ourCar, uint cost) pure internal returns (bool) {
        return ourCar.balance > cost;
    }

    function buyAsMuchAccelerationAsSensible(Monaco.CarData memory ourCar) internal {
        uint baseCost = 25;
        uint speedBoost = ourCar.speed < 5 ? 5 : ourCar.speed < 10 ? 3 : ourCar.speed < 15 ? 2 : 1;
        uint yBoost = ourCar.y < 100 ? 1 : ourCar.y < 250 ? 2 : ourCar.y < 500 ? 3 : ourCar.y < 750 ? 4 : ourCar.y < 950 ? 5 : 10;
        uint costCurve = baseCost * speedBoost * yBoost;
        // uint costCurve = 25 * ((5 / (ourCar.speed + 1))+1) * ((ourCar.y + 1000) / 500);
        uint speedCurve = 8 * ((ourCar.y + 500) / 300);

        emit log_named_uint("[buyAsMuchAccelerationAsSensible] ourCar.y", ourCar.y);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] yBoost", yBoost);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] Speed of our car", ourCar.speed);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] speedBoost", speedBoost);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] Cost Curve", costCurve);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] speedCurve", speedCurve);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] Balance", ourCar.balance);
        emit log_named_uint("[buyAsMuchAccelerationAsSensible] monaco.getAccelerateCost(1) BEFORE", monaco.getAccelerateCost(1));

        while(hasEnoughBalance(ourCar, monaco.getAccelerateCost(1)) && monaco.getAccelerateCost(1) < costCurve && ourCar.speed < speedCurve) updateBalance(ourCar, monaco.buyAcceleration(1));

        emit log_named_uint("[buyAsMuchAccelerationAsSensible] monaco.getAccelerateCost(1) AFTER", monaco.getAccelerateCost(1));
    }

    function buyAsMuchAccelerationAsPossible(Monaco.CarData memory ourCar) internal {
        while(hasEnoughBalance(ourCar, monaco.getAccelerateCost(1))) updateBalance(ourCar, monaco.buyAcceleration(1));
    }

    function inflateShellsPrice(Monaco.CarData memory ourCar) internal {
        while(monaco.getShellCost(1) < 1000 && hasEnoughBalance(ourCar, monaco.getShellCost(1))) updateBalance(ourCar, monaco.buyShell(1));
    }

    function buy1ShellIfPriceIsGood(Monaco.CarData memory ourCar) internal {
        emit log_named_uint("[buy1ShellIfPriceIsGood] Shell Cost BEFORE", monaco.getShellCost(1));
        if(monaco.getShellCost(1) < 1500 && hasEnoughBalance(ourCar, monaco.getShellCost(1) + 500)) updateBalance(ourCar, monaco.buyShell(1));
        emit log_named_uint("[buy1ShellIfPriceIsGood] Shell Cost AFTER", monaco.getShellCost(1));
    }

    function buy1ShellIfSensible(Monaco.CarData memory ourCar, uint speedOfNextCarAhead) internal {
        if(speedOfNextCarAhead < 5) return;

        emit log_named_uint("[buy1ShellIfPriceIsGood] Speed of next car ahead", speedOfNextCarAhead);

        uint costCurve = 500 * ((ourCar.y + 1000) / 500) * ((speedOfNextCarAhead + 5) / 5);

        emit log_named_uint("[buy1ShellIfSensible] Cost Curve", costCurve);
        emit log_named_uint("[buy1ShellIfSensible] Shell Cost BEFORE", monaco.getShellCost(1));

        if(monaco.getShellCost(1) < costCurve && hasEnoughBalance(ourCar, monaco.getShellCost(1))) updateBalance(ourCar, monaco.buyShell(1));

        emit log_named_uint("[buy1ShellIfPriceIsGood] Shell Cost AFTER", monaco.getShellCost(1));
    }

    function buy1ShellWhateverThePrice(Monaco.CarData memory ourCar) internal {
        if(hasEnoughBalance(ourCar, monaco.getShellCost(1))) updateBalance(ourCar, monaco.buyShell(1));
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];
        Monaco.CarData memory otherCar1 = allCars[ourCarIndex == 0 ? 1 : 0];
        Monaco.CarData memory otherCar2 = allCars[ourCarIndex == 2 ? 1 : 2];

        bool isCar1Ahead = otherCar1.y > ourCar.y;
        bool isCar2Ahead = otherCar2.y > ourCar.y;
        bool hasCarAhead = isCar1Ahead || isCar2Ahead;
        // bool hasCarBehind = !isCar1Ahead || !isCar2Ahead;
        // bool isLastPosition = !hasCarBehind;
        // bool is2ndPosition = (isCar1Ahead && !isCar2Ahead) || (isCar2Ahead && !isCar1Ahead);
        bool is1stPosition = !isCar1Ahead && !isCar2Ahead;
        // bool isCar1NextAhead = isCar1Ahead && !isCar2Ahead;
        // bool isCar2NextAhead = isCar2Ahead && !isCar1Ahead;
        // uint distanceToCar1 = isCar1Ahead ? otherCar1.y - ourCar.y : ourCar.y - otherCar1.y;
        // uint distanceToCar2 = isCar2Ahead ? otherCar2.y - ourCar.y : ourCar.y - otherCar2.y;
        // uint distanceToNextCarAhead = is1stPosition ? 0 : isCar1Ahead ? distanceToCar1 : distanceToCar2;
        // uint distanceToNextCarBehind = isLastPosition ? 0 : isCar1NextAhead ? distanceToCar2 : distanceToCar1;
        Monaco.CarData memory nextCarAhead = is1stPosition ? ourCar : isCar1Ahead ? otherCar1 : otherCar2;

        if(hasCarAhead) buy1ShellIfSensible(ourCar, nextCarAhead.speed);
        buy1ShellIfPriceIsGood(ourCar);

        emit log("Accelerating if possible");
        buyAsMuchAccelerationAsSensible(ourCar);
        emit log("Round done");
    }
}
