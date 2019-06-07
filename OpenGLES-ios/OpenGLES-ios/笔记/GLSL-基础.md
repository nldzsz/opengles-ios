#  GLSL(着色器编程语言)
1、介绍
是一个和C语言语法比较类似的着色器变成语言
2、注释
和C语言一样 
// this is a comment
/*
*   this is muti comment
*/
备注：GLSL语言必须由ASCII码字符组成，如果包括非ascii码编译会出错
3、变量命名
GLSL的变量名必须以字母或者下划线开头，由英文字母，数字，_组成，且不能是gl_或__开头(都是系统预留的)，也不能是系统关键字
4、预处理指令
预处理指令以#开头，#号之前不能有除了空白字符之外的任何字符。每一个指令独占一行。内置的预处理指令如下：
#define
#undef
#if
#ifdef
#ifndef
#else
#elif
#endif
#error
#pragma
#extension
#version
#line

#pragma
编译指示。用来控制编译器的一些行为，开发和调试时可以设置为off，默认设为on。

#pragma optimize(on)
#pragma optimize(off)

开发和调试时可以打开debug选项，以便获取更多的调试信息。默认设为off。
#pragma debug(on)
#pragma debug(off)

#extension
如果想使用GLGL默认不支持的操作，则必须启用对应的扩展，启用一个扩展可以使用下面的命令：

#extension : behavior
#extension all : behavior
其中，extension_name是扩展的名称，all是指所有的编译器支持的扩展。
behavior是指对该扩展的具体操作。比如启用、禁用等等。详情如下：
behavior                                    作用                             
require                         启用该扩展。如果不支持，则报错。
enable                          启用该扩展。如果不支持，则会警告。extension_name是all的时候会报错。
warn                            启用该扩展。但是会检测到所有使用该扩展的地方，提出警告。
disable                         禁用该扩展。如果该扩展不被支持，则提出警告。

5、预定义的变量
除此之外，还预定义了一些变量：
__LINE__ ：int类型，当前的行号，也就是在Source String中是第一行
__FILE__ ：int类型，当前Source String的唯一ID标识
__VERSION__ ：int类型，GLGL的版本
GL_ES ：对于嵌入式系统（Embed System，简称 ES），它的值为1，否则为0

6、运算符及其优先级
| 1 |()
| 从右往左 |
| 3 | 乘除法 | * / % | 从左往右 |
| 4 | 加减法 | + - | 从左往右 |
| 5 | 位运算 移位 | << >> | 从左往右 |
| 6 | 大小关系 | < > <= >= | 从左往右 |
| 7 | 相等性判断 | == != | 从左往右 |
| 8 | 位运算 与 | & | 从左往右 |
| 9 | 位或算 非 | ^ | 从左往右 |
| 10 | 位或算 或 | | | 从左往右 |
| 11 | 逻辑与 | && | 从左往右 |
| 12 | 逻辑或 | || | 从左往右 |

7、关键词
列举一下GLSL中的关键词，这些全部是系统保留的，不可私自篡改。

attribute const uniform varying
break continue do for while
if else
in out inout
float int void bool true false
lowp mediump highp precision invariant
discard return
mat2 mat3 mat4
vec2 vec3 vec4 ivec2 ivec3 ivec4 bvec2 bvec3 bvec4
sampler2D samplerCube
struct

asm
class union enum typedef template this packed
goto switch default
inline noinline volatile public static extern external interface flat
long short double half fixed unsigned superp
input output
hvec2 hvec3 hvec4 dvec2 dvec3 dvec4 fvec2 fvec3 fvec4
sampler1D sampler3D
sampler1DShadow sampler2DShadow
sampler2DRect sampler3DRect sampler2DRectShadow
sizeof cast
namespace using

除此之外，所有的以"__"开头的变量全部是预留的，自定义的变量不能以“__”开头。


