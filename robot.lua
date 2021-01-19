local robot = require("robot")
component = require("component")
geolyzer = component.geolyzer

maxGrowth = 23
growth = { 1, 2, 3, 4 }
function start()
    for i = 1, 4 do
        goToA(i)
        scan = geolyzer.analyze(0)
        growth[i] = scan['crop:growth']
        goToBase(position)
        i = i + 1
    end
end

function takeCrops()
    if robot.count(1) < 64 then
        robot.turnRight()
        robot.suck(robot.space(1) - 16)
        robot.turnLeft()
    end
end

function drop()
    robot.turnLeft()
    for i = 2, 16 do
        robot.select(i)
        robot.drop(64)
    end
    robot.turnRight()
    robot.select(1)
end

function goToA(pos)
    if pos == 1 then
        robot.forward()
        position = 'a1'
    end
    if pos == 2 then
        robot.forward()
        robot.forward()
        robot.turnLeft()
        robot.forward()
        position = 'a2'
    end
    if pos == 3 then
        robot.forward()
        robot.forward()
        robot.forward()
        position = 'a3'
    end
    if pos == 4 then
        robot.forward()
        robot.forward()
        robot.turnRight()
        robot.forward()
        position = 'a4'
    end
end

function goToB(pos)
    if pos == 1 then
        robot.forward()
        robot.turnLeft()
        robot.forward()
        position = 'b1'
    end
    if pos == 2 then
        robot.forward()
        robot.forward()
        robot.forward()
        robot.turnLeft()
        robot.forward()
        position = 'b2'
    end
    if pos == 3 then
        robot.forward()
        robot.forward()
        robot.forward()
        robot.turnRight()
        robot.forward()
        position = 'b3'
    end
    if pos == 4 then
        robot.forward()
        robot.turnRight()
        robot.forward()
        position = 'b4'
    end
    if pos == 5 then
        robot.forward()
        robot.forward()
        position = 'b5'
    end
end

function goToBase(position)
    if position == 'a1' then
        robot.back()
    end
    if position == 'a2' then
        robot.back()
        robot.turnRight()
        robot.back()
        robot.back()
    end
    if position == 'a3' then
        robot.back()
        robot.back()
        robot.back()
    end
    if position == 'a4' then
        robot.back()
        robot.turnLeft()
        robot.back()
        robot.back()
    end
    if position == 'b1' then
        robot.back()
        robot.turnRight()
        robot.back()
    end
    if position == 'b2' then
        robot.back()
        robot.turnRight()
        robot.back()
        robot.back()
        robot.back()
    end
    if position == 'b3' then
        robot.back()
        robot.turnLeft()
        robot.back()
        robot.back()
        robot.back()
    end
    if position == 'b4' then
        robot.back()
        robot.turnLeft()
        robot.back()
    end
    if position == 'b5' then
        robot.back()
        robot.back()
    end
end

function checkTake(info)
    if component.inventory_controller.getStackInInternalSlot(2) ~= nie then
        local name = component.inventory_controller.getStackInInternalSlot(2)
        if name['label'] == 'Oak Bonsai Seeds' then
            compareSeeds(info)
        end
    end
end

function changeGrowth(position, seedGrowth)
    if position == 'a1' then
        growth[1] = seedGrowth
    end
    if position == 'a2' then
        growth[2] = seedGrowth
    end
    if position == 'a3' then
        growth[3] = seedGrowth
    end
    if position == 'a4' then
        growth[4] = seedGrowth
    end
end

function replace()
    robot.useDown()
    robot.select(2)
    component.inventory_controller.equip()
    robot.useDown()
    component.inventory_controller.equip()
    robot.select(1)
    goToBase(position)
    drop()
end

function compareSeeds(info)
    --[[local growth = info['crop:growth']]
    seedGrowth = info['crop:growth']
    --[[local weedex = info['crop:weedex']]

    min = growth[1]
    max = min

    -- find min growth a1,a2,a3,a4
    for i = 1, 4 do
        if (growth[i] > max) then
            max = growth[i]
        end
        if (growth[i] < min) then
            min = growth[i]
        end
        i = i + 1
    end

    local minGrowth = min --[[min growth]]

    -- find min index growth a1,a2,a3,a4
    for i = 1, 4 do
        if (growth[i] == min) then
            min = i
        else
            i = i + 1
        end
    end

    if seedGrowth > minGrowth and seedGrowth <= maxGrowth then
        goToA(min)
        print('old:' .. minGrowth .. 'new:' .. seedGrowth)
        changeGrowth(position, seedGrowth)
        replace()
    else
        drop()
    end
end

function deleteSeed(info)
    robot.useDown()
    component.inventory_controller.equip()
    robot.useDown()
    component.inventory_controller.equip()
    goToBase(position)
    if info['crop:name'] == 'Oak Bonsai' then
        checkTake(info)
    else
        drop()
    end
end

start()

repeat
    pauseTime = 1
    for r = 1, 5 do
        goToB(r)
        local scanData = geolyzer.analyze(0)
        if scanData['crop:name'] then
            deleteSeed(scanData)
        else
            goToBase(position)
        end
        r = r + 1
    end
    r = 1

    os.sleep(90)
    takeCrops()

until pauseTime > 2



