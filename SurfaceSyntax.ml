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

type knd = Syntax.knd

type typ =
  | TVar of string
  | TAbs of (string list * knd * typ)
  | TCVal of (string * typ list)
  | TArr of (typ * typ)
  | TApp of (typ * typ)
  | TTpl of typ list
  | TBrackets of typ

type exp =
  | EVar of string
  | ETAbs of (string list * knd * exp)
  | ETAbsNoBkt of (string * knd * exp)
  | EAbs of (pat list * exp)
  | EApp of (exp * exp)
  | ETup of exp list
  | EBrackets of exp
  | EFcmp of exp list
  | ECons of string
  | ENum of Q.t
  | EWhere of (exp * (pat * exp) list)
  | EFun of exp list
  | EAnn of (exp * typ)
  | ECaseOf of (exp list * exp list)
  | ETAppMany of (exp * typ list)
  | ELSec of (typ * exp * exp)
  | ERSec of (exp * exp * typ)
  | ELSecImp of (exp * exp)
  | ERSecImp of (exp * exp)
  | ENil of typ
  | EListLit of exp list
  | EMapLit of (exp * exp) list

and pat =
  | PAny of typ
  | PAnyNoBkt of typ
  | PVar of (string * typ)
  | PVarNoBkt of (string * typ)
  | PCVal of (string * typ list * pat list)
  | PListCons of (pat * pat)
  | PNil of typ
  | PList of pat list
  | PTup of pat list
  | PBrackets of pat
  | PConj of (pat * pat)
  | PWhen of (exp * typ option)
  | PPred of exp
  | PEq of exp
  | PNum of Q.t

let var x = Syntax.EVar x
let svar x = EVar x

let rec coreOfSurfaceTyp (normTyp : Syntax.typ -> Syntax.typ) :
    typ -> Syntax.typ =
  let coreOfSurfaceTyp t = coreOfSurfaceTyp normTyp t in
  function
  | TVar x -> Syntax.TVar x
  | TAbs (xs, k, t) ->
      List.fold_right
        ~f:(fun x t -> Syntax.TAbs (x, k, t))
        ~init:(coreOfSurfaceTyp t) xs
  | TCVal (c, ts) -> Syntax.TCVal (c, List.map ~f:coreOfSurfaceTyp ts)
  | TArr (t, t') -> Syntax.TArr (coreOfSurfaceTyp t, coreOfSurfaceTyp t')
  | TApp (t, t') -> Syntax.TApp (coreOfSurfaceTyp t, coreOfSurfaceTyp t')
  | TTpl ts -> Syntax.TTpl (List.map ~f:coreOfSurfaceTyp ts)
  | TBrackets t -> coreOfSurfaceTyp t

let rec coreOfSurfaceExp (normTyp : Syntax.typ -> Syntax.typ) :
    exp -> Syntax.exp =
  let coreOfSurfaceExp e = coreOfSurfaceExp normTyp e in
  let coreOfSurfacePat p = coreOfSurfacePat normTyp p in
  let coreOfSurfaceTyp t = coreOfSurfaceTyp normTyp t in
  let andCore e e' =
    Syntax.(
      EApp
        ( EFcmp
            [
              EAbs ([ PCVal ("True", [], []) ], e');
              EAbs ([ PCVal ("False", [], []) ], ECVal ("False", []));
            ],
          e ))
  in
  let orCore e e' =
    Syntax.(
      EApp
        ( EFcmp
            [
              EAbs ([ PCVal ("False", [], []) ], e');
              EAbs ([ PCVal ("True", [], []) ], ECVal ("True", []));
            ],
          e ))
  in
  function
  | EVar "and" ->
      let x = Typing.freshVar () in
      let y = Typing.freshVar () in
      Syntax.EAbs
        ( [ PVar (x, TCVal ("Bool", [])); PVar (y, TCVal ("Bool", [])) ],
          andCore (EVar x) (EVar y) )
  | EVar "or" ->
      let x = Typing.freshVar () in
      let y = Typing.freshVar () in
      Syntax.EAbs
        ( [ PVar (x, TCVal ("Bool", [])); PVar (y, TCVal ("Bool", [])) ],
          orCore (EVar x) (EVar y) )
  | EVar x -> Syntax.EVar x
  | ETAbs (xs, k, e) ->
      List.fold_right
        ~f:(fun x e -> Syntax.ETAbs (x, k, e))
        ~init:(coreOfSurfaceExp e) xs
  | ETAbsNoBkt (x, k, e) -> Syntax.ETAbs (x, k, coreOfSurfaceExp e)
  | EApp (EApp (EVar "and", e), e') ->
      andCore (coreOfSurfaceExp e) (coreOfSurfaceExp e')
  | EApp (EApp (EVar "or", e), e') ->
      orCore (coreOfSurfaceExp e) (coreOfSurfaceExp e')
  | ELSecImp (EVar "and", e) | ELSec (TCVal ("Bool", []), EVar "and", e) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, TCVal ("Bool", [])) ],
            andCore (EVar y) (coreOfSurfaceExp e) ))
  | ELSecImp (EVar "or", e) | ELSec (TCVal ("Bool", []), EVar "or", e) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, TCVal ("Bool", [])) ],
            orCore (EVar y) (coreOfSurfaceExp e) ))
  | ERSecImp (e, EVar "and") | ERSec (e, EVar "and", TCVal ("Bool", [])) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, TCVal ("Bool", [])) ],
            andCore (coreOfSurfaceExp e) (EVar y) ))
  | ERSecImp (e, EVar "or") | ERSec (e, EVar "or", TCVal ("Bool", [])) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, TCVal ("Bool", [])) ],
            orCore (coreOfSurfaceExp e) (EVar y) ))
  | EAbs (ps, e) ->
      Syntax.EAbs (List.map ~f:coreOfSurfacePat ps, coreOfSurfaceExp e)
  | EApp (e, e') -> Syntax.EApp (coreOfSurfaceExp e, coreOfSurfaceExp e')
  | ETup es -> Syntax.ETup (List.map ~f:coreOfSurfaceExp es)
  | EBrackets e -> coreOfSurfaceExp e
  | EFcmp es -> Syntax.EFcmp (List.map ~f:coreOfSurfaceExp es)
  | ECons x -> Syntax.ECVal (x, [])
  | ENum n -> Syntax.ENum n
  | EWhere (e, bs) ->
      Syntax.ELet
        ( List.map ~f:(pairMap coreOfSurfacePat coreOfSurfaceExp) bs,
          coreOfSurfaceExp e )
  | EFun es -> EFcmp (List.map ~f:coreOfSurfaceExp es)
  | EAnn (e, t) ->
      Syntax.(EApp (ETApp (var "id", coreOfSurfaceTyp t), coreOfSurfaceExp e))
  | ECaseOf (es', es) ->
      Syntax.(
        List.fold
          ~f:(fun e e' -> EApp (e, e'))
          ~init:(EFcmp (List.map ~f:coreOfSurfaceExp es))
          (List.map ~f:coreOfSurfaceExp es'))
  | ETAppMany (e, ts) ->
      List.fold
        ~f:(fun e t -> Syntax.ETApp (e, coreOfSurfaceTyp t))
        ~init:(coreOfSurfaceExp e) ts
  | ELSec (t, x, e) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, coreOfSurfaceTyp t) ],
            coreOfSurfaceExp (EApp (EApp (x, EVar y), e)) ))
  | ERSec (e, x, t) ->
      let y = Typing.freshVar () in
      Syntax.(
        EAbs
          ( [ PVar (y, coreOfSurfaceTyp t) ],
            EApp (EApp (coreOfSurfaceExp x, coreOfSurfaceExp e), EVar y) ))
  | ELSecImp (x, e) ->
      Syntax.(EApp (EApp (var "flip", coreOfSurfaceExp x), coreOfSurfaceExp e))
  | ERSecImp (e, x) -> Syntax.EApp (coreOfSurfaceExp x, coreOfSurfaceExp e)
  | ENil t -> Syntax.(ETApp (ECVal ("Nil", []), coreOfSurfaceTyp t))
  | EListLit es -> Syntax.EList (List.map ~f:coreOfSurfaceExp es)
  | EMapLit ps ->
      Syntax.(
        EApp
          ( var "list->map",
            EList
              (List.map
                 ~f:(fun (k, v) ->
                   ETup [ coreOfSurfaceExp k; coreOfSurfaceExp v ])
                 ps) ))

and coreOfSurfacePat (normTyp : Syntax.typ -> Syntax.typ) : pat -> Syntax.pat =
  let coreOfSurfaceExp e = coreOfSurfaceExp normTyp e in
  let coreOfSurfacePat p = coreOfSurfacePat normTyp p in
  let coreOfSurfaceTyp t = coreOfSurfaceTyp normTyp t in
  function
  | PAnyNoBkt t | PAny t -> Syntax.PAny (coreOfSurfaceTyp t)
  | PVarNoBkt (x, t) | PVar (x, t) -> Syntax.PVar (x, coreOfSurfaceTyp t)
  | PCVal (x, ts, ps) ->
      Syntax.PCVal
        (x, List.map ~f:coreOfSurfaceTyp ts, List.map ~f:coreOfSurfacePat ps)
  | PListCons (p, p') ->
      Syntax.PCVal ("Cons", [], [ coreOfSurfacePat p; coreOfSurfacePat p' ])
  | PNil t -> Syntax.PCVal ("Nil", [ coreOfSurfaceTyp t ], [])
  | PList ps ->
      Syntax.(
        List.fold_right
          ~f:(fun p ps -> PCVal ("Cons", [], [ coreOfSurfacePat p; ps ]))
          ~init:(PCVal ("Nil", [], []))
          ps)
  | PTup ps -> Syntax.PTup (List.map ~f:coreOfSurfacePat ps)
  | PBrackets p -> coreOfSurfacePat p
  | PConj (p, p') -> Syntax.PConj (coreOfSurfacePat p, coreOfSurfacePat p')
  | PWhen (e, mt) ->
      let mt' =
        match mt with Some t -> Some (coreOfSurfaceTyp t) | None -> None
      in
      Syntax.PWhen (coreOfSurfaceExp e, mt')
  | PPred e -> Syntax.PPred (coreOfSurfaceExp e)
  | PEq e -> Syntax.(PPred (EApp (var "==", coreOfSurfaceExp e)))
  | PNum n -> coreOfSurfacePat (PEq (ENum n))
