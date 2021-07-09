function sysCall_init()
    chair=sim.getObjectHandle('conferenceChair')
    Floor=sim.getObjectHandle('Floor')
    sub=simROS.subscribe('/chatter', 'std_msgs/String', 'kbd_callback')
    simROS.subscriberTreatUInt8ArrayAsString(sub)
end

function kbd_callback(kbd)
    
    --if data == 'w'
    position = sim.getObjectPosition(chair, Floor)
    print(kbd["data"], position)
        
    if kbd["data"] == 'w' then
        position[2] = position[2] + 0.1
    elseif kbd["data"] == 's' then
        position[2] = position[2] - 0.1
    elseif kbd["data"] == 'a' then
        position[1] = position[1] - 0.1
    elseif kbd["data"] == 'd' then
        position[1] = position[1] + 0.1
    end
    
    sim.setObjectPosition(chair, Floor, position)
   
    
end

function sysCall_cleanup()
    if simROS then   
        simROS.shutdownSubscriber(sub)
    end
end
