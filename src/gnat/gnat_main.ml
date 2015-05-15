(* This is the main file of gnatwhy3 *)

(* Gnatwhy3 does the following:
   - it reads a .mlw file that was generated by gnat2why
   - it computes the VCs
   - it runs the selected provers on each VC.
   - it generates a summary of what was proved and not proved in JSON format
 and outputs this JSON format to stdout (for gnat2why to read).

   See gnat_objectives.mli for the notion of objective and goal.

   See gnat_report.mli for the JSON format

   gnat_main can be seen as the "driver" for gnatwhy3. Much of the
   functionality is elsewhere.
   Specifically, this file does:
      - compute the objective that belongs to a goal/VC
      - drive the scheduling of VCs, and handling of results
      - output the messages
*)

open Why3
open Term

let rec search_labels t =
  let acc =
   match t.t_node with
   | Tbinop (Timplies,_, t) -> search_labels t
   | Tlet (_,tb) | Teps tb ->
         let _, t = t_open_bound tb in
         search_labels t
   | Tquant (_,tq) ->
         let _,_,t = t_open_quant tq in
         search_labels t
   | Tnot t ->
         search_labels t
   | _ -> None
  in
  match acc with
  | None -> Gnat_expl.extract_check t.t_label
  | Some _ -> acc

let rec is_trivial fml =
   (* Check wether the formula is trivial.  *)
   match fml.t_node with
   | Ttrue -> true
   | Tquant (_,tq) ->
         let _,_,t = t_open_quant tq in
         is_trivial t
   | Tlet (_,tb) ->
         let _, t = t_open_bound tb in
         is_trivial t
   | Tbinop (Timplies,_,t2) ->
         is_trivial t2
   | Tcase (_,tbl) ->
         List.for_all (fun b ->
            let _, t = t_open_branch b in
            is_trivial t) tbl
   | _ -> false

let register_goal goal =
   (* Register the goal by extracting the explanation and trace. If the goal is
    * trivial, do not register *)
   let task = Session.goal_task goal in
   let fml = Task.task_goal_fmla task in
   match is_trivial fml, search_labels fml with
   | true, None ->
         Gnat_objectives.set_not_interesting goal
   | _, None ->
         Gnat_util.abort_with_message ~internal:true
         "Task has no tracability label."
   | _, Some c ->
       Gnat_objectives.add_to_objective c goal

let rec handle_vc_result goal result prover_result manual_info =
   (* This function is called when the prover has returned from a VC.
       goal           is the VC that the prover has dealt with
       result         a boolean, true if the prover has proved the VC
       prover_result  the actual proof result, to extract statistics
   *)
   let obj, status = Gnat_objectives.register_result goal result in
   let task = Session.goal_task goal in
   match status with
   | Gnat_objectives.Proved ->
       Gnat_report.register obj (Some task) prover_result true None ""
   | Gnat_objectives.Not_Proved ->
       let tracefile =
         match Gnat_config.proof_mode with
         | Gnat_config.Then_Split | Gnat_config.Path_WP ->
           Gnat_objectives.Save_VCs.save_trace goal
         | _ -> ""
       in
       Gnat_report.register obj (Some task) prover_result
                            false manual_info tracefile
   | Gnat_objectives.Work_Left ->
       List.iter (create_manual_or_schedule obj) (Gnat_objectives.next obj)

and interpret_result pa pas =
   (* callback function for the scheduler, here we filter if an interesting
      goal has been dealt with, and only then pass on to handle_vc_result *)
   match pas with
   | Session.Done r ->
         let goal = pa.Session.proof_parent in
         let answer = r.Call_provers.pr_answer in
         let info = Gnat_manual.manual_proof_info pa in
         if answer = Call_provers.HighFailure then
           Gnat_report.add_warning r.Call_provers.pr_output;
         handle_vc_result goal (answer = Call_provers.Valid) (Some r) info
   | _ ->
         ()

and create_manual_or_schedule obj goal =
  match Gnat_config.manual_prover with
  | Some _ when Gnat_objectives.goal_has_splits goal &&
                goal.Session.goal_verified = None ->
                  handle_vc_result goal false None None
  | Some p when Gnat_manual.is_new_manual_proof goal &&
                goal.Session.goal_verified = None ->
                  let _ = Gnat_manual.create_prover_file goal obj p in
                  let pa = Gnat_manual.manual_attempt_of_goal goal in
                  let info = Gnat_manual.manual_proof_info (Opt.get pa) in
                  Gnat_report.register obj None None false info ""
  | _ -> schedule_goal goal

and schedule_goal (g : Gnat_objectives.goal) =
   (* schedule a goal for proof - the goal may not be scheduled actually,
      because we detect that it is not necessary. This may have several
      reasons:
         * command line given to skip proofs
         * goal already proved
         * goal already attempted with identical options
   *)
   if Gnat_config.force && Gnat_config.manual_prover = None then
     Gnat_objectives.clean_automatic_proofs g;
   if Gnat_config.force || (Gnat_config.manual_prover <> None
                            && g.Session.goal_verified = None) then begin
    (* then implement reproving logic *)
   end else begin
      (* Maybe the goal is already proved *)
      if g.Session.goal_verified <> None then begin
         handle_vc_result g true None None
      (* Maybe there was a previous proof attempt with identical parameters *)
      end else if Gnat_objectives.all_provers_tried g then begin
         (* the proof attempt was necessarily false *)
         handle_vc_result g false None None
      end else begin
         actually_schedule_goal g
      end;
   end

and actually_schedule_goal g =
  if Gnat_config.manual_prover <> None then
     (* We need to rewrite the goal if we are working with a manual prover
        because if the user modified code produced by why3, the file might
        be proven when it is incomplete or not corresponding to our
        original VC *)
     Gnat_manual.rewrite_goal g;
  Gnat_objectives.schedule_goal g

let handle_obj obj =
   if Gnat_objectives.objective_status obj =
      Gnat_objectives.Proved then begin
        Gnat_report.register obj None None true None ""
   end else begin
      match Gnat_objectives.next obj with
      | [] -> ()
      | l ->
         List.iter (create_manual_or_schedule obj) l
   end

let normal_handle_one_subp subp =
   if Gnat_objectives.matches_subp_filter subp then begin
     Gnat_objectives.init_subp_vcs subp;
     Gnat_objectives.iter_leaf_goals subp register_goal
   end

let all_split_subp subp =
   if Gnat_objectives.matches_subp_filter subp then begin
     Gnat_objectives.init_subp_vcs subp;
     Gnat_objectives.iter_leaf_goals subp register_goal;
     Gnat_objectives.all_split_leaf_goals ();
     Gnat_objectives.clear ()
   end

let _ =
   (* This is the main code. We read the file into the session if not already
      done, we apply the split_goal transformation when needed, and we schedule
      the first VC of all objectives. When done, we save the session.
   *)
   (* save session on interrupt initiated by the user *)
   let save_session_and_exit signum =
     (* ignore all SIGINT, SIGHUP and SIGTERM, which may be received when
        gnatprove is called in GPS, so that the session file is always saved *)
     Sys.set_signal Sys.sigint Sys.Signal_ignore;
     Sys.set_signal Sys.sighup Sys.Signal_ignore;
     Sys.set_signal Sys.sigterm Sys.Signal_ignore;
     Gnat_objectives.save_session ();
     exit signum
   in
   Sys.set_signal Sys.sigint (Sys.Signal_handle save_session_and_exit);

   try
      Gnat_objectives.init ();
      match Gnat_config.proof_mode with
      | Gnat_config.Then_Split
      | Gnat_config.Path_WP
      | Gnat_config.No_Split ->
         Gnat_objectives.iter_subps normal_handle_one_subp;
         Gnat_objectives.iter handle_obj;
         Gnat_objectives.do_scheduled_jobs interpret_result;
         Gnat_objectives.clear ();
         Gnat_report.print_messages ();
         Gnat_objectives.save_session ()
      | Gnat_config.All_Split ->
         Gnat_objectives.iter_subps all_split_subp
      | Gnat_config.No_WP ->
         (* we should never get here *)
         ()
    with e ->
       let s = Pp.sprintf "%a.@." Exn_printer.exn_printer e in
       Gnat_util.abort_with_message ~internal:true s
