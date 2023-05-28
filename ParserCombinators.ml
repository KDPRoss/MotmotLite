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

let lessEqual  = ( ( <= ) )

let notEqual  = ( ( <> ) )

let disj = ( ( || ) )

include ParserCore

type 'a parse = 'a t

type 'a lazyParse = 'a parse lazy_t

exception ParseFailure of ( string * int )

let ( <*> ) = ( ( <> ) )

let ( =*> ) = ( ( => ) )

let ( <*= ) = ( ( <= ) )

let ( ||| ) = ( ( || ) )

let ( <= ) = ( lessEqual  )

let ( <> ) = ( notEqual  )

let ( || ) = ( disj )

let oneOfC   ( s : string ) ( c : char ) : bool =
  ( try ( let _ = ( String.index s c ) in
      true ) with
  | Not_found -> ( false ) )

let oneOfNotC    ( s : string ) ( c : char ) : bool =
  ( try ( let _ = ( String.index s c ) in
      false ) with
  | Not_found -> ( true ) )

let spaceC  : char -> bool = ( oneOfC   " " )

let spaces1  : unit parse = ( stringOf  spaceC  >>> ignore )

let spaces : unit parse = ( spaces1 ||| just () )

let ( <=> ) ( p : 'a parse ) ( q : 'b parse ) : ( 'a * 'b ) parse = ( p <*= spaces <*> q )

let ( <== ) ( p : 'a parse ) ( q : 'b parse ) : 'a parse = ( p <*= spaces <*= q )

let ( ==> ) ( p : 'a parse ) ( q : 'b parse ) : 'b parse = ( p =*> spaces =*> q )

let ( <!> ) ( p : 'a parse ) ( q : 'b parse ) : ( 'a * 'b ) parse = ( p <*= spaces1  <*> q )

let ( <!= ) ( p : 'a parse ) ( q : 'b parse ) : 'a parse = ( p <*= spaces1  <*= q )

let ( =!> ) ( p : 'a parse ) ( q : 'b parse ) : 'b parse = ( p =*> spaces1  =*> q )

let maybe ( p : 'a parse ) : 'a option parse = ( p >>> ( fun x -> Some x ) ||| just None )

let rangeC  ( c1 : char ) ( c2 : char ) ( c : char ) : bool = ( c >= c1 && c <= c2 )

let parens ( p : 'a parse ) : 'a parse = ( txt "(" ==> p <== txt ")" )

let upperC  : char -> bool = ( rangeC  'A' 'Z' )

let lowerC  : char -> bool = ( rangeC  'a' 'z' )

let digitC  : char -> bool = ( rangeC  '0' '9' )

let varP  : string parse = ( stringOf  lowerC  )

let wrapParser  ( p : 'a parse ) ( s : string ) : 'a =
  ( match ( parse p s ) with
  | Success ( r, _, _ ) -> ( r )
  | Failure i -> ( raise ( ParseFailure ( s, i ) ) ) )

