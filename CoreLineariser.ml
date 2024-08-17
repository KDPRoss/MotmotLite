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

let rec showKnd : knd -> string = function
  | KArr (k, k') -> showKndS k -- " -> " -- showKnd k'
  | KStar -> "*"

and showKndS (k : knd) : string =
  match k with KStar -> showKnd k | _ -> k &> showKnd @> parenthesise

let rec showTyp : typ -> string = function
  | TVar x -> x
  | TAbs (x, k, t) ->
      parenthesise (x -- " : " -- showKnd k) -- " => " -- showTyp t
  | TCVal (c, []) -> c
  | TCVal ("List", [ t ]) -> "[ " -- showTyp t -- " ]"
  | TCVal (c, ts) -> c -- " " -- concatMap showTypS " " ts
  | TArr (t, t') -> showTypH t -- " -> " -- showTyp t'
  | TApp (t, t') -> showTypH t -- " " -- showTypS t'
  | TTpl ts -> parenthesise (concatMap showTyp ", " ts)

and showTypH (t : typ) : string =
  match t with TApp _ | TCVal _ -> showTyp t | _ -> showTypS t

and showTypS (t : typ) : string =
  match t with
  | TVar _ | TTpl _ | TCVal (_, []) -> showTyp t
  | TCVal ("List", _) -> showTyp t
  | _ -> t &> showTyp @> parenthesise

let mixfixSpecs = Syntax.Mixfix.defaultSpecs

let showFuncs : (pat -> string) * (exp -> string) =
  let specs = List.concat_map ~f:fst mixfixSpecs in
  let infix =
    let extractInfix = function [ None; Some x; None ] -> [ x ] | _ -> [] in
    specs &> List.concat_map ~f:extractInfix @> StringSet.of_list
  in
  let infixQ : string -> bool = StringSet.mem infix in
  let rec showPat : pat -> string = function
    | PAny t -> "(_ : " -- showTyp t -- ")"
    | PVar (x, t) -> "(" -- x -- " : " -- showTyp t -- ")"
    | PCVal (c, [], []) -> c
    | PCVal (c, ts, []) -> c -- "{ " -- concatMap showTyp ", " ts -- " }"
    | PCVal (c, [], ps) -> c -- " " -- concatMap showPatS " " ps
    | PCVal (c, ts, ps) ->
        c -- "{ " -- concatMap showTyp ", " ts -- " } "
        -- concatMap showPatS " " ps
    | PTup ps -> parenthesise (concatMap showPat ", " ps)
    | PConj (p, p') -> showPatS p -- " and " -- showPatH p'
    | PWhen (e, None) -> "`{" -- showExp e -- "}"
    | PWhen (e, Some t) -> "`{" -- showExp e -- "}{ " -- showTyp t -- " }"
    | PPred e -> "{" -- showExp e -- "}"
  and showPatH (p : pat) : string =
    match p with PCVal _ | PConj _ -> showPat p | _ -> showPatS p
  and showPatS (p : pat) : string =
    match p with
    | PAny _ | PVar _ | PCVal (_, [], []) | PTup _ | PPred _ | PWhen _ ->
        showPat p
    | _ -> p &> showPat @> parenthesise
  and showExp : exp -> string = function
    | EApp (EApp (EVar x, e), e') when infixQ x ->
        showExpH e -- " " -- x -- " " -- showExpH e'
    | EVar x when infixQ x -> parenthesise x
    | EVar x -> x
    | ETAbs (x, k, e) ->
        parenthesise (x -- " : " -- showKnd k) -- " => " -- showExp e
    | EAbs (ps, e) -> concatMap showPat " | " ps -- " ~ " -- showExp e
    | ETApp _ as e ->
        let rec collectTypes res = function
          | ETApp (e, t) -> collectTypes (t :: res) e
          | e -> (e, res)
        in
        let e', ts = collectTypes [] e in
        showExpS e' -- "{ " -- concatMap showTyp ", " ts -- " }"
    | EApp (e, e') -> showExpH e -- " " -- showExpS e'
    | ETup es -> parenthesise (concatMap showExp ", " es)
    | EFcmp fs -> concatMap showExpH " <+ " fs
    | ECVal (c, []) -> c
    | ECVal (c, es) -> c -- " " -- concatMap showExpS " " es
    | ELet (bs, e) ->
        let showOne (p, e) = showPat p -- " = " -- showExpH e in
        "let " -- concatMap showOne " | " bs -- " in " -- showExp e
    | ENum n ->
        n &> Q.to_string @> Str.global_replace (Str.regexp_string "/") " / "
    | EMap m ->
        let ps = PolyMap.to_alist m in
        ps
        &> concatMap (fun (k, v) -> showExp k -- " |-> " -- showExp v) ", "
           @> around "<map(" ")>"
    | EList [] -> "[]"
    | EList es ->
        let ss = List.map ~f:showExp es in
        let join = String.concat ~sep:", " @> around "[ " " ]" in
        join ss
    | ECls _ | EDely _ | ELazy _ | ENatF _ -> "<fun>"
  and showExpH (e : exp) : string =
    match e with
    | EApp (EApp (EVar x, _), _) when infixQ x -> showExpS e
    | EApp _ | ETApp _ | ECVal _ -> showExp e
    | _ -> showExpS e
  and showExpS (e : exp) : string =
    match e with
    | EVar _ | ETup _
    | ECVal (_, [])
    | ENum _ | EList _ | EDely _ | ECls _ | EMap _ ->
        showExp e
    | _ -> e &> showExp @> parenthesise
  in
  (showPat, showExp)

let showExpTyping : exp -> string = snd showFuncs
let showExp : exp -> string = showExpTyping
let showPat : pat -> string = fst showFuncs
