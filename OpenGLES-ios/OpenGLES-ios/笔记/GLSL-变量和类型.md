#  变量和类型
1、变量类型
变量种类            变量类型                                描述
空                       void                                       用于无返回值的函数或者参数为空的函数
标量                   float, int, bool                        浮点型，整型，布尔型的标量数据类型         
浮点型向量        vec2, vec3, vec4                   包含2，3，4个元素的浮点型向量
整数型向量        ivec2, ivec3, ivec4                 包含2，3，4个元素的整型向量
布尔型向量        bvec2, bvec3, bvec4             包含1，2，3，4个元素的布尔型向量
矩阵                   mat2, mat3, mat4                  尺寸为2x2，3x3，4x4的浮点型矩阵
纹理句柄            sampler2D, samplerCube     分别表示操作2D和cube的句柄
备注：GLSL中没有指针类型，大小写敏感的
对于变量类型，GLSL有着非常严格的规则，进行赋值，加减乘除运算必须类型一直，否则会出现语法错误。如果不一致则必须进行强制类型转换
float myFloat = 1.0;
bool myBool = true;
float result = myFloat + myBool(myBool);

2、Structures 结构体
GLSL支持结构体，把一些系统定义的类型聚到一起，组成自定义的类型，也可以包括事先声明的结构体，但是不能定义嵌套结构体。例如：
struct myStruct
{
    float f1;
    bool f2;
    vec3 v3;
}
声明结构体变量
myStruct lightVar2;
struct myStruct2
{
    float f1;
    myStruct st1;   //合法
    struct str2{        // 不合法
        bool b1;
        float f2;
    }
}
3、Arrays 数组
GLSL中的数组和C的数组很类似，支持最基本类型，也支持结构体的数组。例如：

float frequencies[3];
uniform vec4 lightPosition[4];
const int numLights = 2;
light lights[numLights];
备注 GLSL的数组无法在声明的时候初始化。

4、存储限定符
const           常量，或者是函数的只读参数
attribute       只能在顶点着色器中定义，只读属性，由应用程序赋值初始化
uniform        只能定义为全局变量，只读属性，可以由应用程序和opengl 初始化
varying         提供顶点着色器和片段着色器的连接点，只能是float, vec2, vec3, vec4, mat2, mat3, and mat4类型的变量
5、vector变量操作方式
向量的元素有固定的名字去访问，分别有三组{x,y,z,w}、{r,g,b,a}、{s,t,p,q}，访问时下表对应长度不能超过l向量的长度
vec2 v = vec2(3.0);
v.x //正确
v.z // 错误
向量的元素可以放在一起
vec4 v = vec4(1,2,3,4);
v.zy    // 等于 vec2(3,2)
vec3 v3 = v.xyz // 等于vec3(1,2,3)
v.rgba  // 此种方式不正确，下表同时只能使用一个集合中的名称
v.yx = vec2(3,0)    // 将y和x的位置互换并给他们的赋值为新的值，将变成 vec4(3,0,3,4);
6、矩阵元素的操作方式
用[]访问元素
mat4 m;
m[1] = vec4(2.0);   // sets the 4th element of the third column to 2.0
m[0][0] = 1.0;  // sets the upper left element to 1.0
m[2][3] = 2.0;  // sets the second column to all 2.0
7、向量和矩阵的操作
vec3 v, u; float f;
v = u + f;
等价于
v.x = u.x + f;
v.y = u.y + f;
v.z = u.z + f;

vec3 v, u, w; 
w = v + u;
等价于
w.x = v.x + u.x; 
w.y = v.y + u.y; 
w.z = v.z + u.z;

vec3 v, u; 
mat3 m;
u = v * m;
等价于
u.x = dot(v, m[0]); 
u.y = dot(v, m[1]); 
u.z = dot(v, m[2]);

u = m * v;
等价于
u.x = m[0].x * v.x + m[1].x * v.y + m[2].x * v.z; u.y = m[0].y * v.x + m[1].y * v.y + m[2].y * v.z; u.z = m[0].z * v.x + m[1].z * v.y + m[2].z * v.z;

mat m, n, r;
r = m * n;
等价于
r[0].x = m[0].x * n[0].x + m[1].x * n[0].y + m[2].x * n[0].z;
r[1].x = m[0].x * n[1].x + m[1].x * n[0].y + m[2].y * n[0].z; 
r[2].x = m[0].x * n[2].x + m[1].x * n[0].y + m[2].z * n[0].z;

r[0].y = m[0].y * n[0].x + m[1].y * n[1].y + m[2].x * n[1].z;
r[1].y = m[0].y * n[1].x + m[1].y * n[1].y + m[2].y * n[1].z;
r[2].y = m[0].y * n[2].x + m[1].y * n[1].y + m[2].z * n[1].z;

r[0].z = m[0].z * n[0].x + m[1].z * n[2].y + m[2].x * n[2].z;
r[1].z = m[0].z * n[1].x + m[1].z * n[2].y + m[2].y * n[2].z;
r[2].z = m[0].z * n[2].x + m[1].z * n[2].y + m[2].z * n[2].z;





