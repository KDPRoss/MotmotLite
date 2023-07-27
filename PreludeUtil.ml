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

open Syntax

exception DynFailure

exception NativeFailure of string

exception FailCoreFailure

let showExp  : exp -> string = ( CoreLineariser.showExp  )

let dynFail  ( s : string ) ( es : exp list ) : 'a =
  ( let s' = ( match ( es ) with
           | [] -> ( "Dynamic failure: " -- s )
           | _ -> ( "Dynamic failure: " -- s -- " with expressions context:" ) )
      in let _ = ( print_endline s' )
      in let _ = ( es &>
             List.iter ~f: (
               CoreLineariser.showExp  @>
               ( -- ) "  " @>
               print_endline
             ) ) in
  raise DynFailure )

let natFail  ( s : string ) = ( raise ( NativeFailure s ) )

let listToExternal   : exp -> exp list =
  ( function
  | EList es -> ( es )
  | v -> ( dynFail  "Invalid list." [ v ] ) )

let listToInternal   ( es : exp list ) : exp =
  ( EList es )

let numToExternal   : exp -> Q.t =
  ( function
  | ENum n -> ( n )
  | v -> ( dynFail  "Invalid num." [ v ] ) )

let numToInternal   ( n : Q.t ) : exp =
  ( ENum n )

let integerQ ( n : Q.t ) : bool =
  ( let n' = ( n &>
             Q.to_bigint @>
             Q.of_bigint ) in
  Q.equal n n' )

let intToExternal   : exp -> Q.t option =
  ( function
  | ENum n -> ( if ( integerQ n )
                 then ( Some n )
                 else ( None ) )
  | _ -> ( None ) )

let nonnegativeIntToExternal    ( e : exp ) : Q.t option =
  ( match ( intToExternal   e ) with
  | Some n -> ( if ( Q. ( n >= zero ) )
                 then ( Some n )
                 else ( None ) )
  | None -> ( None ) )

let positiveIntToExternal    ( e : exp ) : Q.t option =
  ( match ( intToExternal   e ) with
  | Some n -> ( if ( Q. ( n > zero ) )
                 then ( Some n )
                 else ( None ) )
  | None -> ( None ) )

let boolToExternal   : exp -> bool =
  ( function
  | ECVal ( "True" , [] ) -> ( true )
  | ECVal ( "False" , [] ) -> ( false )
  | v -> ( dynFail  "Invalid bool." [ v ] ) )

let boolToInternal   : bool -> exp =
  ( function
  | true -> ( ECVal ( "True" , [] ) )
  | false -> ( ECVal ( "False" , [] ) ) )

let forceEqable  ( e : exp ) : exp =
  ( if ( not ( eqableQ e ) )
     then ( dynFail  "Incomparable syntactic class." [ e ] )
     else ( e ) )

