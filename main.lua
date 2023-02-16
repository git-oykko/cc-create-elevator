-- main.lua
-- author : oykko

-- license : MIT

local mappings = {
    ["selected_floor"] = "Right",
    ["current_floor"] = "Front",
    ["is_selected"] = "Left"
}

local modem = peripheral.find("modem")

local ch = 5
local transmitCh = 10

modem.open(ch)

function getSelectedFloor()
    return redstone.getAnalogInput(mappings["selected_floor"])
end

function getIsSelected()
    return redstone.getInput(mappings["is_selected"])
end

function getCurrentFloor()
    return redstone.getAnalogOutput(mappings["current_floor"])
end

function gotoFloor(floor, current_floor)
    modem.transmit(transmitCh, ch, {floor, current_floor})

    local event, side, channel, replyChannel, message, distance

    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == ch

    if message == "done" then
        redstone.setAnalogOutput(mappings["current_floor"], floor)
    end
end

while true do
    os.pullEvent("redstone")

    local selected_floor
    local current_floor

    local is_selected

    is_selected = getIsSelected()

    if is_selected then
        selected_floor = getSelectedFloor()
        current_floor = getCurrentFloor()

        if selected_floor ~= current_floor then
            gotoFloor(selected_floor, current_floor)
        end
    end
end