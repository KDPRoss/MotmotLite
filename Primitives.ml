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

open ParserCombinators

module Out = OutputManager

exception UserFailure of ( string * Syntax.exp )

let numP  : Q.t parse =
  ( let postProcess  s = ( match ( Str.split ( Str.regexp_string "." ) s ) with
                            | [ w ; f ] -> ( let d = ( Q.of_string ( "1" -- String.make ( String.length f ) '0' ) )
                                               in let f' = ( Q. ( of_string f / d ) ) in
                                           w &>
                                             Q.of_string @>
                                             Q. ( + ) f' @>
                                             just )
                            | [ w ] -> ( w &>
                                             Q.of_string @>
                                             just )
                            | _ -> ( fail "Bad number." ) )
      in let oldStyle  = ( regexp ( Str.regexp "[0-9]+\\([.][0-9]+\\)?" ) >>= postProcess  )
      in let postProcess  = ( function
                            | ( Some _, n ) -> ( Q.neg n )
                            | ( None, n ) -> ( n ) ) in
  maybe ( txt "-" ) <*> oldStyle  >>> postProcess  )

let typPrim  : Syntax.prim -> Syntax.typ =
  ( function
  | Num _ -> ( TCVal ( "Num" , [] ) ) )

let parsePrim  : Syntax.prim lazyParse =
  ( let num = ( numP >>> fun n -> Syntax.Num n ) in
  lazy num )

let primKindEnv   parseKnd =
  ( let assumps = [
        ( "Num" , parseKnd  "*" ) ;
      ] in
  match ( PolyMap.of_alist assumps ) with
  | `Duplicate_key k -> ( failwith ( "Duplicate key for `" -- k -- "` in `primKindEnv`; this is an implementation error." ) )
  | `Ok m -> ( Env.ofMap  m ) )

