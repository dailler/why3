(********************************************************************)
(*                                                                  *)
(*  The Why3 Verification Platform   /   The Why3 Development Team  *)
(*  Copyright 2010-2016   --   INRIA - CNRS - Paris-Sud University  *)
(*                                                                  *)
(*  This software is distributed under the terms of the GNU Lesser  *)
(*  General Public License version 2.1, with the special exception  *)
(*  on linking described in file LICENSE.                           *)
(*                                                                  *)
(********************************************************************)


(* Interface to Why3 and Alt-Ergo *)

let why3_conf_file = "/trywhy3.conf"

open Why3
open Format
open Worker_proto

let () = log_time ("Initialising why3 worker: start ")


(* reads the config file *)
let config : Whyconf.config = Whyconf.read_config (Some why3_conf_file)
(* the [main] section of the config file *)
let main : Whyconf.main = Whyconf.get_main config
(* all the provers detected, from the config file *)
let provers : Whyconf.config_prover Whyconf.Mprover.t =
  Whyconf.get_provers config

(* One prover named Alt-Ergo in the config file *)
let alt_ergo : Whyconf.config_prover =
  if Whyconf.Mprover.is_empty provers then begin
    eprintf "Prover Alt-Ergo not installed or not configured@.";
    exit 0
  end else snd (Whyconf.Mprover.choose provers)

(* builds the environment from the [loadpath] *)
let env : Env.env = Env.create_env (Whyconf.loadpath main)

let alt_ergo_driver : Driver.driver =
  try
    Printexc.record_backtrace true;
    Driver.load_driver env alt_ergo.Whyconf.driver []
  with e ->
    let s = Printexc.get_backtrace () in
    eprintf "Failed to load driver for alt-ergo: %a@.%s@."
      Exn_printer.exn_printer e s;
  exit 1

let () = log_time ("Initialising why3 worker: end ")

(* *** *)
type task_info = { task : [ `Theory of Theory.theory | `Task of Task.task ];
		   parent_id : id;
		   mutable status : status;
		   mutable subtasks : id list;
		   loc : loc list;
		   expl : string; }

let task_table : (id, task_info) Hashtbl.t = Hashtbl.create 17

let split_trans = Trans.lookup_transform_l "split_goal_wp" env

let task_to_string t =
  ignore (flush_str_formatter ());
  Driver.print_task alt_ergo_driver str_formatter t;
  flush_str_formatter ()

let gen_id =
  let c = ref 0 in
  fun () -> incr c; "id" ^ (string_of_int !c)

let send msg =
  ignore (Worker.post_message (marshal msg))

let get_loc l =
  match l with
    Some (l) ->
    let _, l, c1, c2 = Loc.get l in
    Some (l, c1, l, c2)
  | _ -> None


let register_task parent_id task =
  let id = gen_id () in
  let vid, expl, _ = Termcode.goal_expl_task ~root:false task in
  let expl = match expl with
    | Some s -> s
    | None -> vid.Ident.id_string
  in
  let task_info = { task = `Task(task);
		    parent_id = parent_id;
		    status = `New;
		    subtasks = [];
		    loc = [ (* todo *) ];
		    expl = expl }
  in
  Hashtbl.add task_table id task_info;
  id

let get_task = function `Task t -> t
                      | `Theory _ -> log ("called get_task on a theory !"); assert false



let rec set_status id st =
  try
    let info = Hashtbl.find task_table id in
    if info.status <> st then begin
	info.status <- st;
	send (UpdateStatus (st, id));
	let par_info = Hashtbl.find task_table info.parent_id in
	let has_new, has_unknown =
	  List.fold_left
	    (fun (an, au) id ->
	     let info = Hashtbl.find task_table id in
	     (an || info.status = `New), (au || info.status = `Unknown))
	    (false, false) par_info.subtasks
	in
	let par_status = if has_new then `New else if
			   has_unknown then `Unknown
			 else `Valid
	in
	if par_info.status <> par_status then
	  set_status info.parent_id par_status 
      end
  with
    Not_found -> ()



let rec why3_prove id =
  let t = Hashtbl.find task_table id in
  match t.subtasks with
    [] ->  t.status <- `Unknown;
	   let task = get_task t.task in
	   let msg = Task (id, t.parent_id, t.expl, task_to_string task, t.loc) in
	   send msg;
	   set_status id `New
  | l -> List.iter why3_prove l


let why3_split id =
  try
    let t = Hashtbl.find task_table id in
    match t.subtasks with
      [] ->
      let subtasks = Trans.apply split_trans (get_task t.task) in
      t.subtasks <- List.fold_left (fun acc t ->
				    let tid = register_task id t in
				    why3_prove tid;
				    tid :: acc) [] subtasks
    | _ -> ()
  with
    Not_found -> log ("No task with id " ^ id)


let rec clean_task id =
  try
    let info = Hashtbl.find task_table id in
    List.iter clean_task info.subtasks;
    Hashtbl.remove task_table id
  with
    Not_found -> ()

let why3_clean id =
  try
    let t = Hashtbl.find task_table id in
    List.iter clean_task t.subtasks;
    t.subtasks <- [];
    set_status id `Unknown;
  with
    Not_found -> ()

let why3_parse_theories theories =
  let theories =
    Stdlib.Mstr.fold
      (fun thname th acc ->
       let loc =
         Opt.get_def Loc.dummy_position th.Theory.th_name.Ident.id_loc
       in
       (loc, (thname, th)) :: acc) theories []
  in
  let theories = List.sort  (fun (l1,_) (l2,_) -> Loc.compare l1 l2) theories in
  List.iter
    (fun (_, (th_name, th)) ->
     let th_id = gen_id () in
     let () = send (Theory(th_id, th_name)) in
     send (UpdateStatus(`New, th_id));
     let tasks = Task.split_theory th None None in
     let task_ids = List.fold_left (fun acc t ->
				    let tid = register_task th_id t in
				    why3_prove tid;
				    tid:: acc) [] tasks in
     Hashtbl.add task_table th_id  { task = `Theory(th);
				     parent_id = "theory-list";
				     status = `New;
				     subtasks = task_ids;
				     loc = [ (* todo *) ];
				     expl = th_name }
    ) theories

let execute_symbol m fmt ps =
  match Mlw_decl.find_definition m.Mlw_module.mod_known ps with
  | None ->
     fprintf fmt "function '%s' has no definition"
	     ps.Mlw_expr.ps_name.Ident.id_string
  | Some d ->
    let lam = d.Mlw_expr.fun_lambda in
    match lam.Mlw_expr.l_args with
    | [pvs] when
        Mlw_ty.ity_equal pvs.Mlw_ty.pv_ity Mlw_ty.ity_unit ->
      begin
        let spec = lam.Mlw_expr.l_spec in
        let eff = spec.Mlw_ty.c_effect in
        let writes = eff.Mlw_ty.eff_writes in
        let body = lam.Mlw_expr.l_expr in
        try
          let res, _final_env =
            Mlw_interp.eval_global_expr env m.Mlw_module.mod_known
              m.Mlw_module.mod_theory.Theory.th_known writes body
          in
          match res with
          | Mlw_interp.Normal v -> Mlw_interp.print_value fmt v
          | Mlw_interp.Excep(x,v) ->
            fprintf fmt "exception %s(%a)"
              x.Mlw_ty.xs_name.Ident.id_string Mlw_interp.print_value v
          | Mlw_interp.Irred e ->
            fprintf fmt "cannot execute expression@ @[%a@]"
              Mlw_pretty.print_expr e
          | Mlw_interp.Fun _ ->
            fprintf fmt "result is a function"
        with e ->
          fprintf fmt
            "failure during execution of function: %a (%s)"
            Exn_printer.exn_printer e
            (Printexc.to_string e)
    end
  | _ ->
    fprintf fmt "Only functions with one unit argument can be executed"

let why3_execute (modules,_theories) =
  let result =
    let mods =
      Stdlib.Mstr.fold
	(fun _k m acc ->
         let th = m.Mlw_module.mod_theory in
         let modname = th.Theory.th_name.Ident.id_string in
         try
           let ps =
             Mlw_module.ns_find_ps m.Mlw_module.mod_export ["main"]
           in
           let result = Pp.sprintf "%a" (execute_symbol m) ps in
           let loc =
             Opt.get_def Loc.dummy_position th.Theory.th_name.Ident.id_loc
           in
           (loc, modname ^ ".main() returns " ^ result)
           :: acc
         with Not_found -> acc)
	modules []
    in
    match mods with
    | [] -> Error "No main function found"
    | _ ->
       let s =
	 List.sort
           (fun (l1,_) (l2,_) -> Loc.compare l2 l1)
           mods
       in
       (Result (List.rev_map snd s) )
  in
  send result

let temp_file_name = "/input.mlw"

let () = Sys_js.register_file ~name:temp_file_name ~content:""

let why3_run f lang code =
  try
    log_time "Why3 worker : start writing file";
    let ch = open_out temp_file_name in
    output_string ch code;
    close_out ch;
    log_time "Why3 worker : stop writing file";

    (* TODO: add a function Env.read_string or Env.read_from_lexbuf ? *)
    log_time "Why3 worker : start parsing file";

    let theories = Env.read_file lang env temp_file_name in
    log_time "Why3 worker : stop parsing file";
    f theories
  with
  | Loc.Located(loc,e') ->
     let _, l, b, e = Loc.get loc in
     send (ErrorLoc ((l-1,b, l-1, e),
		     Pp.sprintf
		       "error line %d, columns %d-%d: %a" l b e
		       Exn_printer.exn_printer e'))
  | e ->
     send (Error (Pp.sprintf
		    "unexpected exception: %a (%s)" Exn_printer.exn_printer e
		    (Printexc.to_string e)))


let () =

  Worker.set_onmessage
    (fun ev ->

     log_time ("Entering why3 worker ");
     let ev = unmarshal ev in
     log_time ("After unmarshal ");
     match ev with
     | Transform (`Split, id) -> why3_split id
     | Transform (`Prove, id) -> why3_prove id
     | Transform (`Clean, id) -> why3_clean id
     | ParseBuffer code ->
        Hashtbl.clear task_table;
        why3_run why3_parse_theories Env.base_language code
     | ExecuteBuffer code ->
	why3_run why3_execute Mlw_module.mlw_language code
     | SetStatus (st, id) -> set_status id st
    )
(*
Local Variables:
compile-command: "unset LANG; make -C ../.. src/trywhy3/trywhy3.js"
End:
*)
