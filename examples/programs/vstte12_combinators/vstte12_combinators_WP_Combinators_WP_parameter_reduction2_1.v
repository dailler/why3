(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive term  :=
  | S : term 
  | K : term 
  | App : term -> term -> term .
Axiom term_WhyType : WhyType term.
Existing Instance term_WhyType.

(* Why3 assumption *)
Fixpoint is_value(t:term) {struct t}: Prop :=
  match t with
  | (K|S) => True
  | ((App K v)|(App S v)) => (is_value v)
  | (App (App S v1) v2) => (is_value v1) /\ (is_value v2)
  | _ => False
  end.

(* Why3 assumption *)
Inductive context  :=
  | Hole : context 
  | Left : context -> term -> context 
  | Right : term -> context -> context .
Axiom context_WhyType : WhyType context.
Existing Instance context_WhyType.

(* Why3 assumption *)
Fixpoint is_context(c:context) {struct c}: Prop :=
  match c with
  | Hole => True
  | (Left c1 _) => (is_context c1)
  | (Right v c1) => (is_value v) /\ (is_context c1)
  end.

(* Why3 assumption *)
Fixpoint subst(c:context) (t:term) {struct c}: term :=
  match c with
  | Hole => t
  | (Left c1 t2) => (App (subst c1 t) t2)
  | (Right v1 c2) => (App v1 (subst c2 t))
  end.

(* Why3 assumption *)
Inductive infix_mnmngt : term -> term -> Prop :=
  | red_K : forall (c:context), (is_context c) -> forall (v1:term) (v2:term),
      (is_value v1) -> ((is_value v2) -> (infix_mnmngt (subst c (App (App K
      v1) v2)) (subst c v1)))
  | red_S : forall (c:context), (is_context c) -> forall (v1:term) (v2:term)
      (v3:term), (is_value v1) -> ((is_value v2) -> ((is_value v3) ->
      (infix_mnmngt (subst c (App (App (App S v1) v2) v3)) (subst c
      (App (App v1 v3) (App v2 v3)))))).

Axiom red_left : forall (t1:term) (t2:term) (t:term), (infix_mnmngt t1 t2) ->
  (infix_mnmngt (App t1 t) (App t2 t)).

Axiom red_right : forall (v:term) (t1:term) (t2:term), (is_value v) ->
  ((infix_mnmngt t1 t2) -> (infix_mnmngt (App v t1) (App v t2))).

(* Why3 assumption *)
Inductive relTR : term -> term -> Prop :=
  | BaseTransRefl : forall (x:term), (relTR x x)
  | StepTransRefl : forall (x:term) (y:term) (z:term), (relTR x y) ->
      ((infix_mnmngt y z) -> (relTR x z)).

Axiom relTR_transitive : forall (x:term) (y:term) (z:term), (relTR x y) ->
  ((relTR y z) -> (relTR x z)).

Axiom red_star_left : forall (t1:term) (t2:term) (t:term), (relTR t1 t2) ->
  (relTR (App t1 t) (App t2 t)).

Axiom red_star_right : forall (v:term) (t1:term) (t2:term), (is_value v) ->
  ((relTR t1 t2) -> (relTR (App v t1) (App v t2))).

Axiom reducible_or_value : forall (t:term), (exists t':term, (infix_mnmngt t
  t')) \/ (is_value t).

(* Why3 assumption *)
Definition irreducible(t:term): Prop := forall (t':term), ~ (infix_mnmngt t
  t').

Axiom irreducible_is_value : forall (t:term), (irreducible t) <->
  (is_value t).

(* Why3 assumption *)
Inductive only_K : term -> Prop :=
  | only_K_K : (only_K K)
  | only_K_App : forall (t1:term) (t2:term), (only_K t1) -> ((only_K t2) ->
      (only_K (App t1 t2))).

Axiom only_K_reduces : forall (t:term), (only_K t) -> exists v:term, (relTR t
  v) /\ ((is_value v) /\ (only_K v)).

(* Why3 assumption *)
Fixpoint size(t:term) {struct t}: Z :=
  match t with
  | (K|S) => 0%Z
  | (App t1 t2) => ((1%Z + (size t1))%Z + (size t2))%Z
  end.

Axiom size_nonneg : forall (t:term), (0%Z <= (size t))%Z.

(* Why3 goal *)
Theorem WP_parameter_reduction2 : forall (t:term), (only_K t) ->
  match t with
  | S => True
  | K => True
  | (App t1 t2) => (only_K t1) -> forall (result:term), ((only_K result) /\
      (is_value result)) ->
      match result with
      | K => True
      | S => True
      | (App K v1) => True
      | (App S v1) => True
      | (App (App S v1) v2) => (only_K t2) -> forall (v3:term),
          ((only_K v3) /\ (is_value v3)) -> ((size (App (App v1 v3) (App v2
          v3))) < (size t))%Z
      | _ => True
      end
  end.
intuition.
destruct t; intuition.
destruct result; intuition.
destruct result1; intuition.
destruct result1_1; intuition.
inversion H2.
inversion H8.
inversion H12.
Qed.


