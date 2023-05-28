(* Generated by           *
 *             CamlTrax   *
 *                     NG *
 *                        *
 * Copyright 2007-2023    *
 *             K.D.P.Ross *)


open Util


open List


module Out = OutputManager


module Map = Core.String.Map


type 'a t = 'a Map.t


let empty : 'a t = ( Map.empty )


let size ( g : 'a t ) : int = ( Map.length g )


let find m k = ( try ( Map.find_exn m k ) with
               | e -> ( let _ = ( Out.error ( "`find` failure on `" -- k -- "`." ) ) in
                      raise e ) )


let ( <+> ) : 'a t -> string * 'a -> 'a t =
  ( fun m ( k, v ) ->
    ( m &>
      flip Map.remove k @>
      Map.add_exn ~key:k ~data:v ) )


let rem : 'a t -> string -> 'a t =
  ( fun m k ->
    ( Map.remove m k ) )


let joinR  : 'a t -> 'a t -> 'a t =
  ( fun g m ->
    ( m &>
      Map.to_alist @>
      fold ~init:g ~f: ( <+> ) ) )


let joinL  : 'a t -> 'a t -> 'a t =
  ( fun g g' ->
    ( joinR  g' g ) )


let cons : ( string * 'a ) list -> 'a t =
  ( fun ps ->
    ( Map.of_alist_exn ps ) )


let decons : 'a t -> ( string * 'a ) list =
  ( fun m ->
    ( Map.to_alist m ) )


let domain : 'a t -> StringSet.t =
  ( fun m ->
    ( StringSet.of_map_keys m ) )


let ofMap  : ( string, 'a ) PolyMap.t -> 'a t =
  ( fun m ->
    ( m &>
      PolyMap.to_alist @>
      Map.of_alist_exn ) )


module type CONVENIENCE = sig
  val ( @-> ) : string -> 'a -> string * 'a
  val ( <+> ) : 'a t -> string * 'a -> 'a t
  val ( ==> ) : 'a t -> string -> 'a option
  val smashEnvs  : 'a t list -> 'a t end


module Convenience = struct
  let ( @-> ) : string -> 'a -> string * 'a = ( pair )
  let ( <+> ) : 'a t -> string * 'a -> 'a t = ( ( <+> ) )
  let ( ==> ) =
   ( fun m ->
     ( Map.find m ) )
  let smashEnvs  ( gs : 'a t list ) : 'a t = ( fold ~init:empty ~f:joinL  gs ) end

