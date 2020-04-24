% Run the following commands manually at first startup
%brick = SimBrick;
%brick.conn.write('SET motorRange 2 -2000 2000');
%brick.conn.write('SET driveGearRatio 0.1666666 1.0');
%brick.conn.write('SET effectiveWheelbase 4.45');

% Ports we plug motors into
LEFTMOTORPORT = 'A';
RIGHTMOTORPORT = 'B';
SMALLMOTORPORT = 'C';
BOTHMOTORSPORT = strcat(LEFTMOTORPORT, RIGHTMOTORPORT);
BUTTONSENSORPORT = 1;
GYROSENSORPORT = 2;
COLORSENSORPORT = 3;
ULTRASONICSENSORPORT = 4;
POWER = 100;

% Setup
global key;
InitKeyboard();
global state;
state = STATE.STOPPED;
global running;
running = true;
passengerOnBoard = false;


% Uncomment line to go straight into manual mode for testing
state = STATE.MANUAL;

while running
    pause(0.1);
    switch state
        case STATE.FORWARD
            disp("Forward State");
            brick.MoveMotorAngleRel(BOTHMOTORSPORT, 100, 7375, 'Brake');
            while brick.MotorBusy(BOTHMOTORSPORT) == 1 & brick.TouchPressed(BUTTONSENSORPORT) == 0
                color = brick.ColorColor(3);
                if color == 3   % Green detected
                    if passengerOnBoard == false;
                        brick.StopAllMotors;
                        manualMode(brick, LEFTMOTORPORT, RIGHTMOTORPORT, SMALLMOTORPORT);
                        passengerOnBoard = true;
                    end
                end
                
                if color == 4   %Yellow Goal Zone
                    if passengerOnBoard == true
                        brick.StopAllMotors;
                        brick.MoveMotorAngleRel(BOTHMOTORSPORT, 100, 2500, 'Brake');
                        brick.WaitForMotor(LEFTMOTORPORT);
                        brick.WaitForMotor(RIGHTMOTORPORT);
                        disp("Dropping Passenger");
                        brick.MoveMotorAngleRel(SMALLMOTORPORT, 100, -1400, 'Brake'); %Open Claw
                        brick.WaitForMotor(SMALLMOTORPORT);
                        brick.StopAllMotors;
                        state = STATE.QUIT;
                        break;
                    end
                end
                if color == 5   % Red Light
                    disp("Stopping at red light");
                    brick.StopAllMotors;
                    pause(5);
                    brick.MoveMotorAngleRel(BOTHMOTORSPORT, 100, 3687, 'Brake');
                    brick.WaitForMotor(LEFTMOTORPORT);
                    brick.WaitForMotor(RIGHTMOTORPORT);
                    brick.StopAllMotors;
                end
            end
            if brick.TouchPressed(BUTTONSENSORPORT) == 1
                state= STATE.REVERSE;
                
            else
                state= STATE.STOPPED;
            end
            
        case STATE.REVERSE
            brick.StopAllMotors();
            disp("Reverse State");
            brick.MoveMotorAngleRel(LEFTMOTORPORT, 100, -2500, 'Brake');
            brick.MoveMotorAngleRel(RIGHTMOTORPORT, 100, -2500, 'Brake');
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.WaitForMotor(RIGHTMOTORPORT);
            brick.StopAllMotors();
            state = STATE.TURNLEFT;
            
        case STATE.STOPPED
            disp("Stopped State");
            wallDistance = getDistance(brick, ULTRASONICSENSORPORT);
            disp("The wall is " + wallDistance + "in away");
            if wallDistance <= 24
                state = STATE.FORWARD;
            elseif wallDistance  > 24
                state = STATE.TURNRIGHT;
            end
            
        case STATE.TURNLEFT
            disp("Turning Left State");
            brick.MoveMotorAngleRel(LEFTMOTORPORT, 70, -1100, 'Brake');
            brick.MoveMotorAngleRel(RIGHTMOTORPORT, 70, 1100, 'Brake');
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.StopAllMotors;
            state = STATE.FORWARD;
            
        case STATE.TURNRIGHT
            disp("Turning Right State");
            brick.MoveMotorAngleRel(LEFTMOTORPORT, 70, 1100, 'Brake');
            brick.MoveMotorAngleRel(RIGHTMOTORPORT, 70, -1100, 'Brake');
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.StopAllMotors;
            state = STATE.FORWARD;
            
        case STATE.MANUAL
            manualMode(brick, LEFTMOTORPORT, RIGHTMOTORPORT, SMALLMOTORPORT);
            if state == STATE.QUIT
                break;
            else
                state = STATE.STOPPED;
            end
        case STATE.QUIT
            CloseKeyboard();
            running = false;
    end
end

disp("Congrats you reached the goal");

% Ultrasonic code
% Returns the distance reading in inches from the ultrasonic sensor
function distance = getDistance(bot, port)
distance = convertToInches(bot.UltrasonicDist(port));
end

% Converts cm to in
function convertedNumber = convertToInches(number)
convertedNumber = number * 0.3937;
end

% Manual Mode Control
function manualMode = manualMode(bot, leftMotor, rightMotor, clawMotor)
disp("Entering manual control");
bothMotors = strcat(leftMotor, rightMotor);
manualControl = true;
speed = 100;
global key
InitKeyboard();
clawOpen = true;
while manualControl
    pause(0.1);
    switch key
        case 'uparrow'
            bot.MoveMotor(bothMotors, speed);
        case 'downarrow'
            bot.StopAllMotors();
        case 'rightarrow'
            bot.MoveMotor(leftMotor, speed);
            bot.MoveMotor(rightMotor, -speed);
        case 'leftarrow'
            bot.MoveMotor(leftMotor, -speed);
            bot.MoveMotor(rightMotor, speed);
        case 'r'
            bot.MoveMotor(bothMotors, -speed);
        case 'q'
            manualControl = false;
        case 'z'
            state = STATE.QUIT;
            manualControl = false;
            break;
        case 'space'
            if clawOpen == true
                bot.MoveMotorAngleRel(clawMotor, 100, 1400, 'Brake'); %Close Claw
                disp("Closing Claw");
                clawOpen = false;
                bot.WaitForMotor(clawMotor);
                bot.StopAllMotors;
            else
                bot.MoveMotorAngleRel(clawMotor, 100, -1400, 'Brake'); %Open Claw
                disp("Opening Claw");
                clawOpen = true;
                bot.WaitForMotor(clawMotor);
                bot.StopAllMotors;
            end
        case '1'
            speed = 10;
            disp("Speed set to " + speed);
        case '2'
            speed = 20;
            disp("Speed set to " + speed);
        case '3'
            speed = 30;
            disp("Speed set to " + speed);
        case '4'
            speed = 40;
            disp("Speed set to " + speed);
        case '5'
            speed = 50;
            disp("Speed set to " + speed);
        case '6'
            speed = 60;
            disp("Speed set to " + speed);
        case '7'
            speed = 70;
            disp("Speed set to " + speed);
        case '8'
            speed = 80;
            disp("Speed set to " + speed);
        case '9'
            speed = 90;
            disp("Speed set to " + speed);
        case '0'
            speed = 100;
            disp("Speed set to " + speed);
    end
end
end

%{
Functions to be implemented:

% Converts REL angle to distance in inches
function angle = convertREL(inches)
angle = inches * 122.9167;  % 122.9167 = (2950/24) = (moveMotorAngleRel distance measured over 24" \ 24")
end

% Move Motor forward  inches
function moveForward = moveForward(bot, bothMotors, inchDistance)
% 2950 = 24"
% 1475 = 12"
bot.MoveMotorAngleRel(bothMotors, 100, convertREL(inchDistance), 'Brake')
end

% Keep moving forward
function continousMoveForward = continousMoveForward(bot, port)
bot.MoveMotor(port, 100);
end

% Stop all motors
function stop = stop(bot, motors)
bot.StopAllMotors(motors, 'Coast')
end

% Turn right 90 degrees
function turnRight90 = turnRight90(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, -700, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, 700, 'Coast');
bot.StopAllMotors;
end

% Keep turning right
function turnRight = turnRight(bot, leftMotor, rightMotor)
bot.MoveMotor(leftMotor, 100);
bot.MoveMotor(rightMotor, -100);
end

% Turn left 90 degrees
function turnLeft90 = turnLeft90(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, 700, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, -700, 'Coast');
bot.WaitForMotor(leftMotor);
bot.WaitForMotor(rightMotor);
bot.StopAllMotors;
end

% Keep turning left
function turnLeft = turnLeft(bot, leftMotor, rightMotor)
bot.MoveMotor(leftMotor, -100);
bot.MoveMotor(rightMotor, 100);
end

% Turn 180
function turn180 = turn180(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, 1000, �Brake�);
bot.MoveMotorAngleRel(rightMotor, 70, -1000, �Brake�);
bot.StopAllMotors;
end

%Move Motor backwards 12 inches
function reverse12 = reverse12(bot, motorPorts)
bot.MoveMotorAngleRel(motorPorts, -100, 1000, �Brake�);
bot.StopAllMotors();
end

%Move Motor backwards
function reverse = reverse(bot, port)
bot.MoveMotor(port, -100);
end
%}
