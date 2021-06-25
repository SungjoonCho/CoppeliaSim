# Creating mesh shape in CoppeliaSim with Depth frame from realsense in real time

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
