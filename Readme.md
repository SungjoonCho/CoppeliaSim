## CoppeliaSim

* Pulblishing frames with Multi Sensor (Using ROS) - RGBD
* Creating mesh shape in CoppeliaSim with Depth frame from realsense in online (Using ROS)
* Creating pointcloud in CoppeliaSim with Depth frame from realsense in online (Using ROS)
* Controlling pose with ROS 

---

## Environment

* OS : Ubunutu 18.04
* ROS : Melodic
* RGBD sensor feature : Realsense D435i
* CoppeliaSim version : Edu


## Installing CoppeliaSim

1. https://www.coppeliarobotics.com/downloads 에서 "choose a different platform?" 확인하여 OS version 확인 후 edu 버전 다운로드
2. 압축 해제 후 Home으로 이동, 디렉토리 이름은 CoppeliaSim으로 변경
3. sudo gedit ~/.bashrc
4. 맨 아랫줄에 export COPPELIASIM_ROOT_DIR=$home/jskimlab/CoppeliaSim 추가하고 나오기
5. cd CoppeliaSim/
6. source ~/.bashrc
7. ./coppeliaSim.sh


참고 : https://www.youtube.com/watch?v=ym5Fveh_yF4



## Connecting ROS 

<pre>
./coppeliaSim.sh 실행시 ROS interface와 연결하지 않았기 때문에 아래와 같은 로그가 출력될 것이다.

[CoppeliaSim:loadinfo]   plugin 'ROS': loading...
[CoppeliaSim:loadinfo]   plugin 'ROS': load failed.

Terminal 1
1. mkdir -p catkin_ws/src
2. /CoppeliaSim/programming/ros_packages의 ros_bubble_rob, sim_ros_interface를 catkin_ws/src로 복사
3. export COPPELIASIM_ROOT_DIR=~/path/to/coppeliaSim/folder (본인 CoppeliaSim 디렉토리 path 입력)
4. catkin build --cmake-args -DCMAKE_BUILD_TYPE=Release (catkin build 하려면 catkin_tool 설치 필요)

Terminal 2
1. roscore

Terminal 3
1. cd CoppeliaSim/
2. source ~/.bashrc
3. ./coppeliaSim.sh

[CoppeliaSim:loadinfo]   plugin 'ROS': loading...
[CoppeliaSim:loadinfo]   plugin 'ROS': load succeeded.

잘 출력되면 성공

참고 : https://www.coppeliarobotics.com/helpFiles/en/ros1Tutorial.htm

</pre>

## Scene

<pre>
기본적인 조작법 참고
https://www.youtube.com/watch?v=PwGY8PxQOXY

scene 구성
1. 좌측의 Model browser에서 필요한 model 드래그&드롭
2. File - Save Scene
</pre>

---

# CoppeliaSim Multi Sensor - RGBD

CoppeliaSim의 Scene에 RGBD sensor 여러 개를 달아 각 방향에서 보이는 rgb frame, depth frame을 ROS로 publish


## Sensor

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/122317570-bd019000-cf58-11eb-9169-383f38cacb17.png">
</p>

<pre>
Model broswer - componets - sensors - spherical vision sensor RGB+depth.ttm

child script(plugin)에서 simulation setting, ros publish & subscribe 가능

getObjectHandle로 sensor 읽어옴
각종 parameter로 realsense D435i와 동일하게 설정(FOV, resolution 등)
setObjectInt32Param로 simulation 속 sensor 동작 설정(위에서 설정한 파라미터 값 부여)
adjustView로 CoppliaSim 내에서 촬영 중인 창 실시간 확인 및 조정

simROS로 ros 관련 값 설정
advertise(topic name, 자료형 type)
sysCall_sensing에서 sensor로부터 실제 data 읽어오고 publish 값 설정 및 publish

기본 child script는 rgb, depth 모두 같은 파라미터를 쓰고 있기 때문에 realsense D435i parameter와 동일하게 만들기 위해 
두 sensor 모두 다른 paramter 적용하도록 수정함, topic도 다른 Sensor에서 이용 가능하도록(겹치지 않도록) Object의 number를 이용하여 추가 설정
</pre>

## 추가로 sensor 부착시

<pre>
동일한 Sensor 가져오고 object_num과 topic_num만 number와 동일하게 수정 ex) '#2', '2'
프로그래밍 언어 lua 이용 참고
</pre>

## Rviz
<pre>
$ rosrun rviz rviz
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/122323270-ca6f4800-cf61-11eb-80b6-4e766a038f76.png">
</p>

---

# Creating mesh shape in CoppeliaSim with Depth frame from realsense in online (Using ROS)

영상 링크
<pre>
https://drive.google.com/file/d/1z_aE5cYs1IBOqVfWEv6FC7Ri53AQjjeH/view?usp=sharing
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123393412-09903f80-d5d9-11eb-8b4e-9350b62a2433.png">
</p>


### CoppeliaSim 설치, ROS 연결
<pre>
https://github.com/SungjoonCho/CoppeliaSim_multiRGBD
</pre>

### Publishing realsense D435i depth frame
<pre>
https://github.com/IntelRealSense/realsense-ros
</pre>

### Mesh 디렉토리 파일 이용 

### Calculating vertices, indices

Plane의 child script에서 depth frame 각 픽셀 값 이용해 계산, 데이터 삽입(언어는 lua)

<pre>
depth frame을 imagesubscribe으로 받아온다.

Lua에서는 데이터를 string으로 주고 받다가 수정이 필요하거나 읽어올 때 int, float로 바꿔쓰는 것이 효율적이라고 한다.

callback func에서 depth frame 전체를 Uint16으로 변환해주고 table로 바꿔준다. 

여기서 테이블을 파이썬으로 치면 list 정도라고 생각하면 된다.
</pre>

Vertices, Indicies

<pre>
Depth frame은 2차원 배열이지만 일렬로 늘어뜨린 1차원 배열이라고 생각하고 진행해야 한다. 각 요소 값은 depth value이다. 

그리고 vertices table 안에는 x,y,z 값이 순서대로 들어가야 한다.
ex. x1,y1,z1,x2,y2,z2,...

x는 각 픽셀의 행, y는 열,z는 depth value로 지정하고 table에 순서대로 삽입해준다. 
이 때 z의 인덱스는 x,y를 이용해서 구한다. 

주의할 점은 lua의 table index는 1부터 시작이다.

Indices table은 우상단이 90도인 직각삼각형(depth가 모두 0일 때 기준)의 연속인 mesh를 그리기 위해
삼각형의 정점 3개가 차례 차례 삽입되도록 하였다.

<p align="center">
  <img width="400" src="https://user-images.githubusercontent.com/80872528/123391884-6db20400-d5d7-11eb-9b1e-8d8c33ec0018.png">
</p>

vertices, indices 구성하는 방법 참고 : https://forum.coppeliarobotics.com/viewtopic.php?t=7920
</pre>

mesh shape이 반복해서 생성되고 제거되도록 만듦.

---

# Creating pointcloud in CoppeliaSim with Depth frame from realsense in online (Using ROS)


영상 링크
<pre>
https://drive.google.com/file/d/14kTUQ0jgJZD7q04P1JKOHyeVGNuQaY-y/view?usp=sharing
</pre>

<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123582361-9ffe7400-d818-11eb-9d63-443d76d0f7ed.png">
</p>

### Pointcloud 디렉토리 이용

---

# Controlling pose with ROS 


<p align="center">
  <img width="700" src="https://user-images.githubusercontent.com/80872528/123583716-0edccc80-d81b-11eb-9233-477551716ade.png">
</p>


## Reference
<pre>
https://www.youtube.com/watch?v=PwGY8PxQOXY
https://www.coppeliarobotics.com/helpFiles/index.html
https://forum.coppeliarobotics.com/viewtopic.php?t=8638
</pre>


