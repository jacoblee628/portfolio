# Test Error for Linear Models
## Problem:
Given target (true distribution) function of ![f(x)=y^2](http://mathurl.com/yarfcahw.png), with x uniformly distributed in ![-1,1](http://mathurl.com/ydbxaw6j.png), our dataset D is two points sampled from the target function, taking the form: ![set](http://mathurl.com/yaxpgzly.png).

We decide to use a linear learning algorithms of form ![hyp](http://mathurl.com/yap2towy.png). Find test performance (![eout](http://mathurl.com/yacz3c8s.png)).

## Solution:
From the famous bias-variance decomposition, we know that expected test error can be calculated as follows:

<img src="https://static.wixstatic.com/media/84a55f_6990fa8904824feabef3d1c75f33f4a4~mv2.png/v1/fill/w_410,h_59,al_c,lg_1,q_80/84a55f_6990fa8904824feabef3d1c75f33f4a4~mv2.webp" alt="exout" width="200" height="30"/>

Some tidbits to help: the average function is ![gbar](http://mathurl.com/ycr5kgay.png), which is equal to 0, because of x's uniform distribution. This means that the slope (a) and intercept (b) of the average line are both 0.

Piecing everything together:

<img src="https://static.wixstatic.com/media/84a55f_9d40f110353947538624a7e7706f70e9~mv2.png/v1/fill/w_417,h_216,al_c,lg_1,q_80/84a55f_9d40f110353947538624a7e7706f70e9~mv2.webp" alt="2" width="220" height="110"/>

### Bias

<img src="https://static.wixstatic.com/media/84a55f_988ce48d945c414a80e6193a8b5d34da~mv2.png/v1/fill/w_360,h_60,al_c,lg_1,q_80/84a55f_988ce48d945c414a80e6193a8b5d34da~mv2.webp" alt="1" width="190" height="35"/>

We can integrate across x's range to find a numerical value for the bias.

<img src="https://static.wixstatic.com/media/84a55f_9b453377c3654452ad09d92a6c0630cb~mv2.png/v1/fill/w_288,h_270,al_c,lg_1,q_80/84a55f_9b453377c3654452ad09d92a6c0630cb~mv2.webp" alt="4" width="190" height="180"/>


Nice!

### Variance
Variance is a little trickier.

<img src="https://static.wixstatic.com/media/84a55f_9bb18b627d014b7b96e32a7fab98b9c0~mv2.png/v1/fill/w_332,h_118,al_c,q_80,usm_0.66_1.00_0.01/84a55f_9bb18b627d014b7b96e32a7fab98b9c0~mv2.webp" alt="6" width="240" height="110"/>


Given this information, we can integrate similarly to how we got bias, but we have to do two integrations because of the nested expected values.

<img src="https://static.wixstatic.com/media/84a55f_61260a886c3e4eccbc0ae8d5d0bb7694~mv2.png/v1/fill/w_768,h_522,al_c,q_85,usm_0.66_1.00_0.01/84a55f_61260a886c3e4eccbc0ae8d5d0bb7694~mv2.webp" alt="7" width="430" height="480"/>

Second integration:

<img src="https://static.wixstatic.com/media/84a55f_8c52ee6cc22c4372adc700ac3e68ac03~mv2.png/v1/fill/w_274,h_252,al_c,q_80,usm_0.66_1.00_0.01/84a55f_8c52ee6cc22c4372adc700ac3e68ac03~mv2.webp" alt="8" width="200" height="210"/>

This yields our expected value for ![eout](http://mathurl.com/yacz3c8s.png). 

We're only able to calculate this because we know the true target function. This doesn't happen in the real world, so this is more just math intuition building.


