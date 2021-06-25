# Creating mesh shape in CoppeliaSim with Depth frame from realsense in real time

CoppeliaSim 설치, ROS 연결 : https://github.com/SungjoonCho/CoppeliaSim_multiRGBD

### Publishing realsense D435i depth frame

https://github.com/IntelRealSense/realsense-ros

### Calculating vertices, indices

Plane의 child script에서 depth frame 각 픽셀 값 이용해 계산, 데이터 삽입(언어는 lua)

<pre>
depth frame을 imagesubscribe으로 받아온다.

Lua에서는 데이터를 string으로 주고 받다가 수정이 필요하거나 읽어올 때 int, float로 바꿔쓰는 것이 효율적이라고 한다.

callback func에서 depth frame 전체를 Uint16으로 변환해주고 table로 바꿔준다. 

여기서 테이블을 파이썬으로 치면 list 정도라고 생각하면 된다.
</pre>

Vertices

<pre>
Depth frame은 2차원 배열이지만 일렬로 늘어뜨린 1차원 배열이라고 생각하고 진행해야 한다. 각 요소 값은 depth value이다. 

그리고 vertices table 안에는 x,y,z 값이 순서대로 들어가야 한다.
ex. x1,y1,z1,x2,y2,z2,...

x는 각 픽셀의 행, y는 열,z는 depth value로 지정하고 table에 순서대로 삽입해준다. 
이 때 z의 인덱스는 x,y를 이용해서 구한다. 

주의할 점은 lua의 table index는 1부터 시작이다.
</pre>
