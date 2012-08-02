(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import ZArith.
Require Import Rbase.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

(* Why3 assumption *)
Inductive list (a:Type) :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Set Contextual Implicit.
Implicit Arguments Nil.
Unset Contextual Implicit.
Implicit Arguments Cons.

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint infix_plpl (a:Type)(l1:(list a)) (l2:(list a)) {struct l1}: (list
  a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.
Unset Implicit Arguments.

Axiom Append_assoc : forall (a:Type), forall (l1:(list a)) (l2:(list a))
  (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall (a:Type), forall (l:(list a)), ((infix_plpl l
  (Nil :(list a))) = l).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint length (a:Type)(l:(list a)) {struct l}: Z :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.
Unset Implicit Arguments.

Axiom Length_nonnegative : forall (a:Type), forall (l:(list a)),
  (0%Z <= (length l))%Z.

Axiom Length_nil : forall (a:Type), forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Axiom Append_length : forall (a:Type), forall (l1:(list a)) (l2:(list a)),
  ((length (infix_plpl l1 l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Set Implicit Arguments.
Fixpoint mem (a:Type)(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem x r)
  end.
Unset Implicit Arguments.

Axiom mem_append : forall (a:Type), forall (x:a) (l1:(list a)) (l2:(list a)),
  (mem x (infix_plpl l1 l2)) <-> ((mem x l1) \/ (mem x l2)).

Axiom mem_decomp : forall (a:Type), forall (x:a) (l:(list a)), (mem x l) ->
  exists l1:(list a), exists l2:(list a), (l = (infix_plpl l1 (Cons x l2))).

Parameter map : forall (a:Type) (b:Type), Type.

Parameter get: forall (a:Type) (b:Type), (map a b) -> a -> b.
Implicit Arguments get.

Parameter set: forall (a:Type) (b:Type), (map a b) -> a -> b -> (map a b).
Implicit Arguments set.

Axiom Select_eq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) -> ((get (set m a1 b1)
  a2) = b1).

Axiom Select_neq : forall (a:Type) (b:Type), forall (m:(map a b)),
  forall (a1:a) (a2:a), forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1)
  a2) = (get m a2)).

Parameter const: forall (a:Type) (b:Type), b -> (map a b).
Set Contextual Implicit.
Implicit Arguments const.
Unset Contextual Implicit.

Axiom Const : forall (a:Type) (b:Type), forall (b1:b) (a1:a),
  ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive array (a:Type) :=
  | mk_array : Z -> (map Z a) -> array a.
Implicit Arguments mk_array.

(* Why3 assumption *)
Definition elts (a:Type)(v:(array a)): (map Z a) :=
  match v with
  | (mk_array x x1) => x1
  end.
Implicit Arguments elts.

(* Why3 assumption *)
Definition length1 (a:Type)(v:(array a)): Z :=
  match v with
  | (mk_array x x1) => x
  end.
Implicit Arguments length1.

(* Why3 assumption *)
Definition get1 (a:Type)(a1:(array a)) (i:Z): a := (get (elts a1) i).
Implicit Arguments get1.

(* Why3 assumption *)
Definition set1 (a:Type)(a1:(array a)) (i:Z) (v:a): (array a) :=
  (mk_array (length1 a1) (set (elts a1) i v)).
Implicit Arguments set1.

(* Why3 assumption *)
Inductive buffer (a:Type) :=
  | mk_buffer : Z -> Z -> (array a) -> buffer a.
Implicit Arguments mk_buffer.

(* Why3 assumption *)
Definition data (a:Type)(v:(buffer a)): (array a) :=
  match v with
  | (mk_buffer x x1 x2) => x2
  end.
Implicit Arguments data.

(* Why3 assumption *)
Definition len (a:Type)(v:(buffer a)): Z :=
  match v with
  | (mk_buffer x x1 x2) => x1
  end.
Implicit Arguments len.

(* Why3 assumption *)
Definition first (a:Type)(v:(buffer a)): Z :=
  match v with
  | (mk_buffer x x1 x2) => x
  end.
Implicit Arguments first.

(* Why3 assumption *)
Definition size (a:Type)(b:(buffer a)): Z := (length1 (data b)).
Implicit Arguments size.

(* Why3 assumption *)
Definition buffer_invariant (a:Type)(b:(buffer a)): Prop :=
  ((0%Z <= (first b))%Z /\ ((first b) < (size b))%Z) /\
  ((0%Z <= (len b))%Z /\ ((len b) <= (size b))%Z).
Implicit Arguments buffer_invariant.

Parameter sequence: forall (a:Type), (buffer a) -> (list a).
Implicit Arguments sequence.

Axiom sequence_def_1 : forall (a:Type), forall (b:(buffer a)),
  (buffer_invariant b) -> (((len b) = 0%Z) -> ((sequence b) = (Nil :(list
  a)))).

Axiom sequence_def_2 : forall (a:Type), forall (b:(buffer a)),
  (buffer_invariant b) -> ((0%Z < (len b))%Z ->
  ((((first b) + 1%Z)%Z < (size b))%Z -> ((sequence b) = (Cons (get1 (data b)
  (first b)) (sequence (mk_buffer ((first b) + 1%Z)%Z ((len b) - 1%Z)%Z
  (data b))))))).

Axiom sequence_def_3 : forall (a:Type), forall (b:(buffer a)),
  (buffer_invariant b) -> ((0%Z < (len b))%Z ->
  ((((first b) + 1%Z)%Z = (size b)) -> ((sequence b) = (Cons (get1 (data b)
  (first b)) (sequence (mk_buffer 0%Z ((len b) - 1%Z)%Z (data b))))))).

Axiom sequence_ind_1 : forall (a:Type), forall (b:(buffer a)),
  (buffer_invariant b) -> ((0%Z < (len b))%Z ->
  (((((first b) + (len b))%Z - 1%Z)%Z < (size b))%Z ->
  ((sequence b) = (infix_plpl (sequence (mk_buffer (first b)
  ((len b) - 1%Z)%Z (data b))) (Cons (get1 (data b)
  (((first b) + (len b))%Z - 1%Z)%Z) (Nil :(list a))))))).

Axiom sequence_ind_2 : forall (a:Type), forall (b:(buffer a)),
  (buffer_invariant b) -> ((0%Z < (len b))%Z ->
  (((size b) <= (((first b) + (len b))%Z - 1%Z)%Z)%Z ->
  ((sequence b) = (infix_plpl (sequence (mk_buffer (first b)
  ((len b) - 1%Z)%Z (data b))) (Cons (get1 (data b)
  ((((first b) + (len b))%Z - 1%Z)%Z - (size b))%Z) (Nil :(list a))))))).

Axiom sequence_invariance : forall (a:Type), forall (b1:(buffer a))
  (b2:(buffer a)), (buffer_invariant b1) -> ((buffer_invariant b2) ->
  (((first b1) = (first b2)) -> (((len b1) = (len b2)) ->
  (((size b1) = (size b2)) -> ((forall (i:Z), (((first b1) <= i)%Z /\
  (i < ((first b1) + (len b1))%Z)%Z) -> ((i < (size b1))%Z ->
  ((get1 (data b1) i) = (get1 (data b2) i)))) -> ((forall (i:Z),
  ((0%Z <= i)%Z /\ (i < (((first b1) + (len b1))%Z - (size b1))%Z)%Z) ->
  ((get1 (data b1) i) = (get1 (data b2) i))) ->
  ((sequence b1) = (sequence b2)))))))).


(* Why3 goal *)
Theorem WP_parameter_push : forall (a:Type), forall (b:Z) (x:a),
  forall (rho:(map Z a)) (rho1:Z) (rho2:Z), let b1 := (mk_buffer rho2 rho1
  (mk_array b rho)) in (((rho1 < b)%Z /\ (buffer_invariant b1)) ->
  (((((b <= (rho2 + rho1)%Z)%Z /\ (0%Z <= ((rho2 + rho1)%Z - b)%Z)%Z) \/
  ((~ (b <= (rho2 + rho1)%Z)%Z) /\ (0%Z <= (rho2 + rho1)%Z)%Z)) /\
  (((b <= (rho2 + rho1)%Z)%Z /\ (((rho2 + rho1)%Z - b)%Z < b)%Z) \/
  ((~ (b <= (rho2 + rho1)%Z)%Z) /\ ((rho2 + rho1)%Z < b)%Z))) ->
  forall (o:(map Z a)), (((b <= (rho2 + rho1)%Z)%Z /\ (o = (set rho
  ((rho2 + rho1)%Z - b)%Z x))) \/ ((~ (b <= (rho2 + rho1)%Z)%Z) /\
  (o = (set rho (rho2 + rho1)%Z x)))) -> forall (rho3:Z),
  (rho3 = (rho1 + 1%Z)%Z) -> ((sequence (mk_buffer rho2 rho3 (mk_array b
  o))) = (infix_plpl (sequence b1) (Cons x (Nil :(list a))))))).
(* YOU MAY EDIT THE PROOF BELOW *)
intuition.
rename a into t.
rename rho into a. rename rho1 into b_len. rename rho2 into b_first.
rename b into b_size.
intuition.
(* 1 *)
(*clear H H1 H5.*)
subst o rho3.
red in H2. simpl in H2. unfold size in H2. simpl in H2.
rewrite sequence_ind_2. simpl.
apply f_equal2.
ring_simplify (b_len+1-1)%Z.
apply sequence_invariance; simpl; intuition.
red; intuition.
red; intuition.
unfold get1; simpl; intuition. rewrite Select_neq; (omega || auto).
unfold get1; simpl; intuition. rewrite Select_neq; (omega || auto).
unfold size in H11. simpl in H11. omega.
apply f_equal2; auto.
unfold get1, size; simpl.
rewrite Select_eq; try omega. auto.
red; unfold size; simpl; intuition.
unfold size; intuition.
unfold len; simpl. omega.
simpl.
unfold size; simpl.
omega.
(* 2 *)
(*discriminate H10.*)
(* 3 *)
(*clear H H3 H0.*)
subst rho3 o.
red in H2. simpl in H2. unfold size in H2. simpl in H2.
rewrite sequence_ind_1. simpl.
apply f_equal2.
ring_simplify (b_len+1-1)%Z.
apply sequence_invariance; simpl; intuition.
red; intuition.
red; intuition.
unfold get1; simpl; intuition. rewrite Select_neq; (omega || auto).
unfold get1; simpl; intuition. rewrite Select_neq; (omega || auto).
unfold size in H11. simpl in H11. omega.
apply f_equal2; auto.
unfold get1, size; simpl.
rewrite Select_eq; try omega. auto.
red; unfold size; simpl; intuition.
unfold size; intuition.
unfold len; simpl. omega.
simpl.
unfold size; simpl.
omega.
Qed.


