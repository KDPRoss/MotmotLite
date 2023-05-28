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

open List

let rec restructureBindings  ( ( p, e ) : Syntax.pat * Syntax.exp ) : ( Syntax.pat * Syntax.exp ) list =
  ( let open Syntax in
  let e = ( restructureBindingsExp   e )
      in let p = ( restructureBindingsPat   p ) in
  match ( p ) with
  | PVar _ -> ( [ ( p, e ) ] )
  | _ -> ( let y = ( Typing.freshVar  () )
                  in let toClause  x = ( ( PVar ( x, TVar "?" ) , EApp ( EAbs ( [ p ] , EVar x ) , EVar y ) ) )
                  in let xs = ( p &>
                                  Syntax.patBoundVars   @>
                                  StringSet.to_list ) in
              ( PVar ( y, TVar "?" ) , e ) :: map ~f:toClause  xs ) )

and restructureBindingsExp   : Syntax.exp -> Syntax.exp =
  ( let open Syntax in
  let loopPat  = ( restructureBindingsPat   ) in
  let rec loop = ( function
                 | ETAbs ( x, k, e ) -> ( ETAbs ( x, k, loop e ) )
                 | EAbs ( ps, e ) -> ( EAbs ( map ~f:loopPat  ps, loop e ) )
                 | ETApp ( e, t ) -> ( ETApp ( loop e, t ) )
                 | EApp ( e, e' ) -> ( EApp ( loop e, loop e' ) )
                 | ETup [ e ] -> ( loop e )
                 | ETup es -> ( ETup ( map ~f:loop es ) )
                 | EFcmp es -> ( EFcmp ( map ~f:loop es ) )
                 | EHcmp ( e, e' ) -> ( EHcmp ( loop e, loop e' ) )
                 | ECVal ( c, es ) -> ( ECVal ( c, map ~f:loop es ) )
                 | ELet ( bs, e ) -> ( let bs' = ( [ concat_map ~f:restructureBindings  bs ] )
                                          in let e' = ( loop e ) in
                                      bs' &>
                                        fold_right ~init:e' ~f: (
                                          fun bs e ->
                                            ELet ( bs, e )
                                        ) )
                 | e -> ( e ) ) in
  loop )

and restructureBindingsPat   : Syntax.pat -> Syntax.pat =
  ( let open Syntax in
  let loop = ( restructureBindingsExp   ) in
  let rec loopPat  = ( function
                     | PCVal ( c, t, ps ) -> ( PCVal ( c, t, map ~f:loopPat  ps ) )
                     | PTup [ p ] -> ( loopPat  p )
                     | PTup ps -> ( PTup ( map ~f:loopPat  ps ) )
                     | PConj ( p, p' ) -> ( PConj ( loopPat  p, loopPat  p' ) )
                     | PWhen ( e, mt ) -> ( PWhen ( loop e, mt ) )
                     | PPred e -> ( PPred ( loop e ) )
                     | p -> ( p ) ) in
  loopPat  )

