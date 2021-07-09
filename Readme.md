## CoppeliaSim

* Pulblishing frames with Multi Sensor (Using ROS) - RGBD
* Creating mesh shape in CoppeliaSim with Depth frame from realsense in online (Using ROS)
* Creating pointcloud in CoppeliaSim with Depth frame from realsense in online (Using ROS)
* Controlling pose with ROS 

---

## Environment

* OS : Ubunutu 18.04
* ROS : Melodic
* RGBD sensor parameters : [Realsense D435i](https://www.intelrealsense.com/depth-camera-d435/)
* CoppeliaSim version : Edu


## Installing CoppeliaSim

<pre>
https://www.coppeliarobotics.com/downloads -> "choose a different platform?" -> Check your OS version -> Download "Edu"
Unzip the directory and move it to your $Home Directory, modify the name to "CoppeliaSim"
$ sudo gedit ~/.bashrc
Add to bashrc - export COPPELIASIM_ROOT_DIR=$your/path/to/CoppeliaSim and Save
$ cd CoppeliaSim/
$ source ~/.bashrc
$ ./coppeliaSim.sh
</pre>


## Connecting ROS 


When you run **./coppeliaSim.sh**, since it is not connected to the ROS interface, the following log will be output.

<pre>
[CoppeliaSim:loadinfo]   plugin 'ROS': loading...
[CoppeliaSim:loadinfo]   plugin 'ROS': load failed.
</pre>

Terminal 1
<pre>
$ mkdir -p catkin_ws/src
copy ros_bubble_rob, sim_ros_interface of /CoppeliaSim/programming/ros_packages to catkin_ws/src
$ export COPPELIASIM_ROOT_DIR=~/path/to/coppeliaSim/folder 
$ catkin build --cmake-args -DCMAKE_BUILD_TYPE=Release 
(catkin_tool must be installed in advance)
</pre>

Terminal 2
<pre>
$ roscore
</pre>

Terminal 3
<pre>
$ cd CoppeliaSim/
$ source ~/.bashrc
$ ./coppeliaSim.sh
</pre>

Result
<pre>
[CoppeliaSim:loadinfo]   plugin 'ROS': loading...
[CoppeliaSim:loadinfo]   plugin 'ROS': load succeeded.
</pre>


## Scene

Refer to the basic operation following link
* https://www.youtube.com/watch?v=PwGY8PxQOXY

Customizing scene 
1. Drag and drop the required model from the left "model browser"
2. File - Save Scene
</pre>

## Reference
* https://www.youtube.com/watch?v=ym5Fveh_yF4
* https://www.coppeliarobotics.com/helpFiles/en/ros1Tutorial.htm

---

## CoppeliaSim Multi Sensor - RGBD

By attaching several RGBD sensors to the scene of CoppeliaSim, rgb and depth frame visible from each direction are published as ROS.

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/122317570-bd019000-cf58-11eb-9169-383f38cacb17.png">
</p>

Drag&Drop sensor model
* Model broswer - componets - sensors - spherical vision sensor RGB+depth.ttm

You can publish & subscribe with Ros by customizing child script(plugin).
* Connect sensor with getObjectHandle func.
* Set the same as realsense D435i with various parameters (FOV, resolution, etc.)
* Set operations in simulation with setObjectInt32Param func.
* Check frames being recorded in real time with adjustView func.

Set ros value with simROS func.
* publishing - advertise(topic name, 자료형 type)
* Read data from sensor with sysCall_sensing and set value for publish.
* Avoid overlapping topics - Use Objec(sensor) number to distinguish each topic
</pre>

## When you attach additional sensors

* Modify only **object_num** and **topic_num** to be the same as object number ex) '#2', '2'
* See how to use programming language **Lua**

## Rviz
<pre>
$ rosrun rviz rviz
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/122323270-ca6f4800-cf61-11eb-80b6-4e766a038f76.png">
</p>

---

## Creating mesh shape in CoppeliaSim with Depth frame from realsense in online (Using ROS)

Video Link
<pre>
https://drive.google.com/file/d/1z_aE5cYs1IBOqVfWEv6FC7Ri53AQjjeH/view?usp=sharing
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123393412-09903f80-d5d9-11eb-8b4e-9350b62a2433.png">
</p>

* Refer to Mesh directory.

Calculating vertices, indices
* Calculation using each pixel value of depth frame in child script of Plane and inserting data
* Subscribe value of depth frame with imagesubscribe func.
* It is efficient to exchange data as a string and then change it to int or float when modification or reading is required.
* In the callback func, the entire depth frame is converted to Uint16 and converted into a table.
* If you think of a table here in Python, you can think of it as a list.

Vertices, Indicies
* Depth frame is a two-dimensional array, but you should think of it as a one-dimensional array arranged in a line. Each element value is a depth value.
* And in the vertices table, x, y, z values must be entered in order. ex. x1,y1,z1,x2,y2,z2,...
* Specify x as a row for each pixel, y as a column, and z as a depth value, and insert them into the table in order. In this case, the index of z is obtained using x and y.
* Note that the table index of lua starts at 1.
* Indices table is used to draw a continuous mesh of right-angled triangles (based on when all depths are 0) with an upper right corner of 90 degrees.
The three vertices of the triangle were inserted one after the other.
* The mesh shape was created and removed over and over again.

<p align="center">
  <img width="400" src="https://user-images.githubusercontent.com/80872528/123391884-6db20400-d5d7-11eb-9b1e-8d8c33ec0018.png">
</p>

## Rerference
* https://forum.coppeliarobotics.com/viewtopic.php?t=7920

---

## Creating pointcloud in CoppeliaSim with Depth frame from realsense in online (Using ROS)

Video Link
<pre>
https://drive.google.com/file/d/14kTUQ0jgJZD7q04P1JKOHyeVGNuQaY-y/view?usp=sharing
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123582361-9ffe7400-d818-11eb-9d63-443d76d0f7ed.png">
</p>

* Use Pointcloud directory

---

## Controlling pose with ROS 


<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123583716-0edccc80-d81b-11eb-9233-477551716ade.png">
</p>


## Reference
* https://www.youtube.com/watch?v=PwGY8PxQOXY
* https://www.coppeliarobotics.com/helpFiles/index.html
* https://forum.coppeliarobotics.com/viewtopic.php?t=8638


