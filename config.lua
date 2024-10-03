Config = {}

Config.Controls = {
    goUp = 85, -- [[Q]]
    goDown = 48, -- [[Z]]
    turnLeft = 14, -- [[SCROLLWHEEL DOWN]]
    turnRight = 15, -- [[SCROLLWHEEL UP]]
    goLeft = 34, -- [[A]]
    goRight = 35, -- [[D]]
    goForward = 32,  -- [[W]]
    goBackward = 33, -- [[S]]
    blockCommands = 47, -- [[G]]
    exitMoveMode = 74, -- [[G]]
}

Config.Offsets = { -- HOW MUCH SHOULD THE PED MOVE IN EACH DIRECTION AND (h) ROTATION
    x = 0.2,
    y = 0.2, 
    z = 0.2, 
    h = 3,
}

Config.MovementSpeed = 0.1 -- SPEED COEFFICIENT OF THE MOVEMENT, BIGGER THE NUMBER THE MORE FASTER THE MOVEMENT IS

Config.Command = "animpos"

Config.CommandSuggestion = "Move your character"

Config.Lang = {
    ["move_up"] = "Move up",
    ["move_down"] = "Move down",
    ["move_lr"] = "Move left/right",
    ["fwrd_bwrd"] = "Forward/Backward",
    ["rotate"] = "Rotate left/right",
    ["confirm"] = "Confirm position",
    ["cancel"] = "Cancel position"
}