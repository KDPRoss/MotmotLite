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
 * Copyright 2007-2024    *
 *             K.D.P.Ross *)

open Util

type source = { str : string; len : int; mutable cleanup : (unit -> unit) list }
type 'a result = Success of 'a * int * int | Failure of int

type 'a t = {
  parser : source -> int * int -> 'a result;
  mutable cachedResults : 'a result option array option;
}

type 'a m = int * int -> 'a result

let return : 'a -> 'a m =
 fun (x : 'a) ((ix, err) : int * int) -> Success (x, ix, err)

let ( >>= ) : 'a m -> ('a -> 'b m) -> 'b m =
 fun (f : 'a m) (g : 'a -> 'b m) (st : int * int) ->
  match f st with
  | Success (x, ix, err) -> g x (ix, err)
  | Failure err -> Failure err

let getSt : (int * int) m = fun (x, y) -> Success ((x, y), x, y)
let getIx : int m = fun (x, y) -> Success (x, x, y)
let setIx : int -> unit m = fun ix (_, err) -> Success ((), ix, err)
let fail : 'a m = fun (err1, err2) -> Failure (max err1 err2)
let makeParser core = { cachedResults = None; parser = core }
let failure err1 err2 = Failure (max err1 err2)

let chr c =
  let core =
   fun { len; str; _ } ->
    getIx >>= fun ix ->
    if ix < len && str.[ix] = c then setIx (ix + 1) >>= fun _ -> return str.[ix]
    else fail
  in
  makeParser core

let oneOf pred =
  let core =
   fun { len; str; _ } ->
    getIx >>= fun ix ->
    if ix < len && pred str.[ix] then
      setIx (ix + 1) >>= fun _ -> return str.[ix]
    else fail
  in
  makeParser core

let noneOf pred = oneOf (fun c -> not (pred c))

let txtGuarded v ~isnt =
  let vLen = String.length v in
  let core =
   fun { len; str; _ } ->
    getIx >>= fun ix ->
    let rec loop i =
      if i = vLen && (i = len || not (isnt str.[ix])) then
        setIx (ix + vLen) >>= fun _ -> return v
      else if i < vLen && ix + i < len && v.[i] = str.[ix + i] then loop (i + 1)
      else fail
    in
    loop 0
  in
  makeParser core

let txt str = txtGuarded str ~isnt:(fun _ -> false)

let regexp reg =
  let core =
   fun { str; _ } ->
    getSt >>= fun (ix, err) ->
    if Str.string_match reg str ix then
      let v = Str.matched_string str in
      setIx (Str.match_end ()) >>= fun _ -> return v
    else setIx err >>= fun _ -> fail
  in
  makeParser core

let seq p1 p2 =
  let core =
   fun src ->
    p1.parser src >>= fun v1 ->
    p2.parser src >>= fun v2 -> return (v1, v2)
  in
  makeParser core

let seqRight p1 p2 =
  let core = fun src -> p1.parser src >>= fun _ -> p2.parser src in
  makeParser core

let seqLeft p1 p2 =
  let core =
   fun src ->
    p1.parser src >>= fun v1 ->
    p2.parser src >>= fun _ -> return v1
  in
  makeParser core

let ( || ) p1 p2 =
  let core =
   fun src (ix, err) ->
    match p1.parser src (ix, err) with
    | Success (v1, ix1, err1) -> Success (v1, ix1, err1)
    | Failure err1 -> p2.parser src (ix, err1)
  in
  makeParser core

let ( >>> ) p f =
  let core = fun src -> p.parser src >>= fun v -> return (f v) in
  makeParser core

let just v = makeParser (fun _ -> return v)
let fail _ = makeParser (fun _ -> fail)

let cache lz =
  let core =
   fun ({ cleanup; len; _ } as src) (ix, err) ->
    if ix >= len then failure err ix
    else
      let p = Lazy.force lz in
      let arr =
        match p.cachedResults with
        | None ->
            let arr = Array.make len None in
            let _ = p.cachedResults <- Some arr in
            let _ =
              src.cleanup <- (fun () -> p.cachedResults <- None) :: cleanup
            in
            arr
        | Some arr -> arr
      in
      let res =
        match arr.(ix) with
        | Some (Success (v, ix, err)) -> Success (v, ix, err)
        | Some fl -> fl
        | None ->
            let res = p.parser src (ix, 0) in
            let _ = arr.(ix) <- Some res in
            res
      in
      match res with
      | Success (v, ix, err1) -> Success (v, ix, max err err1)
      | Failure err1 -> failure err err1
  in
  makeParser core

let ( >>= ) pa fb =
  let core = fun src -> pa.parser src >>= fun res -> (fb res).parser src in
  makeParser core

let rep p =
  let core =
   fun src ->
    let rec loop vs (ix, err) =
      match p.parser src (ix, err) with
      | Success (v, ix, err) -> loop (v :: vs) (ix, err)
      | Failure err -> Success (List.rev vs, ix, err)
    in
    loop []
  in
  makeParser core

let ( <> ) = seq
let ( <= ) = seqLeft
let ( => ) = seqRight
let pcons (x, xs) = x :: xs
let rep1 p = p <> rep p >>> pcons
let repsep1 p s = p <> rep (s => p) >>> pcons
let repsep p s = repsep1 p s || just []

let eof =
  let core =
   fun { len; _ } (ix, err) ->
    if ix = len then Success ((), ix, err) else failure err ix
  in
  makeParser core

let identOf fst rest =
  let core =
   fun { len; str; _ } (ixStart, err) ->
    let not = Stdlib.not in
    let rec loop ix =
      if ix = len then
        let tok = String.sub ~pos:ixStart ~len:(ix - ixStart) str in
        Success (tok, ix, err)
      else if not (rest str.[ix]) then
        let tok = String.sub ~pos:ixStart ~len:(ix - ixStart) str in
        Success (tok, ix, err)
      else loop (ix + 1)
    in
    if ixStart < len then
      if fst str.[ixStart] then loop ixStart else Failure err
    else Failure err
  in
  makeParser core

let stringOf pred = identOf pred pred

let parse p str =
  let src = { str; len = String.length str; cleanup = [] } in
  let res = p.parser src (0, 0) in
  let _ = List.iter ~f:(flip apply ()) src.cleanup in
  res
