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

module OldString = String
module List = Core.List
module String = Core.String
module PolyMap = Core.Map.Poly

module StringMap = struct
  include Core.Map
  include Core.String.Map
end

module PolySet = struct
  include Core.Set
  include Core.Set.Poly
end

module StringSet = struct
  include Core.Set
  include Core.String.Set
end

type ('a, 'b) either = Left of 'a | Right of 'b

let id x = x
let flip f x y = f y x
let uncurry f (x, y) = f x y
let curry f x y = f (x, y)
let apply f x = f x
let const x _ = x
let ( ++ ) f g x = f (g x)
let ( -- ) = ( ^ )
let ( &> ) x f = f x
let ( @> ) f g x = g (f x)
let pair x y = (x, y)
let pairMap f g (x, y) = (f x, g y)
let pairBoth f = pairMap f f
let first f = pairMap f id
let stringOfChar : char -> string = String.make 1
let trimString : string -> string = OldString.trim
let concatMap f s = List.map ~f @> String.concat ~sep:s
let around l r s = l -- s -- r
let parenthesise = around "(" ")"

let fold1 ~f xs =
  match xs with
  | x :: xs -> List.fold ~f ~init:x xs
  | [] -> failwith "fold1 argument error"

let nub xs = PolySet.stable_dedup_list xs

let readFile f =
  let is = open_in f in
  let lines = Std.input_list is in
  let _ = close_in is in
  lines

let gSeed = ref 0

let gensym _ =
  let res = !gSeed in
  let _ = gSeed := res + 1 in
  res
