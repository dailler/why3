(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.HdTlNoOpt.
Require list.Append.

(* Why3 assumption *)
Inductive tree :=
  | Leaf : tree
  | Node : tree -> tree -> tree.
Axiom tree_WhyType : WhyType tree.
Existing Instance tree_WhyType.

(* Why3 assumption *)
Fixpoint depths (d:Numbers.BinNums.Z)
  (t:tree) {struct t}: Init.Datatypes.list Numbers.BinNums.Z :=
  match t with
  | Leaf => Init.Datatypes.cons d Init.Datatypes.nil
  | Node l r =>
      Init.Datatypes.app (depths (d + 1%Z)%Z l) (depths (d + 1%Z)%Z r)
  end.

Axiom depths_head :
  forall (t:tree) (d:Numbers.BinNums.Z),
  match depths d t with
  | Init.Datatypes.cons x _ => (d <= x)%Z
  | Init.Datatypes.nil => False
  end.

Axiom depths_unique :
  forall (t1:tree) (t2:tree) (d:Numbers.BinNums.Z)
    (s1:Init.Datatypes.list Numbers.BinNums.Z)
    (s2:Init.Datatypes.list Numbers.BinNums.Z),
  ((Init.Datatypes.app (depths d t1) s1) =
   (Init.Datatypes.app (depths d t2) s2)) ->
  (t1 = t2) /\ (s1 = s2).

Axiom depths_prefix :
  forall (t:tree) (d1:Numbers.BinNums.Z) (d2:Numbers.BinNums.Z)
    (s1:Init.Datatypes.list Numbers.BinNums.Z)
    (s2:Init.Datatypes.list Numbers.BinNums.Z),
  ((Init.Datatypes.app (depths d1 t) s1) =
   (Init.Datatypes.app (depths d2 t) s2)) ->
  (d1 = d2).

Axiom depths_prefix_simple :
  forall (t:tree) (d1:Numbers.BinNums.Z) (d2:Numbers.BinNums.Z),
  ((depths d1 t) = (depths d2 t)) -> (d1 = d2).

Axiom depths_subtree :
  forall (t1:tree) (t2:tree) (d1:Numbers.BinNums.Z) (d2:Numbers.BinNums.Z)
    (s1:Init.Datatypes.list Numbers.BinNums.Z),
  ((Init.Datatypes.app (depths d1 t1) s1) = (depths d2 t2)) -> (d2 <= d1)%Z.

Axiom depths_unique2 :
  forall (t1:tree) (t2:tree) (d1:Numbers.BinNums.Z) (d2:Numbers.BinNums.Z),
  ((depths d1 t1) = (depths d2 t2)) -> (d1 = d2) /\ (t1 = t2).

Lemma depths_length: 
  forall t d, (Length.length (depths d t) >= 1)%Z.
Proof.
  induction t; simpl; intuition.
  rewrite Append.Append_length.
  generalize (IHt1 (d+1))%Z.
  generalize (IHt2 (d+1))%Z.
  omega.
Qed.

(* Why3 goal *)
Theorem harness2'VC :
  forall (us:tree),
  ~ ((depths 0%Z us) =
     (Init.Datatypes.cons 1%Z
      (Init.Datatypes.cons 3%Z
       (Init.Datatypes.cons 2%Z (Init.Datatypes.cons 2%Z Init.Datatypes.nil))))).
Proof.
intro result.
intuition.
destruct result; simpl in H.
discriminate H.
destruct result1; simpl in H.
injection H. intro H1.
destruct result2; simpl in H1.
discriminate H1.
destruct result2_1; simpl in H1.
discriminate H1.
destruct result2_1_1; simpl in H1.
injection H1. intro H2.
destruct result2_1_2; simpl in H2.
discriminate H2.
clear H H1.
generalize (depths_length result2_1_2_1 4).
generalize (depths_length result2_1_2_2 4).
generalize (depths_length result2_2 2).
generalize (f_equal Length.length H2).
simpl.
do 2 (rewrite Append.Append_length).
omega.
(* 4 trees, 3 ints *)
clear H.
generalize (depths_length result2_1_1_1 4).
generalize (depths_length result2_1_1_2 4).
generalize (depths_length result2_1_2 3).
generalize (depths_length result2_2 2).
generalize (f_equal Length.length H1).
simpl.
do 3 (rewrite Append.Append_length).
omega.

destruct result1_1; simpl in H.
discriminate H.
destruct result1_1_1; simpl in H.
discriminate H.
(* 5 trees, 4 ints *)
generalize (depths_length result1_1_1_1 4).
generalize (depths_length result1_1_1_2 4).
generalize (depths_length result1_1_2 3).
generalize (depths_length result1_2 2).
generalize (depths_length result2 1).
generalize (f_equal Length.length H).
simpl.
do 4 (rewrite Append.Append_length).
omega.

Qed.