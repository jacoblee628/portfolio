# Test Error for Linear Models
## Problem:
Given target (true distribution) function of ![f(x)=y^2](http://mathurl.com/yarfcahw.png), with x uniformly distributed in ![-1,1](http://mathurl.com/ydbxaw6j.png), our dataset D is two points sampled from the target function, taking the form: ![set](http://mathurl.com/yaxpgzly.png).

We decide to use a linear learning algorithms of form ![hyp](http://mathurl.com/yap2towy.png). Find test performance (![eout](http://mathurl.com/yacz3c8s.png)).

## Solution:
Expected test error can be calculated as follows:

<img src="https://static.wixstatic.com/media/84a55f_6990fa8904824feabef3d1c75f33f4a4~mv2.png/v1/fill/w_410,h_59,al_c,lg_1,q_80/84a55f_6990fa8904824feabef3d1c75f33f4a4~mv2.webp" alt="exout" width="80" height="40"/>

First, intuitively the average function is ![gbar](http://mathurl.com/ycr5kgay.png), which is equal to 0, because of x's uniform distribution.

Second, because we know the true target function (this doesn't happen in the real world), we can calculate test error for a single dataset by the following process:

![eout1](http://mathurl.com/ya2m5zoa.png).

We can integrate the above equation with respect to x over the range of the distribution.

<img src="https://static.wixstatic.com/media/84a55f_2e789d9bce414827a46a05d2ae8c9957~mv2.png/v1/fill/w_718,h_504,al_c,q_85,usm_0.66_1.00_0.01/84a55f_2e789d9bce414827a46a05d2ae8c9957~mv2.webp" alt="int" width="400" height="250"/>

Take the average of the final equation for all experiments to get the overall ![eout](http://mathurl.com/yacz3c8s.png).


all we need to do is calculate 

