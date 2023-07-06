(* MotmotLite: A Motmotastic Linguistic Toy

   Copyright 2023, K.D.P.Ross <KDPRoss@gmail.com>

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
 * Copyright 2007-2023    *
 *             K.D.P.Ross *)

open Util

module Out = OutputManager

type knd = KStar
               | KArr of ( knd * knd )

type typ = TVar of string
               | TAbs of ( string * knd * typ )
               | TCVal of ( string * typ list )
               | TArr of ( typ * typ )
               | TApp of ( typ * typ )
               | TTpl of typ list

type exp = EVar of string
               | ETAbs of ( string * knd * exp )
               | EAbs of ( pat list * exp )
               | ETApp of ( exp * typ )
               | EApp of ( exp * exp )
               | ETup of exp list
               | EFcmp of exp list
               | ECVal of ( string * exp list )
               | ELet of ( ( pat * exp ) list * exp )
               | ECls of ( pat list * exp * exp Env.t )
               | EDely of ( exp * exp list ) list * ( exp * exp list ) list
               | ELazy of ( exp * exp Env.t option ) ref
               | ENatF of ( string * natvFunc )
               | ENum of Q.t
               | EList of exp list
               | EMap of ( exp, exp ) PolyMap.t
 and pat = PAny of typ
               | PVar of ( string * typ )
               | PCVal of ( string * typ list * pat list )
               | PTup of pat list
               | PConj of ( pat * pat )
               | PPred of exp
               | PWhen of ( exp * typ option )
 and natvFunc = Natv1 of ( exp -> exp )
               | Natv2 of ( exp -> exp -> exp )

exception UserFailure of ( string * exp )

let natNumArgs   : natvFunc -> int =
  ( function
  | Natv1 _ -> ( 1 )
  | Natv2 _ -> ( 2 ) )

exception EqIncomparableEsc of ( exp * exp )

let rec eqableQ : exp -> bool =
  ( function
  | ETup es
  | ECVal ( _, es )
  | EList es -> ( List.for_all ~f:eqableQ es )
  | ENum _ -> ( true )
  | EMap m -> ( let ksQ = ( m &>
                                 PolyMap.keys @>
                                 List.for_all ~f:eqableQ ) in
                     ksQ && PolyMap.for_all ~f:eqableQ m )
  | _ -> ( false ) )

let rec eqCoreBool   ( throwForFunc   : bool ) ( v1 : exp ) ( v2 : exp ) : bool =
  ( let eqCoreBool   = ( eqCoreBool   throwForFunc   )
      in let _ = ( if ( throwForFunc   && not ( eqableQ v1 && eqableQ v2 ) )
                        then ( raise ( EqIncomparableEsc ( v1, v2 ) ) ) ) in
  match ( ( v1, v2 ) ) with
  | ( EMap m1, EMap m2 ) -> ( Core.Map.equal eqCoreBool   m1 m2 )
  | ( ENum n1, ENum n2 ) -> ( n1 = n2 )
  | ( ECVal ( c1, es1 ) , ECVal ( c2, es2 ) ) -> ( if ( c1 <> c2 )
                                             then ( false )
                                             else ( eqCoreBool   ( ETup es1 ) ( ETup es2 ) ) )
  | ( ETup ts1, ETup ts2 ) -> ( if ( List.length ts1 <> List.length ts2 )
                                             then ( false )
                                             else ( List.zip_exn ts1 ts2 &>
                                                    List.for_all ~f: ( uncurry eqCoreBool   ) ) )
  | ( EList vs1, EList vs2 ) -> ( let open Core.List.Or_unequal_lengths in
                                          match ( List.zip vs1 vs2 ) with
                                          | Unequal_lengths -> ( false )
                                          | Ok ps -> ( List.for_all ~f: ( uncurry eqCoreBool   ) ps ) )
  | _ -> ( false ) )

let ( === ) = ( eqCoreBool   false )

module type MIXFIX = sig
  exception ResolveFailure of string
  type spec = string option list
  type assoc = Left
             | Right
  type specsList = ( spec list * assoc ) list
  val defaultSpecs  : specsList end

module Mixfix : MIXFIX = struct
  exception ResolveFailure of string
  type spec = string option list
  type assoc = Left
             | Right
  type specsList = ( spec list * assoc ) list
  let infix s = ( [ None ; Some s ; None ] )
  let defaultSpecs  : specsList = [
    ( [ infix "<|" ; infix "|>" ] , Right ) ;
    ( [ infix "<<" ; infix ">>" ] , Left ) ;
    ( [ infix "or" ; infix ">+>" ] , Left ) ;
    ( [ infix "and" ; infix "<+>" ; infix "<->" ] , Left ) ;
    ( [ infix "<" ; infix ">" ; infix "=<" ; infix ">=" ; infix "==" ; infix "=/=" ] , Right ) ;
    ( [ infix "::" ] , Right ) ;
    ( [ infix "|->" ] , Left ) ;
    ( [ infix "+" ; infix "-" ] , Left ) ;
    ( [ infix "*" ; infix "/" ] , Left ) ;
  ] end

let patBoundVarsWithTypes     : pat -> ( string * typ ) list =
  ( let rec patBoundVars   : pat -> ( string * typ ) PolySet.t =
        ( let ( ++ ) = ( PolySet.union ) in
        function
        | PVar xt -> ( PolySet.singleton xt )
        | PCVal ( _, _, ps )
        | PTup ps -> ( ps &>
                                List.map ~f:patBoundVars   @>
                                List.fold ~init:PolySet.empty ~f: ( ++ ) )
        | PConj ( p, p' ) -> ( patBoundVars   p ++ patBoundVars   p' )
        | _ -> ( PolySet.empty ) ) in
  patBoundVars   @>
    PolySet.to_list )

let rec patBoundVars   : pat -> StringSet.t =
  ( let ( ++ ) = ( StringSet.union ) in
  function
  | PVar ( x, _ ) -> ( StringSet.singleton x )
  | PCVal ( _, _, ps )
  | PTup ps -> ( ps &>
                          List.map ~f:patBoundVars   @>
                          List.fold ~init:StringSet.empty ~f: ( ++ ) )
  | PConj ( p, p' ) -> ( patBoundVars   p ++ patBoundVars   p' )
  | _ -> ( StringSet.empty ) )

let rec patFreeVars   : pat -> StringSet.t =
  ( let ( ++ ) = ( StringSet.union ) in
  function
  | PCVal ( _, _, ps )
  | PTup ps -> ( ps &>
                          List.map ~f:patFreeVars   @>
                          List.fold ~init:StringSet.empty ~f: ( ++ ) )
  | PConj ( p1, p2 ) -> ( patFreeVars   p1 ++ patFreeVars   p2 )
  | PPred e
  | PWhen ( e, _ ) -> ( expFreeVars   e )
  | _ -> ( StringSet.empty ) )

and expFreeVars   : exp -> StringSet.t =
  ( let ( ++ ) = ( StringSet.union )
      in let ( // ) = ( StringSet.diff ) in
  function
  | EVar x -> ( StringSet.singleton x )
  | ETAbs ( _, _, e )
  | ETApp ( e, _ ) -> ( expFreeVars   e )
  | EAbs ( ps, e ) -> ( let rec loop bound free =
                             ( function
                             | [] -> ( ( bound, free ) )
                             | p :: ps -> ( let fs = ( patFreeVars   p // bound )
                                              in let bs = ( patBoundVars   p ) in
                                          loop ( bound ++ bs ) ( free ++ fs ) ps ) ) in
                       let ( bound, free ) = ( loop StringSet.empty StringSet.empty ps ) in
                       ( expFreeVars   e // bound ) ++ free )
  | EApp ( e1, e2 ) -> ( expFreeVars   e1 ++ expFreeVars   e2 )
  | ETup es
  | EFcmp es
  | ECVal ( _, es )
  | EList es -> ( es &>
                         List.map ~f:expFreeVars   @>
                         List.fold ~init:StringSet.empty ~f: ( ++ ) )
  | ENum _ -> ( StringSet.empty )
  | ELet ( bs, e ) -> ( let bound = ( bs &>
                                     List.map ~f: (
                                       fst @>
                                       patBoundVars
                                     ) @> List.fold ~init:StringSet.empty ~f: ( ++ ) )
                           in let free = ( e :: List.map ~f:snd bs &>
                                     List.map ~f:expFreeVars   @>
                                     List.fold ~init:StringSet.empty ~f: ( ++ ) ) in
                       free // bound )
  | ECls _
  | EDely _
  | ELazy _
  | ENatF _
  | EMap _ -> ( StringSet.empty ) )

