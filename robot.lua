robot = require("robot")
component = require("component")
geolyzer = component.geolyzer

maxGrowthStat = 23 -- Max growth stat 23/31
maxGainStat = 31 -- Max gain stat 31/31
maxResistanceStat = 2 -- Max resistance stat 0/31

growth = { 1, 2, 3, 4 }
gain = { 1, 2, 3, 4 }
resistance = { 1, 2, 3, 4 }

-- Analysis of maternal crops
function start()
    for i = 1, 4 do
        goToA(i)
        scan = geolyzer.analyze(0)
        growth[i] = scan['crop:growth']
        resistance[i] = scan['crop:resistance']
        gain[i] = scan['crop:gain']
        goToBase(position)
        i = i + 1
    end
end
function analyze()
    for i = 1, 4 do
        goToA(i)
        scan = geolyzer.analyze(0)
        if scan['crop:name'] == 'weed' then
            growth[i] = 0
            resistance[i] = 0
            gain[i] = 0
            robot.useDown()
        end
        i = i + 1
        goToBase(position)
    end
end
-- Replenishment of crops from storage
function takeCrops()
    if robot.count(1) < 64 then
        robot.turnRight()
        robot.suck(robot.space(1) - 16)
        robot.turnLeft()
    end
end
-- Vault cleaning
function drop()
    robot.turnLeft()
    for i = 2, 16 do
        robot.select(i)
        robot.drop(64)
    end
    robot.turnRight()
    robot.select(1)
end
function forward()
    if robot.forward() == nie then
        os.sleep(3)
        forward()
    end
end
function back()
    if robot.back() == nie then
        os.sleep(3)
        back()
    end
end
-- Change positions robot on site "a"
function goToA(pos)
    if pos == 1 then
        forward()
        position = 'a1'
    end
    if pos == 2 then
        forward()
        forward()
        robot.turnLeft()
        forward()
        position = 'a2'
    end
    if pos == 3 then
        forward()
        forward()
        forward()
        position = 'a3'
    end
    if pos == 4 then
        forward()
        forward()
        robot.turnRight()
        forward()
        position = 'a4'
    end
end
-- Change positions robot on site "b"
function goToB(pos)
    if pos == 1 then
        forward()
        robot.turnLeft()
        forward()
        position = 'b1'
    end
    if pos == 2 then
        forward()
        forward()
        forward()
        robot.turnLeft()
        forward()
        position = 'b2'
    end
    if pos == 3 then
        forward()
        forward()
        forward()
        robot.turnRight()
        forward()
        position = 'b3'
    end
    if pos == 4 then
        forward()
        robot.turnRight()
        forward()
        position = 'b4'
    end
    if pos == 5 then
        forward()
        forward()
        position = 'b5'
    end
end
-- Return robot on base from site "a or b"
function goToBase(position)
    if position == 'a1' then
        back()
    end
    if position == 'a2' then
        back()
        robot.turnRight()
        back()
        back()
    end
    if position == 'a3' then
        back()
        back()
        back()
    end
    if position == 'a4' then
        back()
        robot.turnLeft()
        back()
        back()
    end
    if position == 'b1' then
        back()
        robot.turnRight()
        back()
    end
    if position == 'b2' then
        back()
        robot.turnRight()
        back()
        back()
        back()
    end
    if position == 'b3' then
        back()
        robot.turnLeft()
        back()
        back()
        back()
    end
    if position == 'b4' then
        back()
        robot.turnLeft()
        back()
    end
    if position == 'b5' then
        back()
        back()
    end
end
-- Check for seeds
function checkTake(info)
    if component.inventory_controller.getStackInInternalSlot(2) ~= nie then
        local name = component.inventory_controller.getStackInInternalSlot(2)
        if name['label'] == 'Argentia Seeds' then
            compareSeeds(info)
        end
    end
end
-- Update information about seed
function changeGrowth(position, seedGrowth, seedGainseed, Resistance)
    if position == 'a1' then
        growth[1] = seedGrowth
        gain[1] = seedGain
        resistance[1] = seedResistance
    end
    if position == 'a2' then
        growth[2] = seedGrowth
        gain[2] = seedGain
        resistance[2] = seedResistance
    end
    if position == 'a3' then
        growth[3] = seedGrowth
        gain[3] = seedGain
        resistance[3] = seedResistance
    end
    if position == 'a4' then
        growth[4] = seedGrowth
        gain[4] = seedGain
        resistance[4] = seedResistance
    end
end
-- Replace maternal seed
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
-- Compare seeds
function compareSeeds(info)

    seedGrowth = info['crop:growth']
    seedGain = info['crop:gain']
    seedResistance = info['crop:resistance']

    for i = 1, 4 do
        if seedGrowth > growth[i] and seedGrowth <= maxGrowthStat and seedGain >= gain[i] and seedGain <= maxGainStat and seedResistance <= maxResistanceStat then
            goToA(i)
            print('----' .. ' Pos: a' .. i)
            print(' Old growth: ' .. growth[i] .. ' New growth: ' .. seedGrowth)
            print(' Old gain: ' .. gain[i] .. ' New gain: ' .. seedGain)
            print(' seedResistence: ' .. seedResistance)
            print('----')
            changeGrowth(position, seedGrowth, seedGain, seedResistance)
            replace()
            break
        else
            if seedGain > gain[i] and seedGain <= maxGainStat and seedGrowth >= growth[i] and seedGrowth <= maxGrowthStat and seedResistance <= maxResistanceStat then
                goToA(i)
                print('----' .. ' Pos: a' .. i)
                print(' Old growth: ' .. growth[i] .. ' New growth: ' .. seedGrowth)
                print(' Old gain: ' .. gain[i] .. ' New gain: ' .. seedGain)
                print(' seedResistence: ' .. seedResistance)
                print('----')
                changeGrowth(position, seedGrowth, seedGain, seedResistance)
                replace()
                break
            end
        end
    end

    drop()
end
-- Remove seed
function deleteSeed(info)
    robot.useDown()
    component.inventory_controller.equip()
    robot.useDown()
    component.inventory_controller.equip()
    goToBase(position)
    if info['crop:name'] == 'Argentia' then
        checkTake(info)
    else
        drop()
    end
end

-- Start work (It will be changed later)
start()
pauseTime = 1
repeat
    for i = 1, 5 do
        goToB(i)
        local scanData = geolyzer.analyze(0)
        if scanData['crop:name'] then
            deleteSeed(scanData)
        else
            goToBase(position)
        end
        i = i + 1
    end
    i = 1

    os.sleep(15)
    takeCrops()
    pauseTime = pauseTime + 1
    if pauseTime == 25 then
        analyze()
        pauseTime = 1
    end

until pauseTime > 30
-- End :)
