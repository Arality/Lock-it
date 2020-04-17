% brick = ConnectBrick('YURI');

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
global event;
event = EVENTS.STOPPED;
global running;
running = true;

while running
    pause(0.1);
    switch event
        case EVENTS.FORWARD
            disp("Forward Event");
            moveForward(brick, BOTHMOTORSPORT, 24)
            while brick.MotorBusy(BOTHMOTORSPORT) == 1 & brick.TouchPressed(BUTTONSENSORPORT) == 0
            end
            if brick.TouchPressed(BUTTONSENSORPORT) == 1
                event = EVENTS.REVERSE;
            else
                event = EVENTS.STOPPED;
            end
            
        case EVENTS.REVERSE
            brick.StopAllMotors();
            disp("Reverse Event");
            brick.MoveMotorAngleRel(LEFTMOTORPORT, 100, -1000, 'Brake');
            brick.MoveMotorAngleRel(RIGHTMOTORPORT, 100, -1000, 'Brake');
            brick.WaitForMotor(LEFTMOTORPORT);
            brick.WaitForMotor(RIGHTMOTORPORT);
            event = EVENTS.TURNING;
            
        case EVENTS.STOPPED
            disp("Stopped Event");
            wallDistance = getDistance(brick, ULTRASONICSENSORPORT);
            disp("The wall is " + wallDistance + "in away");
            if wallDistance <= 24
                event = EVENTS.FORWARD;
            elseif wallDistance  > 24
                event = EVENTS.TURNING;
            end
            
        case EVENTS.TURNING
            disp("Turning Event");
            turnLeft90(brick, LEFTMOTORPORT, RIGHTMOTORPORT);
            event = EVENTS.FORWARD;
            
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

% Move Motor forward  inches
function moveForward = moveForward(bot, bothMotors, inchDistance)
% 2950 = 24"
% 1475 = 12"
bot.MoveMotorAngleRel(bothMotors, 100, convertREL(inchDistance), 'Coast')
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
bot.MoveMotorAngleRel(leftMotor, 70, 1000, 'Coast');
bot.MoveMotorAngleRel(rightMotor, 70, -1000, 'Coast');
bot.StopAllMotors;
end

%Move Motor backwards 12 inches
function reverse12 = reverse12(bot, motorPorts)
bot.MoveMotorAngleRel(motorPorts, -100, 1000, 'Coast');
bot.StopAllMotors();
end

%Move Motor backwards
function reverse = reverse(bot, port)
bot.MoveMotor(port, -100);
end

%{
Functions to be implemented:
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


%}