# MotmotLite

MotmotLite is a linguistic toy (i.e., a programming language
designed for tinkering rather than for doing anything useful
whatsoever) based upon Motmot. It is a purely-functional,
call-by-pattern language based on composing partial
functions. Good luck; have fun!

## Why Should You Use MotmotLite?

If you have to ask ... the answer is probably 'nupe'.

ChatGPT describes MotmotLite:[^0]

> Motmot[Lite] is a theoretical language that resembles a
> simplified form of Haskell, with notable aspects of other
> functional languages like ML ... It includes some unique
> characteristics and syntax, and it is generally meant to
> illustrate concepts related to type systems, pattern
> matching, and lambda calculus.

[^0]: The views of ChatGPT may not reflect those of
      OpenAI ... or anyone else. Neither Motmot nor
      MotmotLite actually has dependent types.

## What is a Motmot?

* noun. A
  [family of pretty neotropical birds](https://en.wikipedia.org/wiki/Motmot).
  * (For a fascinating time, have a look into the 'racket
    feathers' of the tails.)
* noun. A purely-functional programming language.
  * (For a fascinating time, implement anything in
    MotmotLite.)

## Running It

* Clone this repository.
* Set up `opam`:
  * Install `opam` via whatever your package system is
    * On Arch-based Linux: `pacman -S opam`
  * Initialise `opam`:
    * `opam init`
    * `opam switch create ocaml-base-compiler.4.14.1`
    * `opam switch ocaml-base-compiler.4.14.1`
    * `eval $(opam env)`
    * `opam install core extlib zarith`
      * You *may* need to install some system packages
        (e.g., GMP); you're on your own there!
* Build it: `make build`
* Run it:
  * Install `rlwrap` (optional, technically)
  * `make run` (or just `./MotmotLite`)
  * Run the tests (optional)
    * You'll need `cram`, which you may be able to install
      via your package manager ... or via the horrors of
      Python / `pip`.
    * `make test`

### Things that the Interpreter Can Do

* Read the help that the interpreter provides at start-up.
* See [the demo code](./Demo.mot).

## Comparison with Motmot

### Logistics / Implementation

|                                       | Motmot | MotmotLite |
|---------------------------------------|--------|------------|
| Available in stores                   | [ ]    | [X]        |
| ChatGPT-approved                      | [X]    | [X]        |
| Created by KDP                        | [X]    | [X]        |
| Enormous out-of-the-box libraries     | [X]    | [X]        |
| Free like beer                        | [ ]    | [X] [^1]   |
| Has Emacs mode                        | [X]    | [X] [^2]   |
| Has 100+kLOC implemented in it        | [X]    | [ ]        |
| Has dozens of LOC implemented in it   | [ ]    | [X]        |
| Implemented in NG                     | [X]    | [X] [^3]   |
| Is a staggering work of beauty        | [?]    | [?]        |
| Jupyter kernel support                | [X]    | [ ]        |
| Open source                           | [ ]    | [X]        |
| Pipe mode (`stdin` -> `stdout`)       | [X]    | [ ]        |
| REPL -> obj-level querying            | [X]    | [ ]        |
| Runs on Linux                         | [X]    | [X]        |
| Runs on Mac                           | [X]    | [X]        |
| Runs on any other OS                  | [?]    | [?]        |
| Requires innumerable dependencies     | [X]    | [ ]        |
| Settings / language-features system   | [X]    | [ ]        |
| Supports the ideals of peace and love | [X]    | [X]        |
| Tested                                | [X]    | [-] [^4]   |

[^1]: As a linguistic toy, MotmotLite isn't actually
      useful / useable. It may not be extended or employed
      for any purpose other than for study, entertainment,
      or to create further linguistic toys that are so
      licensed. You may not use MotmotLite if you have
      unkind or unjoyous thoughts in your mind. MotmotLite
      exists to promote peace, love, and functional
      programming.

[^2]: Via Motmot's Emacs mode.

[^3]: The MotmotLite release is in the OCaml compiled from
      the NG source.

[^4]: MotmotLite nominally has a `cram`-based test file, but
      it has <1% the test coverage that Motmot has. However,
      given that much of the code was Motmot-sourced, one
      could make a (fairly-weak) argument that the code in
      MotmotLite has been covered extensively by the Motmot
      tests that existed when the code was extracted /
      forked.

### Data Types

|                         | Motmot | MotmotLite |
|-------------------------|--------|------------|
| Arrays [^5]             | [X]    | [ ]        |
| Lists                   | [X]    | [X]        |
| Maps                    | [X]    | [X]        |
| Numbers (arb-precision) | [X]    | [X]        |
| Records                 | [X]    | [ ]        |
| Sets                    | [X]    | [ ]        |
| Streams (lazy lists)    | [X]    | [ ]        |
| Strings                 | [X]    | [ ]        |
| Trees [^6]              | [X]    | [ ]        |

[^5]: These are purely-functional arrays, based on Okasaki's
      work; as such they're really more 'arrays' than arrays
      (i.e., they don't support constant-time operations but
      log-time ones.)

[^6]: Trees are a legacy of Motmot's Tanager-based heritage.
      They are 'semi-typed', arity-polymorphic ADTs that
      exist in a separate namespace to data constructors
      with the express goal of supporting System-S-based
      term rewriting.

### Language Features

|                                            | Motmot | MotmotLite |
|--------------------------------------------|--------|------------|
| Complicated file loader                    | [X]    | [ ]        |
| Direct-style recursive evaluator           | [X]    | [X]        |
| Extensive strict / lazy binding forms      | [X]    | [X]        |
| Error handling [^7]                        | [X]    | [ ]        |
| Hacked-up simple file loader               | [ ]    | [X]        |
| Limited-context type inference             | [X]    | [X]        |
| Linear parser                              | [X]    | [X]        |
| Modules / namespaces                       | [X]    | [ ]        |
| Parser combinators                         | [X]    | [ ]        |
| Partial-function composition               | [X]    | [X]        |
| Recursive bindings                         | [X]    | [X]        |
| Short-form syntax (e.g., type abstraction) | [X]    | [ ]        |
| Sound type system                          | [ ]    | [X]        |
| System-Fω typing                           | [X]    | [X]        |
| Two-dimensional parser                     | [X]    | [ ]        |
| Type abbreviations                         | [X]    | [ ]        |
| User-defined data types                    | [X]    | [ ]        |
| User-defined mixfix syntax                 | [X]    | [ ]        |

[^7]: Motmot's `try`-`recover` is similar to exception
      handling in other languages but subtly distinct.

### Pattern Styles

|                      | Motmot | MotmotLite |
|----------------------|--------|------------|
| Conjunction          | [X]    | [X]        |
| Data constructor     | [X]    | [X]        |
| Disjunction          | [X]    | [ ]        |
| Expression           | [X]    | [X]        |
| Functional           | [X]    | [ ]        |
| Irrefutable variable | [X]    | [X]        |
| Negation             | [X]    | [ ]        |
| Predicate            | [X]    | [X]        |
| Record               | [X]    | [ ]        |
| Tuple                | [X]    | [X]        |
| Wildcard             | [X]    | [X]        |

## Further Links / Resources

* Related languages:
  * [CamlLite](https://caml.inria.fr/caml-light/)
  * Codeine / Codeine'
  * [Erlang](https://en.wikipedia.org/wiki/Erlang_(programming_language))
  * [F#](https://en.wikipedia.org/wiki/F_Sharphttps://github.com/KDPRoss/Sisserouedia.org/wiki/Purely_functional_programming)
  * [Haskell](https://www.haskell.org/ghc/)
* Related concepts:
  * [Generic Programming](https://en.wikipedia.org/wiki/Generic_programming)
  * [Hindley-Milner](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
  * [kinds](https://en.wikipedia.org/wiki/Kind_(type_theory))
  * [Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
  * [The Lambda Cube](https://en.wikipedia.org/wiki/Lambda_cube)
  * [lazy evaluation / call-by-need](https://en.wikipedia.org/wiki/Lazy_evaluation)
  * [monads](https://en.wikipedia.org/wiki/Monad_(functional_programming))
  * [operational semantics](https://en.wikipedia.org/wiki/Operational_semantics)
  * [parametric polymorphism](https://en.wikipedia.org/wiki/Parametric_polymorphism)
  * [pattern matching](https://en.wikipedia.org/wiki/Pattern_matching)
  * [programming languages theory](https://en.wikipedia.org/wiki/Programming_language_theory)
  * [referential transparency](https://en.wikipedia.org/wiki/Purely_functional_programming)
  * [strict evaluation](https://en.wikipedia.org/wiki/Evaluation_strategy#Eager_evaluation)
  * [strictness / laziness](https://en.wikipedia.org/wiki/Strict_programming_language)
  * [System F](https://en.wikipedia.org/wiki/System_F)
  * [term rewriting](https://en.wikipedia.org/wiki/Rewriting#Term_rewriting_systems)
  * [transformation language](https://en.wikipedia.org/wiki/Transformation_language)
  * [Type Theory](https://en.wikipedia.org/wiki/Intuitionistic_type_theory)
  * [unification](https://en.wikipedia.org/wiki/Unification_(computer_science))
