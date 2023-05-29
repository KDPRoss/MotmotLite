Tests for MotmotLite.

Loading some code is about the most testing that we can do!
  $ echo -e ":file $TESTDIR/Examples.mot\n:quit\n" | $TESTDIR/MotmotLite
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
  
  #> Ought to load `/home/royal/royal/projects/motmot-lite/dist/Examples.mot`.
  Read 213 lines from `/home/royal/royal/projects/motmot-lite/dist/Examples.mot`.
  Processing `2 + 3`.
  Parsed: `2 + 3`.
  Has type: `Num`.
  Value: `5`.
  
  Processing `True : Bool`.
  Parsed: `id{ Bool } True`.
  Has type: `Bool`.
  Value: `True`.
  
  Processing `12 : Num`.
  Parsed: `id{ Num } 12`.
  Has type: `Num`.
  Value: `12`.
  
  Processing `93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000 : Num`.
  Parsed: `id{ Num } 93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000`.
  Has type: `Num`.
  Value: `93326215443944152681699238856266700490715968264381621468592963895217599993229915608941463976156518286253697920827223758251185210916864000000000000000000000000`.
  
  Processing `Cons 2 (Cons 3 Nil{ Num })`.
  Parsed: `Cons 2 (Cons 3 (Nil{ Num }))`.
  Has type: `[ Num ]`.
  Value: `[ 2, 3 ]`.
  
  Processing `Cons{ Num } 2 (Cons{ Num } 3 Nil{ Num })`.
  Parsed: `Cons{ Num } 2 (Cons{ Num } 3 (Nil{ Num }))`.
  Has type: `[ Num ]`.
  Value: `[ 2, 3 ]`.
  
  Processing `Cons 3 : [ Num ] -> [ Num ]`.
  Parsed: `id{ [ Num ] -> [ Num ] } (Cons 3)`.
  Has type: `[ Num ] -> [ Num ]`.
  Value: `Cons 3`.
  
  Processing `Nil : (a : *) => [ a ]`.
  Parsed: `id{ (a : *) => [ a ] } Nil`.
  Has type: `(a : *) => [ a ]`.
  Value: `[]`.
  
  Processing `Nil{ Num } : [ Num ]`.
  Parsed: `id{ [ Num ] } (Nil{ Num })`.
  Has type: `[ Num ]`.
  Value: `[]`.
  
  Processing `Nothing{ Maybe Num } : Maybe (Maybe Num)`.
  Parsed: `id{ Maybe (Maybe Num) } (Nothing{ Maybe Num })`.
  Has type: `Maybe (Maybe Num)`.
  Value: `Nothing`.
  
  Processing `(2, True) : (Num, Bool)`.
  Parsed: `id{ (Num, Bool) } (2, True)`.
  Has type: `(Num, Bool)`.
  Value: `(2, True)`.
  
  Processing `(Just 7, False, 12, (3, True)) : (Maybe Num, Bool, Num, (Num, Bool))`.
  Parsed: `id{ (Maybe Num, Bool, Num, (Num, Bool)) } (Just 7, False, 12, (3, True))`.
  Has type: `(Maybe Num, Bool, Num, (Num, Bool))`.
  Value: `(Just 7, False, 12, (3, True))`.
  
  Processing `(3, [ 5 ], Nothing{ [ (Num, Num) ] }) : (Num, [ Num ], Maybe [ ( Num, Num ) ])`.
  Parsed: `id{ (Num, [ Num ], Maybe [ (Num, Num) ]) } (3, [ 5 ], Nothing{ [ (Num, Num) ] })`.
  Has type: `(Num, [ Num ], Maybe [ (Num, Num) ])`.
  Value: `(3, [ 5 ], Nothing)`.
  
  Processing `x : Num ~ 1`.
  Parsed: `(x : Num) ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num, y : Bool) ~ 1`.
  Parsed: `((x : Num), (y : Bool)) ~ 1`.
  Has type: `(Num, Bool) -> Num`.
  Value: `<fun>`.
  
  Processing `_ : [ Num ] ~ 1`.
  Parsed: `(_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `3 ~ 1`.
  Parsed: `{(==) 3} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing ``(3 + 4) ~ 1`.
  Parsed: `{(==) (3 + 4)} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `7 ~ 1`.
  Parsed: `{(==) 7} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num) :: (xs : [ Num ]) ~ 1`.
  Parsed: `Cons (x : Num) (xs : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `{_ > 5} ~ 1`.
  Parsed: `{flip (>) 5} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num) and {_ > 5} ~ 1`.
  Parsed: `(x : Num) and {flip (>) 5} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num) and `{x > 5} ~ 1`.
  Parsed: `(x : Num) and `{x > 5} ~ 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `3 :: (_ : [ Num ]) ~ 1`.
  Parsed: `Cons {(==) 3} (_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing ``(1 + 2) :: (_ : [ Num ]) ~ 1`.
  Parsed: `Cons {(==) (1 + 2)} (_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `{_ == 3} :: (_ : [ Num ]) ~ 1`.
  Parsed: `Cons {flip (==) 3} (_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `((x : Num) and `{x == 3}) :: (_ : [ Num ]) ~ 1`.
  Parsed: `Cons ((x : Num) and `{x == 3}) (_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `(x : Num) :: (_ : [ Num ]) and `{x == 3} ~ 1`.
  Parsed: `(Cons (x : Num) (_ : [ Num ])) and `{x == 3} ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing ``(1 + 2) :: (_ : [ Num ]) ~ 1`.
  Parsed: `Cons {(==) (1 + 2)} (_ : [ Num ]) ~ 1`.
  Has type: `[ Num ] -> Num`.
  Value: `<fun>`.
  
  Processing `x : Num ~ x + 1`.
  Parsed: `(x : Num) ~ x + 1`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `1 ~ 0`.
  Parsed: `{(==) 1} ~ 0`.
  Has type: `Num -> Num`.
  Value: `<fun>`.
  
  Processing `x : Num ~ 5 ~ x + 2`.
  Parsed: `(x : Num) ~ {(==) 5} ~ x + 2`.
  Has type: `Num -> Num -> Num`.
  Value: `<fun>`.
  
  Processing `x : Num | 5 ~ x + 2`.
  Parsed: `(x : Num) | {(==) 5} ~ x + 2`.
  Has type: `Num -> Num -> Num`.
  Value: `<fun>`.
  
  Processing `giggles : Num -> Num = fun ({_ =< 0} ~ 1) (n : Num ~ giggles (n - 1))`.
  Parsed: `giggles : Num -> Num = ({flip (=<) 0} ~ 1) <+ ((n : Num) ~ giggles (n - 1))
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `giggles` has been created.
  
  Processing `mapNum : (Num -> Num) -> [ Num ] -> [ Num ] = fun (f : Num -> Num | (x : Num) :: (xs : [ Num ]) ~ f x :: mapNum f xs) (f : Num -> Num | _ : [ Num ] ~ [{ Num }])`.
  Parsed: `mapNum : (Num -> Num) -> [ Num ] -> [ Num ] = ((f : Num -> Num) | Cons (x : Num) (xs : [ Num ]) ~ f x :: mapNum f xs) <+ ((f : Num -> Num) | (_ : [ Num ]) ~ Nil{ Num })
  Has type: `(Num -> Num) -> [ Num ] -> [ Num ]`.
  Value; `<fun>`.
  Binding `mapNum` has been created.
  
  Processing `mapNum2 : (Num -> Num) -> [ Num ] -> [ Num ] = fun (f : Num -> Num | (x : Num) :: (xs : [ Num ]) ~ f x :: mapNum2 f xs) (_ : Num -> Num | _ : [ Num ] ~ [{ Num }])`.
  Parsed: `mapNum2 : (Num -> Num) -> [ Num ] -> [ Num ] = ((f : Num -> Num) | Cons (x : Num) (xs : [ Num ]) ~ f x :: mapNum2 f xs) <+ ((_ : Num -> Num) | (_ : [ Num ]) ~ Nil{ Num })
  Has type: `(Num -> Num) -> [ Num ] -> [ Num ]`.
  Value; `<fun>`.
  Binding `mapNum2` has been created.
  
  Processing `mapNum3 : (Num -> Num) -> [ Num ] -> [ Num ] = fun (_ : Num -> Num | [{ Num }] ~ [{ Num }]) (f : Num -> Num | (x : Num) :: (xs : [ Num ]) ~ f x :: mapNum3 f xs)`.
  Parsed: `mapNum3 : (Num -> Num) -> [ Num ] -> [ Num ] = ((_ : Num -> Num) | Nil{ Num } ~ Nil{ Num }) <+ ((f : Num -> Num) | Cons (x : Num) (xs : [ Num ]) ~ f x :: mapNum3 f xs)
  Has type: `(Num -> Num) -> [ Num ] -> [ Num ]`.
  Value; `<fun>`.
  Binding `mapNum3` has been created.
  
  Processing `mapNum4 : (Num -> Num) -> [ Num ] -> [ Num ] = fun (_ : Num -> Num | [{ Num }] ~ [{ Num }]) (f : Num -> Num ~ (x : Num) :: (xs : [ Num ]) ~ f x :: mapNum4 f xs)`.
  Parsed: `mapNum4 : (Num -> Num) -> [ Num ] -> [ Num ] = ((_ : Num -> Num) | Nil{ Num } ~ Nil{ Num }) <+ ((f : Num -> Num) ~ Cons (x : Num) (xs : [ Num ]) ~ f x :: mapNum4 f xs)
  Has type: `(Num -> Num) -> [ Num ] -> [ Num ]`.
  Value; `<fun>`.
  Binding `mapNum4` has been created.
  
  Processing `poly-pair : (a : *) => a -> (b : *) => b -> (a, b) = (a : *) => x : a ~ (b : *) => y : b ~ (x, y)`.
  Parsed: `poly-pair : (a : *) => a -> (b : *) => b -> (a, b) = (a : *) => (x : a) ~ (b : *) => (y : b) ~ (x, y)
  Has type: `(a : *) => a -> (b : *) => b -> (a, b)`.
  Value; `<fun>`.
  Binding `poly-pair` has been created.
  
  Processing `mapPoly : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => fun (_ : a -> b | [{ a }] ~ [{ b }]) (f : a -> b ~ (x : a) :: (xs : [ a ]) ~ f x :: mapPoly f xs)`.
  Parsed: `mapPoly : (a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ] = (a : *) => (b : *) => ((_ : a -> b) | Nil{ a } ~ Nil{ b }) <+ ((f : a -> b) ~ Cons (x : a) (xs : [ a ]) ~ f x :: mapPoly f xs)
  Has type: `(a : *) => (b : *) => (a -> b) -> [ a ] -> [ b ]`.
  Value; `<fun>`.
  Binding `mapPoly` has been created.
  
  Processing `fff : (b : *) => (a : *) => a -> b = (b : *) => (a : *) => x : a ~ fff{ b } x`.
  Parsed: `fff : (b : *) => (a : *) => a -> b = (b : *) => (a : *) => (x : a) ~ fff{ b } x
  Has type: `(b : *) => (a : *) => a -> b`.
  Value; `<fun>`.
  Binding `fff` has been created.
  
  Processing `f : (a : *) => (Num -> a) -> Num -> a = (a : *) => g : Num -> a ~ fun (0 ~ g 1) (n : Num ~ f (m : Num ~ g (m * n)) (n - 1))`.
  Parsed: `f : (a : *) => (Num -> a) -> Num -> a = (a : *) => (g : Num -> a) ~ ({(==) 0} ~ g 1) <+ ((n : Num) ~ f ((m : Num) ~ g (m * n)) (n - 1))
  Has type: `(a : *) => (Num -> a) -> Num -> a`.
  Value; `<fun>`.
  Binding `f` has been created.
  
  Processing `f id{ Num } 3`.
  Parsed: `f (id{ Num }) 3`.
  Has type: `Num`.
  Value: `6`.
  
  Processing `id{ [ [ Num ] ] } (mapPoly{ Num, [ Num ] } (id{ Num -> [ Num ] } list{ Num }) [ 5, 2, 1 ]) where (list : (a : *) => a -> [ a ]) = (a : *) => x : a ~ [ x ]`.
  Parsed: `let (list : (a : *) => a -> [ a ]) = ((a : *) => (x : a) ~ [ x ]) in id{ [ [ Num ] ] } (mapPoly{ Num, [ Num ] } (id{ Num -> [ Num ] } (list{ Num })) [ 5, 2, 1 ])`.
  Has type: `[ [ Num ] ]`.
  Value: `[ [ 5 ], [ 2 ], [ 1 ] ]`.
  
  Processing `fac : Num -> Num = fac-core 1 where (fac-core : Num -> Num -> Num) = acc : Num ~ fun (0 ~ acc) (n : Num ~ fac-core (n * acc) (n - 1))`.
  Parsed: `fac : Num -> Num = let (fac-core : Num -> Num -> Num) = ((acc : Num) ~ ({(==) 0} ~ acc) <+ ((n : Num) ~ fac-core (n * acc) (n - 1))) in fac-core 1
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fac` has been created.
  
  Processing `concat : (a : *) => [ a ] -> [ a ] -> [ a ] = (a : *) => xs : [ a ] ~ ys : [ a ] ~ loop xs where (loop : [ a ] -> [ a ]) = fun ([{ a }] ~ ys) ((x : a) :: (xs : [ a ]) ~ x :: loop xs)`.
  Parsed: `concat : (a : *) => [ a ] -> [ a ] -> [ a ] = (a : *) => (xs : [ a ]) ~ (ys : [ a ]) ~ let (loop : [ a ] -> [ a ]) = ((Nil{ a } ~ ys) <+ (Cons (x : a) (xs : [ a ]) ~ x :: loop xs)) in loop xs
  Has type: `(a : *) => [ a ] -> [ a ] -> [ a ]`.
  Value; `<fun>`.
  Binding `concat` has been created.
  
  Processing `reverse : (a : *) => [ a ] -> [ a ] = (a : *) => loop where (loop : [ a ] -> [ a ]) = fun ([{ a }] ~ [{ a }]) ((x : a) :: (xs : [ a ]) ~ concat (loop xs) [ x ])`.
  Parsed: `reverse : (a : *) => [ a ] -> [ a ] = (a : *) => let (loop : [ a ] -> [ a ]) = ((Nil{ a } ~ Nil{ a }) <+ (Cons (x : a) (xs : [ a ]) ~ concat (loop xs) [ x ])) in loop
  Has type: `(a : *) => [ a ] -> [ a ]`.
  Value; `<fun>`.
  Binding `reverse` has been created.
  
  Processing `run-tests : (a : *) => (b : *) => (a -> b) -> [ (a, b) ] -> Bool = (a : *) => (b : *) => f : a -> b ~ loop True where (loop : Bool -> [ (a, b) ] -> Bool) = rsf : Bool ~ fun ([{ (a, b) }] ~ rsf) ((x : a, y : b) :: (ps : [ (a, b) ]) ~ loop rsf' ps where (rsf' : Bool) = y == f x and rsf )`.
  Parsed: `run-tests : (a : *) => (b : *) => (a -> b) -> [ (a, b) ] -> Bool = (a : *) => (b : *) => (f : a -> b) ~ let (loop : Bool -> [ (a, b) ] -> Bool) = ((rsf : Bool) ~ (Nil{ (a, b) } ~ rsf) <+ (Cons ((x : a), (y : b)) (ps : [ (a, b) ]) ~ let (rsf' : Bool) = ((True ~ rsf) <+ (False ~ False)) (y == f x) in loop rsf' ps)) in loop True
  Has type: `(a : *) => (b : *) => (a -> b) -> [ (a, b) ] -> Bool`.
  Value; `<fun>`.
  Binding `run-tests` has been created.
  
  Processing `run-tests reverse{ Num } [ ([{ Num }], [{ Num }]), ([ 1 ], [ 1 ]), ([ 1, 2, 3 ], [ 3, 2, 1 ]), ([ 1, 1, 1 ], [ 1, 1, 1 ]) ]`.
  Parsed: `run-tests (reverse{ Num }) [ (Nil{ Num }, Nil{ Num }), ([ 1 ], [ 1 ]), ([ 1, 2, 3 ], [ 3, 2, 1 ]), ([ 1, 1, 1 ], [ 1, 1, 1 ]) ]`.
  Has type: `Bool`.
  Value: `True`.
  
  Processing `fib : Num -> Num = fun ({_ > 1} and (n : Num) ~ fib (n - 2) + fib (n - 1)) (_ : Num ~ 1)`.
  Parsed: `fib : Num -> Num = ({flip (>) 1} and (n : Num) ~ fib (n - 2) + fib (n - 1)) <+ ((_ : Num) ~ 1)
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib` has been created.
  
  Processing `{ 1 |-> 3, 2 |-> 7 }`.
  Parsed: `list->map [ (1, 3), (2, 7) ]`.
  Has type: `Map Num Num`.
  Value: `<map(1 |-> 3, 2 |-> 7)>`.
  
  Processing `fib-memo : Num -> Num = fun (0 ~ 0) (n : Num ~ fib-core ({ n |-> 0 } <+> 1 |-> 1) n) where (fib-core : Map Num Num -> Num -> Num) = memo : Map Num Num ~ n : Num ~ case memo >+> n of (Just (f : Num) ~ f) (Nothing{ Num } ~ fib-core (memo <+> n |-> f) n where (f : Num) = fib-core memo (n - 2) + fib-core memo (n - 1) )`.
  Parsed: `fib-memo : Num -> Num = let (fib-core : Map Num Num -> Num -> Num) = ((memo : Map Num Num) ~ (n : Num) ~ ((Just (f : Num) ~ f) <+ (Nothing{ Num } ~ let (f : Num) = (fib-core memo (n - 2) + fib-core memo (n - 1)) in fib-core (memo <+> (n |-> f)) n)) (memo >+> n)) in ({(==) 0} ~ 0) <+ ((n : Num) ~ fib-core (list->map [ (n, 0) ] <+> (1 |-> 1)) n)
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib-memo` has been created.
  
  Processing `fib-memo' : Num -> Num = fun (0 ~ 0) (1 ~ 1) (n : Num ~ fib-core ({ 0 |-> 0 } <+> 1 |-> 1) n) where (fib-core : Map Num Num -> Num -> Num) = memo : Map Num Num ~ n : Num ~ case memo >+> n of (Just (f : Num) ~ f) (Nothing{ Num } ~ fib-core (memo <+> n |-> f) n where (f : Num) = fib-core memo (n - 2) + fib-core memo (n - 1) )`.
  Parsed: `fib-memo' : Num -> Num = let (fib-core : Map Num Num -> Num -> Num) = ((memo : Map Num Num) ~ (n : Num) ~ ((Just (f : Num) ~ f) <+ (Nothing{ Num } ~ let (f : Num) = (fib-core memo (n - 2) + fib-core memo (n - 1)) in fib-core (memo <+> (n |-> f)) n)) (memo >+> n)) in ({(==) 0} ~ 0) <+ ({(==) 1} ~ 1) <+ ((n : Num) ~ fib-core (list->map [ (0, 0) ] <+> (1 |-> 1)) n)
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib-memo'` has been created.
  
  Processing `fib-memo'' : Num -> Num = fun (0 ~ 0) (1 ~ 1) (n : Num ~ fib-core { 0 |-> 0, 1 |-> 1 } n) where (fib-core : Map Num Num -> Num -> Num) = memo : Map Num Num ~ n : Num ~ case memo >+> n of (Just (f : Num) ~ f) (Nothing{ Num } ~ fib-core (memo <+> n |-> f) n where (f : Num) = fib-core memo (n - 2) + fib-core memo (n - 1) )`.
  Parsed: `fib-memo'' : Num -> Num = let (fib-core : Map Num Num -> Num -> Num) = ((memo : Map Num Num) ~ (n : Num) ~ ((Just (f : Num) ~ f) <+ (Nothing{ Num } ~ let (f : Num) = (fib-core memo (n - 2) + fib-core memo (n - 1)) in fib-core (memo <+> (n |-> f)) n)) (memo >+> n)) in ({(==) 0} ~ 0) <+ ({(==) 1} ~ 1) <+ ((n : Num) ~ fib-core (list->map [ (0, 0), (1, 1) ]) n)
  Has type: `Num -> Num`.
  Value; `<fun>`.
  Binding `fib-memo''` has been created.
  
  Successfully loaded `/home/royal/royal/projects/motmot-lite/dist/Examples.mot`; created bindings `concat`, `f`, `fac`, `fff`, `fib`, `fib-memo`, `fib-memo'`, `fib-memo''`, `giggles`, `mapNum`, `mapNum2`, `mapNum3`, `mapNum4`, `mapPoly`, `poly-pair`, `reverse`, `run-tests`.
  
  #> Goodbye!
