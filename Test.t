Tests for MotmotLite.

Loading some code is about the most testing that we can do!
  $ echo -e ":file $TESTDIR/Demo.mot\n:quit\n" | $TESTDIR/MotmotLite
  \x1b[H\x1b[JWelcome to MotmotLite (esc)
  Copyright 2023, K.D.P.Ross <KDPRoss@gmail.com>
  
  'It's about 20% as good as Motmot
   with a code-base only 9% the size;
   calibrate expectations accordingly.'
  
  Enter:
  - a binding / expression, e.g.:
    - `x : Num = 5`
    - `2 + 3`
  - `:file {filepath}` (to load a file)
  - `:reset`           (to reset the interpreter)
  - `:quit`            (to exit)
  Interpreter-state has been reset.
  The following bindings are defined: `*`, `+`, `-`, `/`, `::`, `<`, `<+>`, `<->`, `<<`, `<>`, `<|`, `=/=`, `=<`, `==`, `>`, `>+>`, `>=`, `>>`, `id`, `list->map`, `map->list`, `not`, `|->`, `|>`
  (Protip: Type the name of one of these bindings to see its type!)
  
  #> Ought to load `/home/royal/royal/projects/motmot-lite/dist/Demo.mot`.
  Read 208 lines from `/home/royal/royal/projects/motmot-lite/dist/Demo.mot`.
  Processing `2 + 3`.
  Parsed: `2 + 3`.
  Has type: `Num`.
  Value: `5`.
  
  Processing `2 + 3 * 4`.
  Parsed: `2 + (3 * 4)`.
  Has type: `Num`.
  Value: `14`.
  
  Processing `True`.
  Parsed: `True`.
  Has type: `Bool`.
  Value: `True`.
  
  Processing `False`.
  Parsed: `False`.
  Has type: `Bool`.
  Value: `False`.
  
  Processing `[{ Num }]`.
  Parsed: `Nil{ Num }`.
  Has type: `[ Num ]`.
  Value: `[]`.
  
  Processing `[ 1, 2, 3 ]`.
  Parsed: `[ 1, 2, 3 ]`.
  Has type: `[ Num ]`.
  Value: `[ 1, 2, 3 ]`.
  
  Processing `1 :: 2 :: 3 :: [{ Num }]`.
  Parsed: `1 :: (2 :: (3 :: Nil{ Num }))`.
  Has type: `[ Num ]`.
  Value: `[ 1, 2, 3 ]`.
  
  Processing `Cons 1 (Cons 2 (Cons 3 Nil{ Num }))`.
  Parsed: `Cons 1 (Cons 2 (Cons 3 (Nil{ Num })))`.
  Has type: `[ Num ]`.
  Value: `[ 1, 2, 3 ]`.
  
  Processing `Nil : (a : *) => [ a ]`.
  Parsed: `id{ (a : *) => [ a ] } Nil`.
  Has type: `(a : *) => [ a ]`.
  Value: `[]`.
  
  Processing `[{ Num }] : [ Num ]`.
  Parsed: `id{ [ Num ] } (Nil{ Num })`.
  Has type: `[ Num ]`.
  Value: `[]`.
  
  Processing `Just 5`.
  Parsed: `Just 5`.
  Has type: `Maybe Num`.
  Value: `Just 5`.
  
  Processing `Nothing{ [ Num ] }`.
  Parsed: `Nothing{ [ Num ] }`.
  Has type: `Maybe [ Num ]`.
  Value: `Nothing`.
  
  Processing `(Just [ 3 ], (9, [ [ 7 ] ]))`.
  Parsed: `(Just [ 3 ], (9, [ [ 7 ] ]))`.
  Has type: `(Maybe [ Num ], (Num, [ [ Num ] ]))`.
  Value: `(Just [ 3 ], (9, [ [ 7 ] ]))`.
  
  Processing `x : Num ~ 1`.
  Parsed: `(x : Num) ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `_ : Num ~ 7`.
  Parsed: `(_ : Num) ~ 7`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num, y : Bool) ~ 1`.
  Parsed: `((x : Num), (y : Bool)) ~ 1`.
  Has type: `(Num, Bool) -> Num`.
  Value: `<fun>`.
  
  Processing `7 ~ 12`.
  Parsed: `{(==) 7} ~ 12`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing ``(3 + 4) ~ 12`.
  Parsed: `{(==) (3 + 4)} ~ 12`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `Just (Just 7) ~ 3`.
  Parsed: `Just (Just {(==) 7}) ~ 3`.
  Has type: `Maybe (Maybe Num) -> Num`.
  Value: `<fun>`.
  
  Processing `Just{ Maybe Num } (Just{ Num } 7) ~ 3`.
  Parsed: `Just{ Maybe Num } (Just{ Num } {(==) 7}) ~ 3`.
  Has type: `Maybe (Maybe Num) -> Num`.
  Value: `<fun>`.
  
  Processing `[{ Num }] ~ 9`.
  Parsed: `Nil{ Num } ~ 9`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `Nil{ Num } ~ 9`.
  Parsed: `Nil{ Num } ~ 9`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num) :: (_ : [ Num ]) ~ x`.
  Parsed: `Cons (x : Num) (_ : [ Num ]) ~ x`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `[ x1 : Num, x2 : Num ] ~ x1 + x2`.
  Parsed: `Cons (x1 : Num) (Cons (x2 : Num) Nil) ~ x1 + x2`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `{_ =< 5} ~ 3`.
  Parsed: `{flip (=<) 5} ~ 3`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `((x : Num) :: (_ : [ Num ])) and (xs : [ Num ]) ~ x :: xs`.
  Parsed: `(Cons (x : Num) (_ : [ Num ])) and (xs : [ Num ]) ~ x :: xs`.
  Has type: `[ Num ] -> [ Num ]`.
  Value: `<fun>`.
  
  Processing `(x : Num) and `{x >= 5} ~ x`.
  Parsed: `(x : Num) and `{x >= 5} ~ x`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(0 ~ 0) <+ (n : Num ~ n - 1)`.
  Parsed: `({(==) 0} ~ 0) <+ ((n : Num) ~ n - 1)`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `fun (0 ~ 0) (n : Num ~ n - 1)`.
  Parsed: `({(==) 0} ~ 0) <+ ((n : Num) ~ n - 1)`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `fun (0 ~ 1) id{ Num }`.
  Parsed: `({(==) 0} ~ 1) <+ id{ Num }`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `case 12 of (0 ~ 0) (n : Num ~ n - 1)`.
  Parsed: `(({(==) 0} ~ 0) <+ ((n : Num) ~ n - 1)) 12`.
  Has type: `Num`.
  Value: `11`.
  
  Processing `add-corresponding-elements [ 1, 2 ] [ 3, 4, 5, 6, 7 ] where (add-corresponding-elements : [ Num ] -> [ Num ] -> [ Num ]) = fun (_ : [ Num ] | [{ Num }] ~ [{ Num }]) ([{ Num }] ~ _ : [ Num ] ~ [{ Num }]) ((m : Num) :: (ms : [ Num ]) ~ (n : Num) :: (ns : [ Num ]) ~ (m + n) :: add-corresponding-elements ms ns)`.
  Parsed: `let (add-corresponding-elements : [ Num ] -> [ Num ] -> [ Num ]) = (((_ : [ Num ]) | Nil{ Num } ~ Nil{ Num }) <+ (Nil{ Num } ~ (_ : [ Num ]) ~ Nil{ Num }) <+ (Cons (m : Num) (ms : [ Num ]) ~ Cons (n : Num) (ns : [ Num ]) ~ (m + n) :: add-corresponding-elements ms ns)) in add-corresponding-elements [ 1, 2 ] [ 3, 4, 5, 6, 7 ]`.
  Has type: `[ Num ]`.
  Value: `[ 4, 6 ]`.
  
  Processing `1 / 3 + 2 / 3 == 1`.
  Parsed: `((1 / 3) + (2 / 3)) == 1`.
  Has type: `Bool`.
  Value: `True`.
  
  Processing `3 : Num`.
  Parsed: `id{ Num } 3`.
  Has type: `Num`.
  Value: `3`.
  
  Processing `12 |> (_ - 3) >> (7 * _)`.
  Parsed: `12 |> (flip (-) 3 >> (*) 7)`.
  Has type: `Num`.
  Value: `63`.
  
  Processing `fib-naive : Num -> Num = fun (0 ~ 1) (1 ~ 1) ((n : Num) and {_ > 1} ~ fib-naive (n - 2) + fib-naive (n - 1))`.
  Parsed: `fib-naive : Num -> Num = ({(==) 0} ~ 1) <+ ({(==) 1} ~ 1) <+ ((n : Num) and {flip (>) 1} ~ fib-naive (n - 2) + fib-naive (n - 1))
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib-naive` has been created.
  
  Processing `fib-memo : Num -> Num = n : Num ~ v where (v : Num, _ : Map Num Num) = core { 0 |-> 1, 1 |-> 1 } n | (core : Map Num Num -> Num -> (Num, Map Num Num)) = m : Map Num Num ~ n : Num ~ case m >+> n of (Just (n' : Num) ~ (n', m)) (Nothing{ Num } ~ (n', m''') where (n' : Num) = l + r | (m''' : Map Num Num) = m'' <+> n |-> n' | (l : Num, m' : Map Num Num) = core m (n - 2) | (r : Num, m'' : Map Num Num) = core m' (n - 1) )`.
  Parsed: `fib-memo : Num -> Num = (n : Num) ~ let ((v : Num), (_ : Map Num Num)) = core (list->map [ (0, 1), (1, 1) ]) n | (core : Map Num Num -> Num -> (Num, Map Num Num)) = ((m : Map Num Num) ~ (n : Num) ~ ((Just (n' : Num) ~ (n', m)) <+ (Nothing{ Num } ~ let (n' : Num) = (l + r) | (m''' : Map Num Num) = (m'' <+> (n |-> n')) | ((l : Num), (m' : Map Num Num)) = core m (n - 2) | ((r : Num), (m'' : Map Num Num)) = core m' (n - 1) in (n', m'''))) (m >+> n)) in v
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib-memo` has been created.
  
  Processing `f : (a : *) => a -> a ~ f f`.
  Parsed: `(f : (a : *) => a -> a) ~ f f`.
  Has type: `((a : *) => a -> a) -> (a : *) => a -> a`.
  Value: `<fun>`.
  
  Processing `poly-pair : (a : *) => a -> (b : *) => b -> (a, b) = (a : *) => x : a ~ (b : *) => y : b ~ (x, y)`.
  Parsed: `poly-pair : (a : *) => a -> (b : *) => b -> (a, b) = (a : *) => (x : a) ~ (b : *) => (y : b) ~ (x, y)
  Has type: `(a : *) => a -> (b : *) => b -> (a, b)`.
  Value; `<fun>`.
  Binding `poly-pair` has been created.
  
  Processing `funny-games where (funny-games : (a : *) => (b : *) => a -> b) = (a : *) => (b : *) => x : a ~ funny-games{ _, b } x`.
  Parsed: `let (funny-games : (a : *) => (b : *) => a -> b) = ((a : *) => (b : *) => (x : a) ~ funny-games{ _, b } x) in funny-games`.
  Has type: `(a : *) => (b : *) => a -> b`.
  Value: `<fun>`.
  
  Processing `(sq-list [ 2, 4 ], comp-list [ True, False ]) where (my-map : (a : *) => (a -> a) -> [ a ] -> [ a ]) = (a : *) => fun (_ : a -> a | [{ a }] ~ [{ a }]) (f : a -> a ~ (l : a) :: (ls : [ a ]) ~ f l :: my-map f ls) | (sq-list : [ Num ] -> [ Num ]) = my-map (x : Num ~ x * x) | (comp-list : [ Bool ] -> [ Bool ]) = my-map not`.
  Parsed: `let (my-map : (a : *) => (a -> a) -> [ a ] -> [ a ]) = ((a : *) => ((_ : a -> a) | Nil{ a } ~ Nil{ a }) <+ ((f : a -> a) ~ Cons (l : a) (ls : [ a ]) ~ f l :: my-map f ls)) | (sq-list : [ Num ] -> [ Num ]) = my-map ((x : Num) ~ x * x) | (comp-list : [ Bool ] -> [ Bool ]) = my-map not in (sq-list [ 2, 4 ], comp-list [ True, False ])`.
  Has type: `([ Num ], [ Bool ])`.
  Value: `([ 4, 16 ], [ False, True ])`.
  
  Processing `map-cps : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => f : a -> b ~ loop id{ [ b ] } where (loop : (c : *) => ([ b ] -> c) -> [ a ] -> c) = (c : *) => k : [ b ] -> c ~ fun ([{ a }] ~ k [{ b }]) ((x : a) :: (xs : [ a ]) ~ loop k' xs where (k' : [ b ] -> c) = ys : [ b ] ~ k (f x :: ys) )`.
  Parsed: `map-cps : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => (f : a -> b) ~ let (loop : (c : *) => ([ b ] -> c) -> [ a ] -> c) = ((c : *) => (k : [ b ] -> c) ~ (Nil{ a } ~ k (Nil{ b })) <+ (Cons (x : a) (xs : [ a ]) ~ let (k' : [ b ] -> c) = ((ys : [ b ]) ~ k (f x :: ys)) in loop k' xs)) in loop (id{ [ b ] })
  Has type: `(a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ]`.
  Value; `<fun>`.
  Binding `map-cps` has been created.
  
  Processing `map-naive : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => fun (f : a -> b | (x : a) :: (xs : [ a ]) ~ f x :: map-naive f xs) (_ : a -> b ~ [{ a }] ~ [{ b }])`.
  Parsed: `map-naive : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => ((f : a -> b) | Cons (x : a) (xs : [ a ]) ~ f x :: map-naive f xs) <+ ((_ : a -> b) ~ Nil{ a } ~ Nil{ b })
  Has type: `(a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ]`.
  Value; `<fun>`.
  Binding `map-naive` has been created.
  
  Processing `map-naive f xs == map-cps f xs where (f : Num -> Num) = _ + 3 | (xs : [ Num ]) = [ 1, 17, 12 ]`.
  Parsed: `let (f : Num -> Num) = flip (+) 3 | (xs : [ Num ]) = [ 1, 17, 12 ] in map-naive f xs == map-cps f xs`.
  Has type: `Bool`.
  Value: `True`.
  
  Successfully loaded `/home/royal/royal/projects/motmot-lite/dist/Demo.mot`; created bindings `fib-memo`, `fib-naive`, `map-cps`, `map-naive`, `poly-pair`.
  
  #> Goodbye!
