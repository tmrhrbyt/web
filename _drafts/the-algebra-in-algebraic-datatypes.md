---
layout: post
title: "The algebra in algebraic datatypes"
katex: True
---

In this post I will explore the algebraic properties of Haskell's types, give an informal description of category theory, F-algebras, homomorphisms, catamorphisms and a roundabout way to write a `foldr` that recurses backwards.

<!--more-->

# What do types have to do with algebra?

The first step to modeling Haskell's datatypes algebraically is to build an intution for why such a thing should be possible in the first place. In order to motivate this we shall give an interpretation of some haskell types into sums, products, and exponents on numbers.

We shall make the following intepretation:
* `Either a b`, the disjoint sum type, is interpteted as $$a + b$$.

* `(a, b)`, the product type, is interpteted as $$a \cdot b$$.

* `a -> b`, the function type is interpteted as $$b^a$$.

We will motivate this interpretation by considering the cardinality, or the number of elements of a type. For example, `()` has cardinality 1, and `Bool` has cardinality two. Now then, what is the cardinality of `Either a b`, given that `a` and `b` have cardinalities $$n$$ and $$m$$? Well, there are two ways of constructing a value of `Either a b`, `Left :: a -> Either a b` or `Right :: b -> Either a b`. We can construct $$n$$ elements using `Left`, since we have $$n$$ elements of `a`, and $$m$$ elements using right, as there are $$m$$ elements of `b`. Then in total we can construct $$m + n$$ elements of `Either a b`. Likewise we will see that in the case of `(a, b)` we will have $$n$$ choices for the first element, and then for each element of type `a` we will have another $$m$$ choices for the element of type `b`, yielding $$n \cdot m$$ elements in total. The function type being exponentiation might seem more arcane, but by defining equality of functions and using some basic combinatronics we can make perfect sense of it. If we consider two functions equal given that for every input they give the same output (a principle known as function extensionality) we will see that the way to enumerate the amount of elements of a function type is to enumerate how many different ways we can pick outputs for all our inputs. Consider then, any function `f :: a -> b` for each of the $$n$$ elements `αᵢ : a` we can choose $$m$$ different elements of `b` to send `f αⱼ` to. Thus we are making $$n$$ repeated choices of $$m$$ elements, yielding $$m^n$$ different options.

If we let `| a |` denote the cardinality of `a`, then we can write what we just learned quite succintly.

* `| Either a b |` = `| a | + | b |`

* `| (a, b) |` = `| a | · | b |`

* `| a -> b |` = `| b | ^ | a |`

You may notice the pattern of how we replace the operation (`Either` to `+`, `(,)` to `·`, `->` to `^`) and move the interpretation function (in this case `|_|`) onto the respective arguments. In algebra such a function is called a homomorphism, it's a function which preserves structure, or alternatively, let's us interpret structure in a new domain, here we can reinterpret the structure of our types in numbers, in a way which plays nice with our operations on either side.
  
# Some algebraic properties of types

Now that we've established that we can interpret some of our types in numbers, we may ask of ourselfs if our types fufill some of the same algebraic identities as our numbers. We will revisit some agebraic laws you probably learned long ago and see if we can restate them in Haskell using types.

First let's visit the distributive law of addition and multiplication:

* $$a · (b + c) = a · b + a · c$$

Now, in Haskell we cannot prove equality of types, instead we shall construct an isomorphism, or bijection between our types, a function with an inverse such that their compositio is the identity. Constructing these functions corresponds to creating two functions

```hs
f   :: (a, Either b c) -> Either (a, b) (a, c)
f⁻¹ :: Either (a, b) (a, c) -> (a, Either b c)
```

and proving that

```hs
f . f⁻¹ = id
f⁻¹ . f = id
```

we construct

```hs
f   :: (a, Either b c) -> Either (a, b) (a, c)
f   (a, Left b) = Left (a, b)
f   (a, Right c) = Right (a, c)

f⁻¹ :: Either (a, b) (a, c) -> (a, Either b c)
f⁻¹ Left (a, b) = (a, Left b)
f⁻¹ Right (a, c) = (a, Right c)
```

Proving these are inverses is quite trivial (hint: compare the patterns) and left as an exercise to the reader ;).

The real interesting identities, however, are those to do with exponents, we shall prove that the haskell equivalent of the following exponent laws hold:

* $$a^b \cdot a^c = a^{b+c}$$

* $$(a^b)^c = a^{c \cdot b}$$

Corresponding to creating the following two Haskell functions, and their inverses

```hs
f :: (b -> a, c -> a) -> Either b c -> a
g :: (c -> (b -> a)) -> (c, b) -> a
```

We can define `f` as follows

```hs
f :: (b -> a, c -> a) -> Either b c -> a
f (f, g) (Left b) = f b
f (f, g) (Right c) = g c
```

Interestingly, `g` turns out to be usefull when programming, and is already defined in the prelude!

```hs
g :: (c -> (b -> a)) -> (c, b) -> a
g = uncurry
```

This time I shall be evil and leave finding the inverses as an exercise for you as well!

# Categories

In order to start formalising our notion of algebra in Haskell we will begin to view Haskell lens of category theory. Category theory is the studies of categories, which is defined to be the following

* A collection of objects

* For every ordered pair of objects a set of arrows from the first to the second object

* For every object $$a$$ an arrow $$id_a : a \to a$$

* A composition operation, denoted by $$\circ$$ such that if we have arrows $$g : a \to b$$ and $$f : b \to c$$ then there is another arrow $$f \circ g : a \to c$$

Additionally, the follwing requirements are made

* For any arrow $$f : a \to b$$ we have that $$f \circ id_a = f$$ and $$id_b \circ f = f$$
* For three arrows $$h : a \to b$$, $$g : b \to c$$ and $$f : a \to b$$ we have that $$f \circ (g \circ h) = (f \circ g) \circ h$$

Now of course this all seems very abstract, and it is. The strenght of category theory is how general it is, letting us make precise concepts such as sums and products which pop up all over math. In order to make category theory less abstract we will use Haskell as an example, since it's what we'll mainly be working with in this post.

# Thinking with functions

Now that we've unconvered some interesting algebraic properties of types in Haskell we'll begin viewing these from a category theoretic perspective, which will let us make these notions formal. In doing so we'll need to switch our perspective from the individual types to functions between them, as category is all about arrows rather than objects.

In category theory we define many things using commuting diagrams, and products are no exception. In categary theory, the product of objects $$A$$ and $$B$$ is an object $$A \times B$$, with two arrows $$fst : A \times B \to A$$ and $$snd : A \times B \to B$$, and the requirment that for any C, and f, g, there is an arrow k, such that the following arrow commutes.

{% details What is a commuting diagram %}
A commuting diagram is one in which all ways of walking from one point to another, composing functions along the way, are equal. In the diagram below this means that $$f = fst \circ k$$, and that $$g = snd \circ k$$.
{% enddetails %}

{% cd Product diagram s:40 %}
& \ar[ddl, "f"'] C \ar[dd, dotted, "k"] \ar[ddr, "g"] & \\
& & \\
A & \ar[l, "fst"] A \times B \ar[r, "snd"'] & B
{% endcd %}

* Products + Coproducts
* Explain commuting diagrams somewhere here?

* Initial objects
* Generalized elements

We do however, of course, want to be able to talk about elements of types still, however we will do so using functions. An element of the type `a` will be modelled by a function of type `() -> a`, Using our cardinality view we can see this makes sense as `| () -> a | = | a | ^ | () | = | a | ^ 1 = | a |`.

  * Products
  * Sums
  * Exponents
  * Quick detour on limits

# Functors in category theory
* Functors
  * Endofunctors
  
# Algebra through functors
* Algebra in a category
  * Monoidal object
  * Use this to motivate F-algebras
	* Homomorphism
	  * relate to classical concept of homomorphisms
	  * some examples
  
# Datatypes through fixpoints
* Recursive types in haskell as fixpoints of functors
  * Initial algebra fixpoints
  * Construction
  * Catamorphisms
  * Some examples of familiar datatypes described in this way
  * How catamorphisms compute backwards

# Writing foldr
* Recovering `foldr`

# Co algebras and streams
  
# Caveats

* Haskell pattern matching + recursion more general
  * Bottom

# Notes
* Notation/Terminology
  * Morphism instead of arrow
  * Mjau?

* Recommendations
  * Category theory for programmers
  * Ther are many category theory books

# Bonus: monoids in the category of endofunctors
* monads are monoids in the category of endofunctors
  * category of endofunctors
	* natural transformations
  * relate monoid example from before
  * multiplication given by composition instead of $$\times$$

* General recursion
