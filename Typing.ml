(* MotmotLite: A Motmotastic Linguistic Toy

   Copyright 2023 -- 2024, K.D.P.Ross <KDPRoss@gmail.com>

MotmotLite is released under the MotmotLite Licence with the
following terms:
- MotmotLite may be used for amusement and study.
- MotmotLite may be extended for similar purposes, provided
  that the changes involved in doing so are publicly
  released and licensed under the same terms.
- MotmotLite may only be used if you have joy and kindness
  in your thoughts.

   'When we agree about our hallucinations,
    we call that reality.' -- A.Seth

   'Be kind to yourself, and
    the world is your playground.'-KDP
 *)

(* Generated by           *
 *             CamlTrax   *
 *                     NG *
 *                        *
 * Copyright 2007-2024    *
 *             K.D.P.Ross *)

open Util
open Syntax
open Env.Convenience

let tBool = TCVal ("Bool", [])

exception TypeAbort
exception TypeError

let typeError (s : string) =
  let _ = match s with "" -> () | _ -> print_endline s in
  raise TypeError

let baseTermConsEnv parseTyp =
  let assumps =
    [
      ("Cons", parseTyp "(a : *) => a -> List a -> List a");
      ("False", parseTyp "Bool");
      ("Just", parseTyp "(a : *) => a -> Maybe a");
      ("Nil", parseTyp "(a : *) => List a");
      ("Nothing", parseTyp "(a : *) => Maybe a");
      ("True", parseTyp "Bool");
    ]
  in
  match PolyMap.of_alist assumps with
  | `Duplicate_key k ->
      failwith
        ("Duplicate key for `" -- k
       -- "` in `baseTermConsEnv`; this is an implementation error.")
  | `Ok m -> Env.ofMap m

let baseKindEnv parseKnd =
  let assumps =
    [
      ("->", parseKnd "* -> * -> *");
      ("Bool", parseKnd "*");
      ("List", parseKnd "* -> *");
      ("Map", parseKnd "* -> * -> *");
      ("Maybe", parseKnd "* -> *");
      ("Num", parseKnd "*");
    ]
  in
  match PolyMap.of_alist assumps with
  | `Duplicate_key k ->
      failwith
        ("Duplicate key for `" -- k
       -- "` in `baseKindEnv`; this is an implementation error.")
  | `Ok m -> Env.ofMap m

let checkUniqueNames (msgGen : string -> string) (xs : string list) : bool =
  let f (seen, duped) x =
    if StringSet.mem seen x then (seen, x :: duped)
    else (StringSet.add seen x, duped)
  in
  match snd (List.fold ~f ~init:(StringSet.empty, []) xs) with
  | [] -> true
  | xs ->
      let _ =
        xs &> nub @> concatMap (around "`" "`") ", " @> msgGen @> print_endline
      in
      false

let freshVar (_ : unit) : string =
  let prefix = "^G." in
  () &> gensym @> string_of_int @> ( -- ) prefix

let freeVars : typ -> string list =
  let rec core = function
    | TVar x -> [ x ]
    | TAbs (x, _, t) -> t &> core @> List.filter ~f:(( <> ) x)
    | TCVal (_, ts) | TTpl ts -> List.concat_map ~f:core ts
    | TArr (t, t') | TApp (t, t') -> core t @ core t'
  in
  core @> nub

let rec substType (x : string) (t : typ) : typ -> typ =
 (function
 | TVar y when y = x -> t
 | TAbs (y, k, t') when y <> x -> TAbs (y, k, substType x t t')
 | TCVal (c, ts) ->
     let ts' = List.map ~f:(substType x t) ts in
     TCVal (c, ts')
 | TArr (t1, t2) -> TArr (substType x t t1, substType x t t2)
 | TApp (t1, t2) -> TApp (substType x t t1, substType x t t2)
 | TTpl ts ->
     let ts' = List.map ~f:(substType x t) ts in
     TTpl ts'
 | t -> t)

let substType (x : string) (t : typ) (t' : typ) : typ =
  let xs = t &> freeVars @> StringSet.of_list in
  let rec loop = function
    | TAbs (y, k, t') when StringSet.mem xs y ->
        let y' = freshVar () in
        let t'' = t' &> substType y (TVar y') @> loop in
        TAbs (y', k, t'')
    | TAbs (y, k, t') -> TAbs (y, k, loop t')
    | TCVal (c, ts) -> TCVal (c, List.map ~f:loop ts)
    | TTpl ts -> TTpl (List.map ~f:loop ts)
    | TArr (t, t') -> TArr (loop t, loop t')
    | TApp (t, t') -> TApp (loop t, loop t')
    | t -> t
  in
  t' &> loop @> substType x t

let rec kindOf (showTyp : typ -> string) (d : knd Env.t) (g : knd Env.t) :
    typ -> knd =
  let kindOf = kindOf showTyp in
  function
  | TVar "_" -> typeError "Invalid type placeholder."
  | TVar x -> (
      match g ==> x with
      | Some k -> k
      | None -> typeError ("No kind for variable `" -- showTyp (TVar x) -- "`.")
      )
  | TAbs (x, k, t) ->
      let g' = g <+> x @-> k in
      kindOf d g' t
  | TCVal (c, ts) -> (
      match d ==> c with
      | Some k ->
          let tks = List.map ~f:(fun t -> (t, kindOf d g t)) ts in
          let rec handleArgs k' =
           (function
           | [] -> k'
           | (t, k) :: tks -> (
               match k' with
               | KArr (k1, k2) when k = k1 -> handleArgs k2 tks
               | KArr (k1, _) ->
                   typeError
                     ("Kind error in tycon `" -- c
                    -- "` application: Formal argument `"
                    -- CoreLineariser.showKnd k1
                    -- "` does not match actual argument `" -- showTyp t
                    -- " : " -- CoreLineariser.showKnd k -- "`.")
               | KStar ->
                   typeError ("Too many type arguments to tycon `" -- c -- "`.")
               ))
          in
          handleArgs k tks
      | None ->
          typeError
            ("No kind for type constructor `" -- showTyp (TCVal (c, [])) -- "`.")
      )
  | TArr (t, t') -> (
      match (kindOf d g t, kindOf d g t') with
      | KStar, KStar -> KStar
      | KStar, k' ->
          typeError
            ("Kind error in function-type codomain type `" -- showTyp t'
           -- " : " -- CoreLineariser.showKnd k' -- "`; should be `"
            -- CoreLineariser.showKnd KStar
            -- "`.")
      | k, KStar ->
          typeError
            ("Kind error in function-type domain type `" -- showTyp t -- " : "
           -- CoreLineariser.showKnd k -- "`; should be `"
            -- CoreLineariser.showKnd KStar
            -- "`.")
      | k, k' ->
          typeError
            ("Kind error in function-type domain type `" -- showTyp t -- " : "
           -- CoreLineariser.showKnd k -- "`; `" -- showTyp t' -- " : "
           -- CoreLineariser.showKnd k' -- "`; both should be `"
            -- CoreLineariser.showKnd KStar
            -- "`."))
  | TApp (t, t') -> (
      match (kindOf d g t, kindOf d g t') with
      | KArr (k1, k2), k1' when k1 = k1' -> k2
      | KArr (k1, _), k1' ->
          typeError
            ("Kind mismatch: Domain kind `" -- CoreLineariser.showKnd k1
           -- "` should match argument kind `" -- CoreLineariser.showKnd k1'
           -- "`.")
      | KStar, _ ->
          typeError
            ("Kind error: Cannot apply something of kind `"
            -- CoreLineariser.showKnd KStar
            -- "` (" -- showTyp t -- ")."))
  | TTpl ts -> (
      let tksBad =
        ts
        &> List.map ~f:(fun t -> (t, kindOf d g t))
           @> List.filter ~f:(snd @> ( <> ) KStar)
      in
      match tksBad with
      | [] -> KStar
      | _ ->
          let showOne (t, k) =
            "`" -- showTyp t -- " : " -- CoreLineariser.showKnd k -- "`"
          in
          typeError
            ("Tuple types should have kind `"
            -- CoreLineariser.showKnd KStar
            -- "`; the following types do not:"
            -- concatMap showOne ", " tksBad
            -- "."))

let rec canApply (showTyp : typ -> string) (d : knd Env.t) (g : knd Env.t)
    (k : knd) (t : typ) : bool =
  let canApply = canApply showTyp in
  let kindOf = kindOf showTyp in
  match k with
  | KStar -> KStar = kindOf d g t
  | KArr (k1, k2) -> (
      match t with
      | _ when k = kindOf d g t -> true
      | TAbs (x, k, t) when k1 = k ->
          let g' = g <+> x @-> k in
          canApply d g' k2 t
      | _ -> false)

let rec reduceType (showTyp : typ -> string) (closed : bool) (d : knd Env.t)
    (g : knd Env.t) (t : typ) : typ =
  let reduceType = reduceType showTyp closed in
  let canApply = canApply showTyp in
  match t with
  | TCVal ("->", [ t1; t2 ]) -> reduceType d g (TArr (t1, t2))
  | TAbs (x, k, t) ->
      let g' = g <+> x @-> k in
      TAbs (x, k, reduceType d g' t)
  | TCVal (c, ts) ->
      let ts' = List.map ~f:(reduceType d g) ts in
      TCVal (c, ts')
  | TArr (t, t') -> TArr (reduceType d g t, reduceType d g t')
  | TApp (t, t') -> (
      let tRed = reduceType d g t in
      match tRed with
      | TAbs (x, k, t) ->
          let _ =
            if closed && not (canApply d g k t') then
              typeError
                ("Kind mismatch in application-type reduction: Formal `"
               -- CoreLineariser.showKnd k -- "` with actual type `"
               -- showTyp t' -- "`.")
          in
          t &> substType x t' @> reduceType d g
      | TCVal (c, ts) -> reduceType d g (TCVal (c, ts @ [ t' ]))
      | t -> TApp (t, reduceType d g t'))
  | TTpl ts ->
      let ts' = List.map ~f:(reduceType d g) ts in
      TTpl ts'
  | t -> t

let rec solidType (showTyp : typ -> string) (fs : StringSet.t) : typ -> bool =
  let solidType = solidType showTyp in
  function
  | TVar "_" -> false
  | TVar x -> not (StringSet.mem fs x)
  | TAbs (_, _, t) -> solidType fs t
  | TCVal (_, ts) | TTpl ts -> List.for_all ~f:(solidType fs) ts
  | TArr (t, t') | TApp ((TVar _ as t), t') -> solidType fs t && solidType fs t'
  | TApp _ as t ->
      typeError ("Invalid application in `solid-type`: `" -- showTyp t -- "`.")

type 'a diffSt = string Env.t -> 'a * string Env.t

let showDiffTypes _ _ _ : unit = ()

let unify (showTyp : typ -> string) (fs : StringSet.t) (d : knd Env.t)
    (g : knd Env.t) (bigG : typ Env.t) (t1 : typ) (t2 : typ) : typ Env.t =
  let typeError s =
    let _ = showDiffTypes showTyp t1 t2 in
    typeError s
  in
  let rec unify (fs : StringSet.t) (s : typ Env.t) (t : typ) (t' : typ) :
      typ Env.t =
    let reduceType t =
      let rec handlePlaceholderApp = function
        | TApp (TVar "_", t) -> Some [ t ]
        | TApp (t, t') -> (
            match handlePlaceholderApp t with
            | Some ts -> Some (ts @ [ t' ])
            | None -> None)
        | _ -> None
      in
      let t' = reduceType showTyp false d g t in
      match handlePlaceholderApp t' with
      | Some ts -> TCVal ("_", ts)
      | None -> t'
    in
    let tl = reduceType t in
    let tr = reduceType t' in
    match (tl, tr) with
    | _ when tl = tr -> s
    | TVar "_", _ | _, TVar "_" -> s
    | TVar x, t when StringSet.mem fs x -> (
        match s ==> x with
        | Some t' ->
            if t <> t' then
              typeError
                ("Unification failure for `" -- showTyp t -- "` and `"
               -- showTyp t' -- "`.")
            else s
        | None -> s <+> x @-> t)
    | t, TVar x when StringSet.mem fs x -> (
        match s ==> x with
        | Some t' ->
            if t <> t' then
              typeError
                ("Unification failure for `" -- showTyp t -- "` and `"
               -- showTyp t' -- "`.")
            else s
        | None -> s <+> x @-> t)
    | TAbs (x, k, t), TAbs (x', k', t') ->
        if k <> k' then
          typeError
            ("Kind error when unifying universal types: `"
           -- CoreLineariser.showKnd k -- "` and `" -- CoreLineariser.showKnd k'
           -- "`.")
        else
          let x'' = freshVar () in
          let t = substType x (TVar x'') t in
          let t' = substType x' (TVar x'') t' in
          unify fs s t t'
    | TCVal (c, ts), TCVal (c', ts') ->
        if c = c' || "_" = c' then unify fs s (TTpl ts) (TTpl ts')
        else
          typeError
            ("Mismatched constructors when unifying types: `" -- c -- "` and `"
           -- c' -- "`.")
    | TApp (t1, t2), TCVal (c, ts) -> (
        match List.rev ts with
        | t :: ts ->
            let s' = unify fs s t1 (TCVal (c, List.rev ts)) in
            unify fs s' t2 t
        | [] ->
            typeError
              ("App-cons shape mismatch for `" -- showTyp tl -- "` (app) and `"
             -- showTyp tr -- "` (cval)."))
    | TCVal (c, ts), TApp (t1, t2) -> (
        match List.rev ts with
        | t :: ts ->
            let s' = unify fs s t1 (TCVal (c, List.rev ts)) in
            unify fs s' t2 t
        | [] ->
            typeError
              ("App-cons shape mismatch for `" -- showTyp tl -- "` (cval) and `"
             -- showTyp tr -- "` (app)."))
    | TArr (t1, t2), TApp (TApp (TVar x, t1'), t2')
    | TApp (TApp (TVar x, t1'), t2'), TArr (t1, t2) ->
        let s' = s <+> x @-> TCVal ("->", []) in
        let s'' = unify fs s' t1 t1' in
        unify fs s'' t2 t2'
    | TArr (t1, t2), TArr (t1', t2') | TApp (t1, t2), TApp (t1', t2') ->
        let s' = unify fs s t1 t1' in
        unify fs s' t2 t2'
    | TTpl [], TTpl [] -> s
    | TTpl (t :: ts), TTpl (t' :: ts') ->
        let s' = unify fs s t t' in
        unify fs s' (TTpl ts) (TTpl ts')
    | _ ->
        typeError
          ("General unification failure with types `" -- showTyp t -- "` and `"
         -- showTyp t' -- "`.")
  in
  unify fs bigG t1 t2

let freshen : typ -> string list * typ =
  let rec freshen fs =
   (function
   | TAbs (x, _, t) ->
       let x' = freshVar () in
       let t' = substType x (TVar x') t in
       let fs' = x' :: fs in
       freshen fs' t'
   | t -> (List.rev fs, t))
  in
  freshen []

let applySubst (s : typ Env.t) : typ -> typ =
  let rec loop = function
    | TVar x as t -> ( match s ==> x with Some t -> t | None -> t)
    | TAbs (x, k, t) -> TAbs (x, k, loop t)
    | TCVal (c, ts) ->
        let ts' = List.map ~f:loop ts in
        TCVal (c, ts')
    | TArr (t, t') -> TArr (loop t, loop t')
    | TApp (t, t') -> TApp (loop t, loop t')
    | TTpl ts ->
        let ts' = List.map ~f:loop ts in
        TTpl ts'
  in
  loop

let typEquiv (showTyp : typ -> string) (d : knd Env.t) (g : knd Env.t) (t : typ)
    (t' : typ) : bool =
  let rec loop eqs t t' =
    match (t, t') with
    | TVar "_", _ | _, TVar "_" -> typeError "Invalid type placeholder."
    | TVar x, TVar y ->
        let mem = List.mem ~equal:( = ) in
        let xs, ys = List.unzip eqs in
        if (not (mem xs x)) && not (mem ys y) then x = y else mem eqs (x, y)
    | TAbs (x, k, t), TAbs (x', k', t') -> k = k' && loop ((x, x') :: eqs) t t'
    | TCVal (c, ts), TCVal (c', ts') -> c = c' && loop eqs (TTpl ts) (TTpl ts')
    | TArr (t1, t2), TArr (t1', t2') -> loop eqs t1 t1' && loop eqs t2 t2'
    | TTpl [], TTpl [] -> true
    | TTpl (t :: ts), TTpl (t' :: ts') ->
        loop eqs t t' && loop eqs (TTpl ts) (TTpl ts')
    | TApp (t1, t2), TApp (t1', t2') -> loop eqs t1 t1' && loop eqs t2 t2'
    | _ -> false
  in
  loop [] (reduceType showTyp true d g t) (reduceType showTyp true d g t')

let handleApp (showTyp : typ -> string) (d : knd Env.t) (g : knd Env.t)
    (t : typ) (vts : (typ, typ) either list) : typ =
  let reduceType = reduceType showTyp in
  let unify = unify showTyp in
  let rec loopApp fs d g s t vts =
    match (t, vts) with
    | t, [] -> (t, fs, s)
    | t, Right t' :: vts ->
        let t'' = reduceType true d g (TApp (t, t')) in
        loopApp fs d g s t'' vts
    | TAbs (x, k, t), vts ->
        let x' = freshVar () in
        let t' = substType x (TVar x') t in
        let g' = g <+> x' @-> k in
        let fs' = StringSet.add fs x' in
        loopApp fs' d g' s t' vts
    | TArr (t, t'), Left t'' :: vts ->
        let s' = unify fs d g s t t'' in
        loopApp fs d g s' t' vts
    | _ ->
        let showOne = function
          | Left t -> " @ " -- showTyp t
          | Right t -> " /@ " -- showTyp t
        in
        typeError
          ("Invalid application reduction for `" -- showTyp t
         -- concatMap showOne "" vts -- "`")
  in
  let t, fs, s = loopApp StringSet.empty d g Env.empty t vts in
  let t' = reduceType true d g (applySubst s t) in
  let check f =
    match s ==> f with
    | Some _ -> ()
    | _ -> typeError ("Unification variable `" -- f -- "` was not resolved.")
  in
  if solidType showTyp fs t' then
    let _ = fs &> StringSet.to_list @> List.iter ~f:check in
    t'
  else
    typeError
      ("`handle-app` failed to resolve `" -- showTyp t
     -- "` to a solid type; got as far as `" -- showTyp t' -- "`.")

let rec rewritePipeline : exp -> exp =
  let rec extractPipeline = function
    | EApp (EApp (EVar ">>", e), e') | EApp (EApp (EVar "<<", e'), e) ->
        extractPipeline e @ extractPipeline e'
    | e -> [ rewritePipeline e ]
  in
  function
  | EApp (EApp (EVar "|>", x), e) | EApp (EApp (EVar "<|", e), x) ->
      let app x f = EApp (f, x) in
      e &> extractPipeline @> List.fold ~f:app ~init:x @> rewritePipeline
  | EApp (EApp (EApp (EVar "flip", f), e2), e1) ->
      EApp (EApp (f, e1), e2) &> rewritePipeline
  | EApp (e, e') -> EApp (rewritePipeline e, rewritePipeline e')
  | e -> e

let barePipeQ : exp -> bool = function
  | EApp (EApp (EVar ">>", _), _) | EApp (EApp (EVar "<<", _), _) -> true
  | _ -> false

let rec extractBarePipeline : exp -> exp list = function
  | EApp (EApp (EVar ">>", e1), e2) | EApp (EApp (EVar "<<", e2), e1) ->
      extractBarePipeline e1 @ extractBarePipeline e2
  | e -> [ e ]

let rec tApp : exp -> bool = function
  | ETApp (_, TVar "_") -> true
  | ETApp (e, _) -> tApp e
  | _ -> false

let unwindTApp : exp -> exp * typ list =
  let rec loop res =
   (function
   | ETApp (e, t) ->
       let e', ts = loop (t :: res) e in
       (e', ts)
   | e -> (e, res))
  in
  loop []

let rec unwindTAbs : typ -> typ * (string * knd) list = function
  | TAbs (x, k, t) ->
      let t', xks = unwindTAbs t in
      (t', (x, k) :: xks)
  | t -> (t, [])

let mixfixSpecs = Syntax.Mixfix.defaultSpecs

let typingFuncs (showTyp : typ -> string) =
  let noRepeatedVars print wrap err =
    let rec loop (seen : StringSet.t) : typ Env.t list -> unit =
     (function
     | g :: gs ->
         let domG = Env.domain g in
         let doubledVars = domG &> StringSet.inter seen @> StringSet.to_list in
         if [] <> doubledVars then
           let _ =
             doubledVars &> concatMap (around "`" "`") ", " @> wrap @> print
           in
           let _ = err () in
           loop seen gs
         else
           let seen' = StringSet.union seen domG in
           loop seen' gs
     | [] -> ())
    in
    loop StringSet.empty
  in
  let repeatedVarsErr =
    noRepeatedVars print_endline
      (around "Repeated variables: " ". (This list may not be exhaustive.)")
  in
  let shadowedVarsWarn gs = true in
  let rec typOf (d : knd Env.t) (g : knd Env.t) (bigD : typ Env.t)
      (bigG : typ Env.t) (e : exp) : typ =
    let handleApp = handleApp showTyp in
    let kindOf = kindOf showTyp in
    let reduceType = reduceType showTyp in
    let showDiffTypes = showDiffTypes showTyp in
    let typEquiv = typEquiv showTyp in
    let ( =~= ) t1 t2 = typEquiv d g t1 t2 in
    let handleApp d g t vts =
      try handleApp d g t vts
      with TypeError ->
        typeError ("Invalid application: `" -- CoreLineariser.showExp e -- "`.")
    in
    let canFlipHack = function
      | EApp (EApp (EApp (EVar "flip", EVar _), _), _) -> true
      | EApp (EApp (EVar "flip", EVar _), _) -> true
      | _ -> false
    in
    let flipHack e =
      match e with
      | EApp (EApp (EApp (_, e1), e2), e3) ->
          typOf d g bigD bigG (EApp (EApp (e1, e3), e2))
      | EApp (EApp (_, e1), e2) -> (
          let rec stripUniv = function
            | TAbs (x, k, t) ->
                let ps, t' = stripUniv t in
                ((x, k) :: ps, t')
            | t -> ([], t)
          and t1 = typOf d g bigD bigG e1
          and t2 = typOf d g bigD bigG e2 in
          match stripUniv t1 with
          | ps, TArr (ta, TArr (tb, t')) ->
              let t'' = TArr (tb, TArr (ta, t')) in
              let t''' =
                List.fold ~f:(fun t (x, k) -> TAbs (x, k, t)) ~init:t'' ps
              in
              handleApp d g t''' [ Left t2 ]
          | _ ->
              typeError
                ("Flip hack reached with invalid term `"
               -- CoreLineariser.showExp e -- "`."))
      | _ -> typOf d g bigD bigG e
    in
    let e = rewritePipeline e in
    let unwindPartialTApp e =
      let e', ts = unwindTApp e in
      let te = typOf d g bigD bigG e' in
      let te', xks = unwindTAbs te in
      let _ =
        if List.length ts > List.length xks then
          typeError "Too many types in `_` type application!"
      in
      let now, later = List.split_n xks (List.length ts) in
      let now', later' =
        List.zip_exn ts now
        &> List.partition_tf ~f:(fst @> ( = ) (TVar "_") @> not)
      in
      let later'' = List.map ~f:snd later' @ later in
      let checkOne (t, (x, k)) =
        let k' = kindOf d g t in
        if k <> k' then
          let _ =
            let core =
              [
                "Kind error when partially applying `" -- x -- "`.";
                "  `" -- showTyp t -- "` :: `" -- CoreLineariser.showKnd k'
                -- "`";
                "but it ought to have kind:";
                "  `" -- CoreLineariser.showKnd k -- "`";
              ]
            in
            List.iter ~f:print_endline core
          in
          typeError ""
      in
      let _ = List.iter ~f:checkOne now' in
      let te'' =
        List.fold_left ~init:te'
          ~f:(fun t (t', (x, _)) -> substType x t' t)
          now'
      in
      let te3 =
        List.fold_right ~init:te'' ~f:(fun (x, k) t -> TAbs (x, k, t)) later''
      in
      te3
    in
    match e with
    | _ when barePipeQ e -> (
        match extractBarePipeline e with
        | e1 :: _ -> (
            match typOf d g bigD bigG e1 with
            | TArr (t, _) ->
                let x = freshVar () in
                typOf d g bigD bigG
                  (EAbs ([ PVar (x, t) ], EApp (EApp (EVar "|>", EVar x), e)))
            | t ->
                typeError
                  ("Nonfunction type `" -- showTyp t
                 -- "` at head of bare pipeline."))
        | [] -> typeError "Invalid bare pipeline.")
    | _ when canFlipHack e -> flipHack e
    | EVar x -> (
        let x = x in
        match bigG ==> x with
        | Some t -> t
        | None ->
            typeError
              ("No type for variable `" -- CoreLineariser.showExp e -- "`."))
    | ETAbs (x, k, e) -> (
        let g' = g <+> x @-> k in
        let t = typOf d g' bigD bigG e in
        match kindOf d g' t with
        | KStar -> TAbs (x, k, t)
        | k ->
            let _ =
              let core =
                [
                  "Kind error when constructing universal type:";
                  "  `" -- showTyp t -- "` :: `" -- CoreLineariser.showKnd k
                  -- "`";
                  "but it ought to have kind:";
                  "  `" -- CoreLineariser.showKnd KStar -- "`";
                ]
              in
              List.iter ~f:print_endline core
            in
            typeError "")
    | EAbs (ps, e) ->
        let rec loop bigG =
         (function
         | [] -> ([], bigG)
         | p :: ps ->
             let t, bigG' = typOfPat d g bigD bigG None p in
             let gs = [ bigG'; bigG ] in
             let bigG'' = smashEnvs gs in
             let _ = shadowedVarsWarn gs in
             let ts, bigG''' = loop bigG'' ps in
             (reduceType true d g t :: ts, bigG'''))
        in
        let ts, bigG' = loop bigG ps in
        let t = typOf d g bigD bigG' e in
        List.fold_right ~f:(fun t t' -> TArr (t, t')) ~init:t ts
    | e when tApp e -> unwindPartialTApp e
    | ETApp (e, t) ->
        let t' = typOf d g bigD bigG e in
        reduceType true d g (TApp (t', t))
    | ETup es ->
        let ts = List.map ~f:(typOf d g bigD bigG) es in
        TTpl ts
    | EFcmp fs -> (
        let checkOne t t' =
          if not (t =~= t') then
            let t = reduceType true d g t in
            let t' = reduceType true d g t' in
            let _ =
              let core =
                [
                  "Mismatched types in partial-function composition:";
                  "  `" -- showTyp t -- "`";
                  "vs";
                  "  `" -- showTyp t' -- "`";
                ]
              in
              List.iter ~f:print_endline core
            in
            let _ = showDiffTypes t t' in
            typeError ""
        in
        let ts = List.map ~f:(typOf d g bigD bigG) fs in
        match ts with
        | [] -> typeError "Empty partial-function composition cannot be typed!"
        | t :: ts ->
            let _ = List.iter ~f:(checkOne t) ts in
            let _ =
              match t with
              | TArr _ -> ()
              | _ ->
                  let _ =
                    let core =
                      [
                        "Only arrow types are allowed in partial-function \
                         composition; received:";
                        "  `" -- showTyp t -- "`";
                      ]
                    in
                    List.iter ~f:print_endline core
                  in
                  typeError ""
            in
            t)
    | ECVal (c, es) -> (
        let ts = List.map ~f:(typOf d g bigD bigG) es in
        let left t = Left t in
        let ts' = List.map ~f:left ts in
        match bigD ==> c with
        | Some t -> handleApp d g t ts'
        | None ->
            typeError
              ("No type found for term constructor `"
              -- CoreLineariser.showExp (ECVal (c, []))
              -- "`."))
    | EApp _ -> (
        let rec unwindApp (e : exp) : (typ, typ) either list =
          match e with
          | _ when tApp e ->
              let t = unwindPartialTApp e in
              [ Left t ]
          | EApp (e, e') ->
              let t' = typOf d g bigD bigG e' in
              let es = unwindApp e in
              es @ [ Left t' ]
          | ETApp (e, t) ->
              let es = unwindApp e in
              es @ [ Right t ]
          | e ->
              let t = typOf d g bigD bigG e in
              [ Left t ]
        in
        match unwindApp e with
        | Left t :: vts -> handleApp d g t vts
        | _ ->
            typeError
              ("Unexpected application when trying to type `"
             -- CoreLineariser.showExp e -- "`."))
    | ELet (bts, e) ->
        let bts =
          let extract (p, e) =
            match p with
            | PVar (x, t) -> (x, t, e)
            | _ ->
                let _ =
                  let core =
                    [
                      "Destructuring pattern:";
                      "  `" -- CoreLineariser.showPat p -- "`";
                      "  ought to have been rewritten to irrefutable patterns; \
                       this is a Motmot-implementation error";
                    ]
                  in
                  List.iter ~f:print_endline core
                in
                typeError ""
          in
          let one (p, e) =
            try
              match restructureBindings d g bigD bigG (p, e) with
              | None, bts' -> bts'
              | Some (y, e), bts' ->
                  let t, _ = typOfPat d g bigD bigG None p in
                  (PVar (y, t), e) :: bts'
            with TypeError ->
              typeError ("Bad pattern `" -- CoreLineariser.showPat p -- "`.")
          in
          bts
          &> List.concat_map ~f:one @> List.map ~f:extract
             @> List.sort ~compare:(fun (x, _, _) (y, _, _) ->
                    Stdlib.compare x y)
        in
        let bigG' =
          List.fold
            ~f:(fun g' (x, t, _) -> g' <+> x @-> reduceType true d g t)
            ~init:bigG bts
        in
        let names = List.map ~f:(fun (x, _, _) -> x) bts in
        let checkOne (x, t, e) =
          try
            let t = reduceType true d g t in
            let _ =
              try
                match kindOf d g t with
                | KStar -> ()
                | k ->
                    let _ =
                      print_endline
                        ("Expected kind `"
                        -- CoreLineariser.showKnd KStar
                        -- "` for binding; received `"
                        -- CoreLineariser.showKnd k -- "`.")
                    in
                    raise TypeError
              with _ ->
                print_endline
                  ("Kind error when checking type `" -- showTyp t
                 -- "` for binding `" -- x -- "`.")
            in
            let t' = typOf d g bigD bigG' e in
            if not (t =~= t') then
              let _ =
                let t' = reduceType true d g t' in
                let core =
                  [
                    "Binding `" -- x -- "` was expected to have type:";
                    "  `" -- showTyp t -- "`";
                    "but was inferred to have type";
                    "  `" -- showTyp t' -- "`";
                    "with RHS";
                    "  `" -- CoreLineariser.showExp e -- "`";
                  ]
                in
                List.iter ~f:print_endline core
              in
              typeError ""
          with TypeError ->
            let _ =
              let core =
                [
                  "In recursive-binding context:";
                  bts
                  &> List.map ~f:(fun (x, _, _) -> x)
                     @> List.sort ~compare:Stdlib.compare
                     @> String.concat ~sep:", " @> ( -- ) "  ";
                ]
              in
              List.iter ~f:print_endline core
            in
            raise TypeAbort
        in
        let _ =
          if
            not
              (checkUniqueNames
                 (around "Names bound in a `let` must be unique; repeated: " ".")
                 names)
          then typeError ""
        in
        let _ = List.iter ~f:checkOne bts in
        typOf d g bigD bigG' e
    | ENum _ -> TCVal ("Num", [])
    | EList es -> (
        let ts = es &> List.map ~f:(typOf d g bigD bigG) @> nub in
        match ts with
        | [] -> typeError "Cannot type empty `EList`."
        | [ t ] -> TCVal ("List", [ t ])
        | ts ->
            let _ =
              "Mismatched list types:"
              :: (ts &> List.map ~f:(showTyp @> around "  `" "`"))
              &> List.iter ~f:print_endline
            in
            typeError "")
    | ECls _ | EDely _ | ELazy _ | ENatF _ | EMap _ ->
        typeError
          ("Cannot infer type for nonsyntactically-denotable term `"
         -- CoreLineariser.showExp e -- "`.")
  and typOfPat (d : knd Env.t) (g : knd Env.t) (bigD : typ Env.t)
      (bigG : typ Env.t) (tM : typ option) (p : pat) : typ * typ Env.t =
    let handleApp = handleApp showTyp in
    let reduceType = reduceType showTyp in
    let showDiffTypes = showDiffTypes showTyp in
    let typEquiv = typEquiv showTyp in
    let ( =~= ) t1 t2 = typEquiv d g t1 t2 in
    let handleApp d g t vts =
      try handleApp d g t vts
      with TypeError ->
        typeError ("Invalid application: `" -- CoreLineariser.showPat p -- "`.")
    in
    match p with
    | PAny t -> (t, Env.empty)
    | PVar (x, t) -> (t, Env.empty <+> x @-> reduceType true d g t)
    | PCVal ("Cons", [], [ p; PCVal ("Nil", [], []) ]) ->
        let t, g = typOfPat d g bigD bigG tM p in
        (TCVal ("List", [ t ]), g)
    | PCVal (c, ts, ps) -> (
        let ts', bigGs' =
          ps &> List.map ~f:(typOfPat d g bigD bigG tM) @> List.unzip
        in
        let _ = repeatedVarsErr (fun _ -> typeError "") bigGs' in
        let left t = Left t in
        let right t = Right t in
        match bigD ==> c with
        | Some t -> (
            let ts', bigGs' =
              ps &> List.map ~f:(typOfPat d g bigD bigG tM) @> List.unzip
            in
            let _ = repeatedVarsErr (fun _ -> typeError "") bigGs' in
            let bigG' = smashEnvs bigGs' in
            let tsSeq = List.map ~f:right ts @ List.map ~f:left ts' in
            let t' = handleApp d g t tsSeq in
            match t' with
            | TAbs _ ->
                let _ =
                  let core =
                    [
                      "Uninstantiated constructor type in pattern:";
                      "  at type";
                      "  `" -- showTyp t' -- "`";
                    ]
                  in
                  List.iter ~f:print_endline core
                in
                typeError ""
            | TCVal _ -> (t', bigG')
            | _ ->
                let _ =
                  let core =
                    [
                      "Unsaturated or unconstructor type in pattern:";
                      "  at type";
                      "  `" -- showTyp t' -- "`";
                    ]
                  in
                  List.iter ~f:print_endline core
                in
                typeError "")
        | None ->
            let _ =
              let core =
                [
                  "No type for term constructor:";
                  "  failed constructor";
                  "  `" -- CoreLineariser.showExp (ECVal (c, [])) -- "`.";
                ]
              in
              List.iter ~f:print_endline core
            in
            typeError "")
    | PTup ps ->
        let ts, gs =
          ps &> List.map ~f:(typOfPat d g bigD bigG tM) @> List.unzip
        in
        let _ = repeatedVarsErr (fun _ -> typeError "") gs in
        let g = smashEnvs gs in
        (TTpl ts, g)
    | PWhen (e, Some t) ->
        let te = typOf d g bigD bigG e in
        if tBool = te then (t, Env.empty)
        else typeError "Condition pattern must be `Bool`."
    | PWhen (e, None) -> (
        match tM with
        | Some t -> typOfPat d g bigD bigG tM (PWhen (e, Some t))
        | None -> typeError "Condition pattern must have a type annotation.")
    | PConj (PWhen (e, None), p) ->
        let te = typOf d g bigD bigG e in
        let tpg = typOfPat d g bigD bigG tM p in
        if tBool = te then tpg
        else typeError "Condition pattern must be `Bool`."
    | PConj (p1, p2) -> (
        let t1, g1 = typOfPat d g bigD bigG tM p1 in
        let t2, g2 = typOfPat d g bigD (Env.joinR bigG g1) (Some t1) p2 in
        if not (t1 =~= t2) then (
          let _ =
            let core =
              [
                "Conjunction patterns disagree in type:";
                "  `" -- showTyp t1 -- "`";
                "  vs";
                "  `" -- showTyp t2 -- "`";
              ]
            in
            List.iter ~f:print_endline core
          in
          showDiffTypes t1 t2;
          typeError "")
        else
          match tM with
          | Some t ->
              if not (t =~= t1) then (
                let _ =
                  let core =
                    [
                      "Conjunction pattern disagrees with type hint:";
                      "  `" -- showTyp t -- "` (hint)";
                      "  vs";
                      "  `" -- showTyp t1 -- "` (type)";
                    ]
                  in
                  List.iter ~f:print_endline core
                in
                showDiffTypes t1 t2;
                typeError "")
              else (t1, Env.joinR g1 g2)
          | None -> (t1, Env.joinR g1 g2))
    | PPred e -> (
        match typOf d g bigD bigG e with
        | TArr (t, t') when t' = tBool -> (t, Env.empty)
        | t ->
            let _ =
              let core =
                [
                  "Invalid predicate type in pattern:";
                  "  `" -- CoreLineariser.showPat p -- "`:";
                  "    `" -- showTyp t -- "`";
                ]
              in
              List.iter ~f:print_endline core
            in
            typeError "")
  and restructureBindings (d : knd Env.t) (g : knd Env.t) (bigD : typ Env.t)
      (bigG : typ Env.t) ((p, e) : pat * exp) :
      (string * exp) option * (pat * exp) list =
    let p = restructureBindingsPat d g bigD bigG p in
    match p with
    | PVar _ -> (None, [ (p, e) ])
    | _ ->
        let y = freshVar () in
        let xts = patBoundVarsWithTypes p in
        let _ =
          xts
          &> List.map ~f:(fun xt -> Env.cons [ xt ])
             @> repeatedVarsErr (fun _ -> raise TypeError)
        in
        let g = Env.cons xts in
        let toClause x =
          match g ==> x with
          | Some t -> (PVar (x, t), EApp (EAbs ([ p ], EVar x), EVar y))
          | None ->
              let _ = print_endline ("No type for `" -- x -- "`.") in
              raise TypeError
        in
        let xs = p &> patBoundVars @> StringSet.to_list in
        (Some (y, e), List.map ~f:toClause xs)
  and restructureBindingsExp (d : knd Env.t) (g : knd Env.t) (bigD : typ Env.t)
      (bigG : typ Env.t) : exp -> exp =
    let loopPat p = restructureBindingsPat d g bigD bigG p in
    let rec loop = function
      | ETAbs (x, k, e) -> ETAbs (x, k, loop e)
      | EAbs (ps, e) -> EAbs (List.map ~f:loopPat ps, loop e)
      | ETApp (e, t) -> ETApp (loop e, t)
      | EApp (e, e') -> EApp (loop e, loop e')
      | ETup [ e ] -> loop e
      | ETup es -> ETup (List.map ~f:loop es)
      | EFcmp es -> EFcmp (List.map ~f:loop es)
      | ECVal (c, es) -> ECVal (c, List.map ~f:loop es)
      | ELet _ ->
          let _ =
            print_endline "`let` / `where` are not allowed within patterns."
          in
          raise TypeError
      | e -> e
    in
    loop
  and restructureBindingsPat (d : knd Env.t) (g : knd Env.t) (bigD : typ Env.t)
      (bigG : typ Env.t) : pat -> pat =
    let loop e = restructureBindingsExp d g bigD bigG e in
    let rec loopPat = function
      | PCVal (c, t, ps) -> PCVal (c, t, List.map ~f:loopPat ps)
      | PTup [ p ] -> loopPat p
      | PTup ps -> PTup (List.map ~f:loopPat ps)
      | PConj (p, p') -> PConj (loopPat p, loopPat p')
      | PWhen (e, mt) -> PWhen (loop e, mt)
      | PPred e -> PPred (loop e)
      | p -> p
    in
    loopPat
  in
  (typOf, typOfPat)

let typOf (showTyp : typ -> string) (d : knd Env.t) (g : knd Env.t)
    (bigD : typ Env.t) (bigG : typ Env.t) (e : exp) : typ =
  let typOf, _ = typingFuncs showTyp in
  typOf d g bigD bigG e
