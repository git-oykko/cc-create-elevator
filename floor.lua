-- floor.lua
-- author : oykko

-- license : MIT

local mappings = {
    ["ground_floor"] = "Front",
    ["floor"] = "Back",
    ["clutch"] = "Right",
    ["gearshift"] = "Left"
}

local modem = peripheral.find("modem")

local ch = 10
local transmitCh = 5

modem.open(ch)

while true do
    local event, side, channel, replyChannel, message, distance

    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == ch

    local selected_floor = message[1]
    local current_floor = message[2]

    redstone.setOutput(mappings["clutch"], true)

    local passed = 0

    if selected_floor > current_floor then
        redstone.setOutput(mappings["gearshift"], true)
    elseif selected_floor < current_floor then
        redstone.setOutput(mappings["gearshift"], false)
    end

    redstone.setOutput(mappings["clutch"], false)

    local passings = math.abs(selected_floor - current_floor)

    while passed ~= passings do
        if selected_floor == 0 then break end

        os.pullEvent("redstone")

        if redstone.getInput(mappings["floor"]) then
            
            passed = passed + 1
            if passed == passings then
                break
            end
        end
    end

    while true do
        if selected_floor ~= 0 then
            break
        end

        os.pullEvent("redstone")

        if selected_floor == 0 then
            if redstone.getInput(mappings["ground_floor"]) then
                modem.transmit(transmitCh, ch, "done")
                break
            end
        end
    end

    redstone.setOutput(mappings["clutch"], true)

    modem.transmit(transmitCh, ch, "done")
end
