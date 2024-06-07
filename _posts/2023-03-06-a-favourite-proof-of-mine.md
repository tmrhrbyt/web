---
layout: post
title: "A favorite proof of mine"
katex: True
---

There are a lot of proofs in mathematics. Many of them serve to verify what we intuitively know to be true, some of them shed light on new methods, and some reveal new ways to view old ideas. Some proofs leave us with a headache, some leave us bored, and some leave us with wonder. In this blog post I will share a beautiful proof leading to a closed formula for the $$n$$-th Fibonacci number, taking us on a detour into functional programming and linear algebra.

<!--more-->

# The Fibonacci Numbers

The Fibonacci numbers are a sequence of numbers starting with a zero followed by a one where each consequent number is the sum of the last two: $$0, 1, 1, 2, 3, 5, 8, 13 \dots$$. If we wanted to be more precise we could define a mathematical sequence $$\{f\}_{n=0}^{\infty}$$ by the following recursive definition:

$$
  f_n = \begin{cases}
          0\;\textrm{if}\;n=0 \\
          1\;\textrm{if}\;n=1 \\
          f_{n-2} + f_{n-1}\;\textrm{otherwise}
        \end{cases}
$$

The Fibonacci numbers have become a bit of a poster child for recursive definitions, perhaps due to it's simplicity. You'll surely find it in the early chapters of most books teaching functional programming (a programming paradigm where recursive definitions are common).

Indeed, if we open [Chapter 5: Recursion](https://learnyouahaskell.github.io/recursion.html) of [LYAH](https://learnyouahaskell.github.io/) we are greeted with the following.

> Definitions in mathematics are often given recursively. For instance, the Fibonacci sequence is defined recursively.

Likewise, in [Chapter 1.2.2 Tree Recursion](https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/full-text/book/book-Z-H-4.html#%_toc_%_sec_1.2.2) of [SICP](https://mitp-content-server.mit.edu/books/content/sectbyfn/books_pres_0/6515/sicp.zip/index.html) we are yet again greeted by a familiar face.

> Another common pattern of computation is called tree recursion. As an example, consider computing the sequence of Fibonacci numbers

With this in mind, it might come as a surprise that there is a closed, non-recursive, formula for the $$n$$-th Fibonacci number. Perhaps more surprising is that we will discover this formula by using the ideas presented in the above chapter of SICP.

# Programmatically calculating the $$n$$-th Fibonacci number

A naive way of calculating the $$n$$-th Fibonacci number is to use the definition above. Check if $$n = 0$$, if $$n = 1$$, and otherwise calculating $$f_{n-2}$$ and $$f_{n-1}$$. This corresponds to the following Haskell code:
```hs
fib :: Integer -> Integer
fib 0 = 0
fib 1 = 1
fib n = fib (n-2) + fib (n-1)
```

However, there is an issue with this method, many Fibonacci numbers will be calculated numerous times, as for each Fibonacci number evaluated we split into two paths, evaluating the previous and twice previous Fibonacci number. The reader which prefers visuals might appreciate Figure 1.5 from the SICP chapter.

How might we fix this then? A human calculating the $$n$$-th Fibonacci number might construct a list of Fibonacci numbers, calculating each Fibonacci number only once. While it is possible to do this on the computer it is superfluous to carry around all previous numbers, as we only need the previous two to calculate the next one. We might think of this as a 2-slot window, moving along the Fibonacci numbers, taking $$n$$ steps to arrive at $$f_n$$. In code we could represent this as follows:
```hs
--        steps   -> f n-2   -> f n-1   -> f n
window :: Integer -> Integer -> Integer -> Integer
window 0     a b = a
window steps a b = window (steps-1) b (a+b)

fib :: Integer -> Integer
fib n = window n 0 1
```

In each step we move the window by replacing the first slot in the window by what was previously in the second slot and filling the new second slot of the window with the sum of the previous two slots. This is then repeated $$n$$ times, and then the first slot of the window is returned.

# Mathematically calculating the $$n$$-th Fibonacci number

What does this have to do with mathematics, and this beautiful proof that I have promised? We shall begin to translate this moving window into the language of mathematics, our window is a pair of numbers, so why not represent it as a vector. Furthermore, we may view sliding our window one step as a function $$S$$ from vectors to vectors. This poses an interesting question: is this function a linear transformation?

$$
S \left(\begin{bmatrix} a & b \end{bmatrix}\right) \\
+ S\left(\begin{bmatrix} c & d \end{bmatrix}\right) \\
= \begin{bmatrix} b a + b \end{bmatrix} \\
+ \begin{bmatrix} d c + d \end{bmatrix}
$$

$$ = \begin{bmatrix} b + d  \\ a + b + c + d \end{bmatrix} = $$

$$ S\left(\begin{bmatrix} a + c \\ b + d \end{bmatrix}\right) = S\left(\begin{bmatrix} a \\ b \end{bmatrix} + \begin{bmatrix} c \\ d \end{bmatrix}\right)$$

$$ S\left(\alpha \begin{bmatrix} a \\ b \end{bmatrix}\right) = \begin{bmatrix} \alpha b \\ \alpha (a + b) \end{bmatrix} = \alpha \begin{bmatrix} b \\ a + b \end{bmatrix} = \alpha S\left(\begin{bmatrix} a \\ b \end{bmatrix}\right) $$

It is! This is great news as it means we can represent our step function by a matrix. With some basic linear algebra one can deduce that

$$ S = \begin{bmatrix} 0 & 1 \\ 1 & 1 \end{bmatrix} $$

Then to calculate the $$n$$-th Fibonacci number we take the starting window $$\begin{bmatrix} 0 \\ 1 \end{bmatrix}$$ and multiply it by $$S^n$$. Now that the sliding window has been expressed purely in the language of linear algebra we may apply the tools of linear algebra.

# Applying the tools of linear algebra

If you're familiar with linear algebra there might be a part of your brain yelling "diagonalization" right now. We've translated our problem into linear algebra, but even for a small matrix calculating $$S^n$$ can become costly for high $$n$$. Diagonalization is a technique in which we express a matrix in a base where all base vectors are eigenvectors of the original matrix. The benefit of doing this is that it turns exponentiation of matrices, which is hard to calculate into exponentiation of scalars, which is much easier to calculate.

An eigenvector for our matrix $$S$$ is a vector $$\hat v$$ for which $$S \hat v = \lambda \hat v$$ for some scalar $$\lambda$$, which we call an eigenvalue. If there are any such vectors we can find them using their definition.

$$ S \hat v = \lambda \hat v = \lambda I_2 \hat v $$ 

Subtracting $$\lambda I_2 v$$ from both sides yields:

$$ 0 = S \hat v - \lambda I_2 \hat v = (S-\lambda I_2) \hat v $$ 

An equation of the form $$0 = A \hat u$$ will only have non-trivial solutions if the column vectors of $$A$$ are linearly dependent, that is if $$\textrm{det}(A) = 0$$. Thus we can find all scalars $$\lambda$$ for which there are non-trivial vector solutions by solving $$\textrm{det}(S-\lambda I_2) = 0$$. Because of this property the polynomial $$\textrm{det}(A-\lambda I)$$ is called the characteristic polynomial of $$A$$.

In our case we have the following:

$$ \textrm{det}(S-\lambda I_2) = \begin{vmatrix} - \lambda & 1 \\ 1 & 1 - \lambda \end{vmatrix} = \lambda^2 - \lambda - 1 = 0$$

Solving for $$\lambda$$ yields two eigenvalues:

$$ \lambda_0 = \frac{1 - \sqrt 5}{2} ,\; \lambda_1 = \frac{1 + \sqrt 5}{2}$$

Would you look at that, $$\frac{1 + \sqrt 5}{2}$$, the golden ratio! Some of you might already know that the golden ratio is connected to the Fibonacci numbers, in fact, as you get further and further into the sequence of the Fibonacci numbers the ratio $$\frac{f_{n+1}}{f_n}$$ approaches $$\frac{1 + \sqrt 5}{2}$$.

Now we can solve $$(S-\lambda I_2) \hat v = 0$$ for $$\lambda_0$$ and $$\lambda_1$$, and if the two resulting vectors are linearly independent we may use them as the basis of our diagonalization matrix. Gauss elimination yields:

$$ \hat v_0 = \begin{bmatrix} -2 \\ \sqrt 5 - 1 \end{bmatrix},\; \hat v_1 = \begin{bmatrix} 2 \\ \sqrt 5 + 1 \end{bmatrix} $$

These vectors are indeed linearly independent, and we can use them as basis vectors for our diagonal matrix. We will now to write $$S = BDB^{-1}$$ where 
$$ B = \begin{bmatrix} -2 & 2 \\ \sqrt 5 - 1 & \sqrt 5 + 1 \end{bmatrix}$$ 
$$ D = \begin{bmatrix} \frac{1 - \sqrt 5}{2} & 0 \\ 0 & \frac{1 + \sqrt 5}{2} \end{bmatrix}$$ 

We then have that

$$S^n = (BDB^{-1})^n = \underbrace{BDB^{-1} BDB^{-1} \dots BDB^{-1}}_n $$
$$ = \underbrace{BDIDI \dots DB^{-1}}_n = BD^nB^{-1}$$

Which is very nice since

$$D^n = \begin{bmatrix} \frac{1 - \sqrt 5}{2} & 0 \\ 0 & \frac{1 + \sqrt 5}{2} \end{bmatrix}^n = \begin{bmatrix} \left(\frac{1 - \sqrt 5}{2}\right)^n & 0 \\ 0 & \left(\frac{1 + \sqrt 5}{2}\right)^n \end{bmatrix}$$

After calculating $$B^{-1}$$ we can solve $$\begin{bmatrix} f_{n+1} \\ f_n \end{bmatrix} = BD^nB^{-1}$$ for $$f_n$$ to get our closed expression.

$$ f_n = \frac{1}{\sqrt 5} \left(\left(\frac{1 + \sqrt 5}{2}\right)^n - \left(\frac{1 - \sqrt 5}{2}\right)^n\right) $$

# Final thoughts

Whenever I first happened upon the closed formula for the $$n$$-th Fibonacci number it seemed so shockingly random, a formula with bunch of square roots always giving me a recursively specified integer. After I learned this proof it doesn't feel as random anymore, instead, I feel it would be more surprising if we carried out the whole diagonalization process and ended up with no roots. Perhaps more importantly, it opened my eyes to the usage of linear algebra as a powerful mathematical tool, and not just something to be applied in geometry, flow balancing or computer graphics.

# Addendum

It was pointed out to me [on mastodon](https://mastodon.vierkantor.com/@Vierkantor/109978590835441958) that this technique is of interest even if it is not possible to diagonalize the stepping matrix. This is because using fast binary exponentiation one can perform matrix exponentiation in logarithmic time. Thus any linearly recursive algorithm can be calculated in logarithmic time!

Fast binary exponentiation uses the identity $$A^{2k} = (A \cdot A)^k$$, thus we can split the exponent in 2 when even, rather than performing $$2k$$ multiplications. Recursively doing this each time the exponent is even yields logarithmic time exponentiation.
