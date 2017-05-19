
open Itp_communication

val print_request: Format.formatter -> ide_request -> unit
val print_msg: Format.formatter -> message_notification -> unit
val print_notify: Format.formatter -> notification -> unit

(* The server part of the protocol *)
module type Protocol = sig

  val get_requests : unit -> ide_request list
  val notify : notification -> unit

end

module Make (S:Controller_itp.Scheduler) (P:Protocol) : sig

  (* Initialize server with the given config, env and filename for the session *)
  val init_server: Whyconf.config -> Env.env -> string -> unit

end