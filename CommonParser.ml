(* MotmotLite: A Motmotastic Linguistic Toy

   Copyright 2023 -- 2025, K.D.P.Ross <KDPRoss@gmail.com>

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
 * Copyright 2007-2025    *
 *             K.D.P.Ross *)

open Util
open ParserCombinators

let surfaceKeywords =
  let core =
    [ ":"; "<+"; "="; "=>"; "\\"; "case"; "fun"; "of"; "where"; "~" ]
  in
  StringSet.of_list core

let checkEnd keywords s =
  if StringSet.mem keywords s then fail "keyword is not valid" else just s

let repsep1NoSpace (p : 'a parse) (s : 'b parse) : 'a list parse =
  let rec mult = lazy (p <*= s <*> cache nonEmpty >>> fun (x, xs) -> x :: xs)
  and single = lazy (p >>> fun x -> [ x ])
  and nonEmpty = lazy (cache mult ||| cache single) in
  cache nonEmpty

let repsepK (p : 'a parse) (s : 'b parse) : 'a list parse =
  let rec mult = lazy (p <== s <=> cache nonEmpty >>> fun (x, xs) -> x :: xs)
  and single = lazy (p >>> fun x -> [ x ])
  and empty = lazy (just [])
  and nonEmpty = lazy (cache mult ||| cache single) in
  cache nonEmpty ||| cache empty

let many1Spaces (p : 'a parse) : 'a list parse =
  let rec mult = lazy (p <!> cache nonEmpty >>> fun (x, xs) -> x :: xs)
  and single = lazy (p >>> fun x -> [ x ])
  and nonEmpty = lazy (cache mult ||| cache single) in
  cache nonEmpty

let commaSepList1 (p : 'a parse) : 'a list parse =
  repsep1 (p <== just ()) (txt "," <== just ())

let nonEmpty s =
  if String.length s = 0 then fail "Must be nonempty." else just s

let mashStringStringOpt c = (function Some s -> c -- s | None -> c)

let varPExt : string parse =
  let mashCharString (c, s) = stringOfChar c -- s in
  let mashCharStringOpt = first stringOfChar @> uncurry mashStringStringOpt in
  let ( |@| ) p q = fun x -> p x || q x in
  let follow : string parse =
    stringOf (oneOfC "!%&*+-/;<>?\\^~_:#=@|_\'" |@| upperC |@| lowerC |@| digitC)
  in
  let startWithLetterOrUnderscore =
    let init = oneOf lowerC ||| chr '_' in
    init <*> maybe follow >>> mashCharStringOpt
  in
  let startWithNormalOpC =
    let init = ":!%&*+-/;<>?\\^~_#@" &> oneOfC @> oneOf in
    init <*> maybe follow >>> mashCharStringOpt
  in
  let startWithSpecialOpC =
    let init = "=|" &> oneOfC @> oneOf in
    let follow' = follow >>= nonEmpty in
    init <*> follow' >>> mashCharString
  in
  startWithLetterOrUnderscore ||| startWithNormalOpC ||| startWithSpecialOpC

let atomP =
  stringOf upperC >>= nonEmpty <*> maybe varPExt >>> uncurry mashStringStringOpt
