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
%event = EVENTS.MANUAL;
event = EVENTS.STARTUP;
global BUTTON;
BUTTON = brick.TouchPressed(BUTTONSENSORPORT);
global AUTONOMOUSMODE;
AUTONOMOUSMODE = true;

while running
    pause(0.1);
    switch BUTTON
    case 1  % Button Pressed
        reverse12(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
        event = EVENTS.STOPPED
    case 0  % Button not pressed
        switch AUTONOMOUSMODE
        case false  % Yuri under manual control
            manualControl = true;
            while manualControl
                pause(0.1);
                switch key
                    case 'uparrow'
                        continousMoveForward(brick, BOTHMOTORSPORT);
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
                    case 'c'
                        manualControl = false;
                        event = EVENTS.STOPPED;
                        break;
                end
            end
        case true   % Yuri under autonomous control
            switch event
            case EVENTS.STARTUP
                % Setup sim values
                
                event = EVENTS.STOPPED;
            case EVENTS.FORWARD
                for i = 0:3
                    touch = brick.TouchPressed(BUTTONSENSORPORT);
                    if touch
                        event = EVENTS.REVERSE;
                    end
                    moveForward(brick, LEFTMOTORPORT, RIGHTMOTORPORT, 6)
                    i++;
                event = EVENTS.STOPPED;
            case EVENTS.REVERSE
                reverse12(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
                event = EVENTS.STOPPED;
            case EVENTS.STOPPED
                wallDistance = getDistance(brick, ULTRASONICSENSORPORT);
                if wallDistance <= 24
                    event = EVENTS.FORWARD;
                elseif wallDistance  > 24
                    event = EVENTS.TURNING;
                end
            case EVENTS.TURNING
                turnRight90(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
                event = EVENTS.STOPPED;
            case EVENTS.MANUAL
    
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

% Converts REL angle to distance in inches
function angle = convertREL(inches)
angle = inches * 122.9167;  % 122.9167 = (2950/24) = (moveMotorAngleRel distance measured over 24" \ 24")
end

% Move Motor forward 24 inches
function moveForward = moveForward(bot, leftMotor, rightMotor, inchDistance)
% 2950 = 24"
% 1475 = 12"
brick.MoveMotorAngleRel(leftMotor, 100, convertREL(inchDistance), 'Coast')
brick.MoveMotorAngleRel(rightMotor, 100, convertREL(inchDistance), 'Coast')
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
bot.MoveMotorAngleRel(rightMotor, 70, -1000, 'Coast');
bot.StopAllMotors;
end

%Move Motor backwards 12 inches
function reverse = reverse(bot, port)
bot.MoveMotor(port, -100);
end

%{
Functions to be implemented:



%}