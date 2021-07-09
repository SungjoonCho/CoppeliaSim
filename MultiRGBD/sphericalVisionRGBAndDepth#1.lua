-- Note: the spherical vision sensor is supported via the plugin simExtVision, which exports a
-- custom Lua function: simVision.handleSpherical (see further down for the documentation of this function)
-- The source code of the plugin is located in CoppeliaSim's programming folder, and you can freely
-- adapt it. If you add some specific filter or other useful feature to that plugin, let us know, so that we can add it too.

function sysCall_init() 
    local model=sim.getObjectHandle(sim.handle_self)
    object_num = '#1'
    topic_num = '1'
    rgb=sim.getObjectHandle('sphericalVisionRGBAndDepth_sensorRGB'..object_num)
    depth=sim.getObjectHandle('sphericalVisionRGBAndDepth_sensorDepth'..object_num)
    a={-1,-1,-1,-1,-1,-1}
    a[1]=sim.getObjectHandle('sphericalVisionRGBAndDepth_front'..object_num)
    a[2]=sim.getObjectHandle('sphericalVisionRGBAndDepth_top'..object_num)
    a[3]=sim.getObjectHandle('sphericalVisionRGBAndDepth_back'..object_num)
    a[4]=sim.getObjectHandle('sphericalVisionRGBAndDepth_bottom'..object_num)
    a[5]=sim.getObjectHandle('sphericalVisionRGBAndDepth_left'..object_num)
    a[6]=sim.getObjectHandle('sphericalVisionRGBAndDepth_right'..object_num)
    local coll=sim.createCollection(0)
    sim.addItemToCollection(coll,sim.handle_all,-1,0)
    sim.addItemToCollection(coll,sim.handle_tree,model,1)
    for i=1,#a,1 do
        sim.setObjectInt32Param(a[i],sim.visionintparam_entity_to_render,coll)
    end

    -- resolution (color and depth are all unified)
    resXY=1920
    
    -- color 
    rgb_resX=1920
    rgb_resY=1080
    rgb_horizontalAngle=69
    rgb_verticalAngle=42
    
    -- depth
    depth_resX=1280
    depth_resY=720
    depth_horizontalAngle=87
    depth_verticalAngle=58    
    
    updateEveryXSimulationPass=1

    for i=1,6,1 do
        sim.setObjectInt32Param(a[i],sim.visionintparam_resolution_x,resXY)
        sim.setObjectInt32Param(a[i],sim.visionintparam_resolution_y,resXY)
    end
    sim.setObjectInt32Param(rgb,sim.visionintparam_resolution_x,rgb_resX)
    sim.setObjectInt32Param(rgb,sim.visionintparam_resolution_y,rgb_resY)
    sim.setObjectInt32Param(depth,sim.visionintparam_resolution_x,depth_resX)
    sim.setObjectInt32Param(depth,sim.visionintparam_resolution_y,depth_resY)

    viewRgb=sim.floatingViewAdd(0.4,0.8,0.4,0.4,0)
    sim.adjustView(viewRgb,rgb,64)
    viewDepth=sim.floatingViewAdd(0.8,0.8,0.4,0.4,0)
    sim.adjustView(viewDepth,depth,64)
    
    pass=0
    
    if simROS then
        sim.addLog(sim.verbosity_scriptinfos,"ROS interface was found.")
        rgb_pub=simROS.advertise('spherical'..topic_num..'/rgb', 'sensor_msgs/Image')
        depth_pub=simROS.advertise('spherical'..topic_num..'/depth', 'sensor_msgs/Image')
        simROS.publisherTreatUInt8ArrayAsString(rgb_pub) -- treat uint8 arrays as strings (much faster, tables/arrays are kind of slow in Lua)
        simROS.publisherTreatUInt8ArrayAsString(depth_pub)
    else
        sim.addLog(sim.verbosity_scripterrors,"ROS interface was not found. Cannot run.")
    end
    
end

function sysCall_sensing() 
    pass=pass+1
    
    if pass>=updateEveryXSimulationPass then
        result1=simVision.handleSpherical(rgb,a,rgb_horizontalAngle*math.pi/180,rgb_verticalAngle*math.pi/180)
        result2=simVision.handleSpherical(-1,a,depth_horizontalAngle*math.pi/180,depth_verticalAngle*math.pi/180,depth)
   
        pass=0
    end
    
    if simROS then   
        -- Publish the image of the active vision sensor:
        local data,w,h=sim.getVisionSensorCharImage(rgb)
        sim.transformImage(data,{w,h},4)
        d={}
        d.header={stamp=simROS.getTime(), frame_id='rgb_mert'}
        d.height=h
        d.width=w
        d.encoding='rgb8'
        d.is_bigendian=1
        d.step=w*3
        d.data=data
        simROS.publish(rgb_pub,d)
        
        
        -- depth sensor
        local data,w,h=sim.getVisionSensorCharImage(depth)
        sim.transformImage(data,{w,h},4)
        d={}
        d.header={stamp=simROS.getTime(), frame_id='depth_mert'}
        d.height=h
        d.width=w
        d.encoding='rgb8'
        d.is_bigendian=1
        d.step=w*2
        d.data=data
        simROS.publish(depth_pub,d)
    end
    
    
    
    -- How to use the simVision.handleSpherical function:
    -- result=simVision.handleSpherical(passiveVisionSensorHandle,tableOfSixVisionSensorHandles,
    --                                     horizontalSweepAngle,verticalSweepAngle)
    -- In total there are 7 vision sensor objects needed: one passive vision sensor, that will be used to
    -- store the calculated image, and 6 active vision sensors that will look into the 6 direction of space
    -- in following order: front, top, back, bottom, left, right
    -- All vision sensors need to be flagged as 'explicit handling'. The active vision sensor's resolution
    -- need to be all the same, and resolutionX==resolutionY
    --
    -- If you open the hierarchy tree branch of the spherical vision model, you will notice a model
    -- named 'sphericalVision_box'. If you open its model properties, you can make it visible, and 
    -- display the images recorded by the 6 active sensors
    --
    -- Currently, the spherical vision model will disable the specular lighting during operation.
end 

function sysCall_cleanup()
    if simROS then   
        -- Shut down publisher and subscriber. Not really needed from a simulation script (automatic shutdown)
        simROS.shutdownPublisher(rgb_pub)
        simROS.shutdownPublisher(depth_pub)
    end
end
