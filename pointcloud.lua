function sysCall_init()
    size=2
    pc=sim.createPointCloud(0.02,20,0,size)
    pointcloud=sim.getObjectHandle('PointCloud')
    sub=simROS.subscribe('/camera/depth/color/points', 'sensor_msgs/PointCloud2', 'pointcloudMessage_callback')
    simROS.subscriberTreatUInt8ArrayAsString(sub)
end

function pointcloudMessage_callback(pts)
    --sim.addLog(0,'callback')
    sim.removePointsFromPointCloud(pc,0,nil,0)
    --local start=sim.getSystemTimeInMs(-2)
    local points={}
    local col={}
    local num=pts.width*pts.height
    tables=sim.unpackFloatTable(pts.data,0,0,0) -- coordinate
    tables1=sim.unpackUInt8Table(pts.data,0,0,0) -- rgb
    local unpack=sim.getSystemTimeInMs(-2)
    
    coor_step = 64
    rgb_step = 256
    z = 1
    
    sim.addLog(0,num)
    
    for  i=0,num-1 do        
        if(tables1[rgb_step*i+19] ~= nil and tables1[rgb_step*i+18] ~= nil and tables1[rgb_step*i+17] ~= nil and tables[coor_step*i+1] ~= nil and tables[coor_step*i+2] ~= nil and tables[coor_step*i+3] ~= nil) then
           table.insert(points,-tables[coor_step*i+1]) -- coor x
           table.insert(points,-tables[coor_step*i+3]) -- coor y
           table.insert(points,-tables[coor_step*i+2]+ z) -- coor z
           table.insert(col,tables1[rgb_step*i+19]) -- rgb
           table.insert(col,tables1[rgb_step*i+18])
           table.insert(col,tables1[rgb_step*i+17])
         end
    end
    --local extract=sim.getSystemTimeInMs(-2)
    sim.insertPointsIntoPointCloud(pc,3,points,col,nil)
    --local insert=sim.getSystemTimeInMs(-2)
    --time1=unpack-start
    --time2=extract-unpack
    --time3=insert-extract
    -- dlgHandle=nil
    -- local txt='unpack_time='..time1.."ms    extract_time="..time2.."ms    insert_time="..time3.."ms"
    -- dlgHandle=sim.displayDialog('info',txt,sim.dlgstyle_message,false)
    sim.switchThread()
end
