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
open Syntax.Mixfix

type 'a at = AB of 'a at list | AL of string | AO of 'a

let resolveGroupRight s es =
  try
    let symbolsToFind =
      let extract = function
        | [ None; Some s; None ] -> s
        | _ -> raise Not_found
      in
      List.map ~f:extract s
    in
    let rec chop acc = function
      | AL x :: xs when List.mem ~equal:( = ) symbolsToFind x ->
          Some (List.rev acc, x, xs)
      | e :: xs -> chop (e :: acc) xs
      | [] -> None
    in
    match chop [] es with
    | Some ([], _, _) -> None
    | Some (_, _, []) -> None
    | Some (es1, f, es2) -> Some ([ es1; [ AL f ]; es2 ], [ None; Some f; None ])
    | None -> None
  with _ -> None

let resolveGroupLeft s es =
  match resolveGroupRight s (List.rev es) with
  | Some ([ es1; f; es2 ], s) -> Some ([ List.rev es2; f; List.rev es1 ], s)
  | _ -> None

let specs = Syntax.Mixfix.defaultSpecs

let rec resolveApps es =
  let rec resolve sss es =
    match sss with
    | (ss, ass) :: sss -> (
        match
          match ass with
          | Left -> resolveGroupLeft ss es
          | Right -> resolveGroupRight ss es
        with
        | Some (es', s) -> (
            let es'' = List.map ~f:resolveApps es' in
            let rec strip acc = function
              | [] -> Some acc
              | Some x :: xs -> strip (acc @ [ x ]) xs
              | None :: _ -> None
            in
            match strip [] es'' with
            | Some es -> (
                let cs = List.zip_exn s es in
                let rec split (s, es) = function
                  | (Some f, _) :: cs -> split (f :: s, es) cs
                  | (None, e) :: cs -> split (s, es @ [ e ]) cs
                  | [] ->
                      let s' = s &> List.rev @> String.concat ~sep:"_" in
                      (s', es)
                in
                match split ([], []) cs with
                | "", _ -> None
                | f, es -> Some (AB (AL f :: es)))
            | _ -> None)
        | None -> resolve sss es)
    | [] -> None
  in
  match es with
  | [] -> None
  | [ e ] -> Some e
  | _ -> (
      match resolve specs es with Some _ as e -> e | None -> Some (AB es))

let appTreesOfExps =
  let convertOne = function SurfaceSyntax.EVar x -> AL x | e -> AO e in
  List.map ~f:convertOne

let rec expOfAppTree = function
  | AL x -> SurfaceSyntax.EVar x
  | AO e -> e
  | AB es ->
      es
      &> List.map ~f:expOfAppTree
         @> fold1 ~f:(fun f x -> SurfaceSyntax.EApp (f, x))
