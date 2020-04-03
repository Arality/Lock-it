% brick = ConnectBrick('YURI');
%brick = SimBrick;

% Sim Settings
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
global event;
running = true;
event = EVENTS.MANUAL;

while running
    %if brick.TouchPressed(1)
    %    reverse12(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
    %end
    event = EVENTS.MANUAL;
    switch event
        case EVENTS.STARTUP
            event = EVENTS.MANUAL;
        case EVENTS.FORWARD
            moveForward24(bot, port, speed);
        case EVENTS.REVERSE
            
        case EVENTS.STOPPED
            wallDistance = getDistance(brick, ULTRASONICSENSORPORT);
            if wallDistance <= 24
                % There's a wall here
            elseif wallDistance  > 24
                % No Wall
            end
        case EVENTS.TURNING
            
        case EVENTS.MANUAL
            manualControl = true;
            while manualControl
                pause(0.1);
                switch key
                    case 'uparrow'
                        moveForward(brick, BOTHMOTORSPORT);
                    case 'downarrow'
                        brick.StopAllMotors();
                    case 'rightarrow'
                        turnRight(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
                    case 'leftarrow'
                        turnLeft(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
                    case 'r'
                        reverse(brick, BOTHMOTORSPORT);
                    case 'q'
                        manualControl = false;
                        event = EVENTS.QUIT;
                        break;
                end
            end
        case EVENTS.PICKUP
            
        case EVENTS.DROPOFF
            
        case EVENTS.QUIT
            CloseKeyboard();
            running = false;
    end
end

% Ultrasonic code
% Returns the distance reading in inches from the ultrasonic sensor
function distance = getDistance(bot, port)
distance = convertToInches(bot.UltrasonicDist(port));
end

% Converts cm to in
function convertedNumber = convertToInches(number)
convertedNumber = number * 0.3937;
end

% Move Motor forward 24 inches
function moveForward24 = moveForward24(bot, port)
bot.MoveMotor(port, 100);
%Seconds is calculated using distance (24") over speed (9inches/second)
pause(2.666);
bot.StopMotor(port);
end

% Keep moving forward
function moveForward = moveForward(bot, port)
bot.MoveMotor(port, 100);
end

% Stop all motors
function stop = stop(bot, motors)
bot.StopAllMotors(motors, 'Coast')
end

% Turn right 90 degrees
function turnRight90 = turnRight90(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, -650, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, 650, 'Coast');
bot.StopAllMotors;
end

% Keep turnig right
function turnRight = turnRight(bot, leftMotor, rightMotor)
bot.MoveMotor(leftMotor, 100);
bot.MoveMotor(rightMotor, -100);
end

% Turn left 90 degrees
function turnLeft90 = turnLeft90(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, 650, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, -650, 'Coast');
bot.StopAllMotors;
end

% Keep turning left
function turnLeft = turnLeft(bot, leftMotor, rightMotor)
bot.MoveMotor(leftMotor, -100);
bot.MoveMotor(rightMotor, 100);
end

% Turn 180
function turn180 = turn180(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, 1000, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, -1000, 'Coast');
bot.StopAllMotors;
end

%Move Motor backwards 12 inches
function reverse12 = reverse12(bot, leftMotor, rightMotor)
bot.MoveMotorAngleRel(leftMotor, 70, 1000, 'Coast');
bot.MoveMotorAngleRel(rightrMotor, 70, -1000, 'Coast');
bot.StopAllMotors;
end

%Move Motor backwards 12 inches
function reverse = reverse(bot, port)
bot.MoveMotor(port, -100);
end

%{
Functions to be implemented:


%}