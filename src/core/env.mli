(**************************************************************************)
(*                                                                        *)
(*  Copyright (C) 2010-                                                   *)
(*    Francois Bobot                                                      *)
(*    Jean-Christophe Filliatre                                           *)
(*    Johannes Kanig                                                      *)
(*    Andrei Paskevich                                                    *)
(*                                                                        *)
(*  This software is free software; you can redistribute it and/or        *)
(*  modify it under the terms of the GNU Library General Public           *)
(*  License version 2.1, with the special exception on linking            *)
(*  described in file LICENSE.                                            *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                  *)
(*                                                                        *)
(**************************************************************************)

(** Access to Environment, Load Path *)

open Theory

type env

val env_tag : env -> Hashweak.tag

type retrieve_theory = env -> string list -> theory Mnm.t

val create_env : retrieve_theory -> env

exception TheoryNotFound of string list * string

val find_theory : env -> string list -> string -> theory
  (** [find_theory e p n] finds the theory named [p.n] in environment [e]
      @raise TheoryNotFound if theory not present in env [e] *)

(** Parsers *)

type read_channel = env -> string -> in_channel -> theory Mnm.t

val register_format : string -> string list -> read_channel -> unit
  (** [register_format name extensions f1 f2] registers a new format
      under name [name], for files with extensions in list [extensions];
      [f1] is the function to perform parsing *)

val read_channel : ?name:string -> read_channel
(** [read_channel ?name env f c] returns the map of theories
    in channel [c]. When given, [name] enforces the format, otherwise
    the format is chosen according to [f]'s extension. 
    Beware that it cannot be checked that [c] corresponds 
    to the contents of [f] *)

val read_file : ?name:string -> env -> string -> theory Mnm.t 
(** [read_file ?name env f] returns the map of theories
    in file [f]. When given, [name] enforces the format, otherwise
    the format is chosen according to [f]'s extension. *)

exception UnknownFormat of string (* format name *)

val list_formats : unit -> (string * string list) list

