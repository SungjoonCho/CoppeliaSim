function sysCall_init()

    sub=simROS.imageTransportSubscribe('/camera/depth/image_rect_raw', 'depth_callback')
    init = true
    cnt = 0
end

function depth_callback(pts)
    start = os.clock()

    print("Callback func"..cnt)   
    cnt = cnt + 1

    local v={}
    local idx = {}
    float_table=sim.unpackUInt16Table(pts,0,0,0)
    print(#pts, #float_table)
    
    height = 480 --480
    width = 848 --848    
    stride = 8
    divide_ratio = 5000
    
    -- accoring to lua, table index always start from 1
    
    for i=0,height-1,stride do
        for j=0, width-1,stride do
            table.insert(v, i/100) --x
            table.insert(v, j/100) --y
            table.insert(v, float_table[(i*width)+j+1]/divide_ratio) --z   
        end
    end   
    
    -- indices starts with 0

    for i=0,height/stride-2 do
        for j=0, width/stride-2 do
            table.insert(idx, i*width/stride+j)
            table.insert(idx, i*width/stride+j+1)
            table.insert(idx,(i+1)*width/stride+j+1)             
        end
    end    
    
    if init == false then
        mesh=sim.getObjectHandle('Shape')
        sim.removeObject(mesh)
    else
        init = false
    end

    sim.createMeshShape(0,0,v,idx)     
    
    finish = os.clock()

    print(string.format("time costs %.2f\n", finish - start))
       
end

function sysCall_cleanup()
    if simROS then   
        simROS.shutdownSubscriber(sub)
    end
end
