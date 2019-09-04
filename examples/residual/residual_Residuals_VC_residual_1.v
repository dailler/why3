(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.
Require list.List.
Require list.Length.
Require list.Mem.
Require list.Append.

Axiom char : Type.
Parameter char_WhyType : WhyType char.
Existing Instance char_WhyType.

Parameter eq: char -> char -> Prop.

Axiom eq'spec : forall (x:char) (y:char), eq x y <-> (x = y).

(* Why3 assumption *)
Inductive regexp :=
  | Empty : regexp
  | Epsilon : regexp
  | Char : char -> regexp
  | Alt : regexp -> regexp -> regexp
  | Concat : regexp -> regexp -> regexp
  | Star : regexp -> regexp.
Axiom regexp_WhyType : WhyType regexp.
Existing Instance regexp_WhyType.

(* Why3 assumption *)
Definition word := Init.Datatypes.list char.

(* Why3 assumption *)
Inductive mem: Init.Datatypes.list char -> regexp -> Prop :=
  | mem_eps : mem Init.Datatypes.nil Epsilon
  | mem_char :
      forall (c:char),
      mem (Init.Datatypes.cons c Init.Datatypes.nil) (Char c)
  | mem_altl :
      forall (w:Init.Datatypes.list char) (r1:regexp) (r2:regexp),
      mem w r1 -> mem w (Alt r1 r2)
  | mem_altr :
      forall (w:Init.Datatypes.list char) (r1:regexp) (r2:regexp),
      mem w r2 -> mem w (Alt r1 r2)
  | mem_concat :
      forall (w1:Init.Datatypes.list char) (w2:Init.Datatypes.list char)
        (r1:regexp) (r2:regexp),
      mem w1 r1 -> mem w2 r2 -> mem (Init.Datatypes.app w1 w2) (Concat r1 r2)
  | mems1 : forall (r:regexp), mem Init.Datatypes.nil (Star r)
  | mems2 :
      forall (w1:Init.Datatypes.list char) (w2:Init.Datatypes.list char)
        (r:regexp),
      mem w1 r -> mem w2 (Star r) -> mem (Init.Datatypes.app w1 w2) (Star r).

Axiom inversion_mem_star_gen :
  forall (c:char) (w:Init.Datatypes.list char) (r:regexp)
    (w':Init.Datatypes.list char) (r':regexp),
  (w' = (Init.Datatypes.cons c w)) /\ (r' = (Star r)) -> mem w' r' ->
  exists w1:Init.Datatypes.list char, exists w2:Init.Datatypes.list char,
  (w = (Init.Datatypes.app w1 w2)) /\
  mem (Init.Datatypes.cons c w1) r /\ mem w2 r'.

Axiom inversion_mem_star :
  forall (c:char) (w:Init.Datatypes.list char) (r:regexp),
  mem (Init.Datatypes.cons c w) (Star r) ->
  exists w1:Init.Datatypes.list char, exists w2:Init.Datatypes.list char,
  (w = (Init.Datatypes.app w1 w2)) /\
  mem (Init.Datatypes.cons c w1) r /\ mem w2 (Star r).

(* Why3 goal *)
Theorem residual'VC :
  forall (r:regexp) (c:char), forall (result:regexp),
  (exists x:regexp, exists x1:regexp,
   (r = (Concat x x1)) /\
   mem Init.Datatypes.nil x /\
   (exists o:regexp,
    (forall (w:Init.Datatypes.list char),
     mem w o <-> mem (Init.Datatypes.cons c w) x1) /\
    (exists o1:regexp,
     (forall (w:Init.Datatypes.list char),
      mem w o1 <-> mem (Init.Datatypes.cons c w) x) /\
     (result = (Alt (Concat o1 x1) o))))) ->
  forall (w:Init.Datatypes.list char), mem w result ->
  mem (Init.Datatypes.cons c w) r.
Proof.
intros r c result (x,(x1,(h1,(h2,(o,(h3,(o1,(h4,h5)))))))) w h6.
subst.
inversion h6; subst; clear h6.
inversion H1; subst; clear H1.
replace ((c :: (w1 ++ w2))%list) with (((c :: w1) ++ w2)%list) by auto.
apply mem_concat; auto.
now rewrite <- h4.
replace ((c :: w)%list) with ((nil ++ (c :: w))%list) by auto.
apply mem_concat; auto.
now rewrite <- h3.
Qed.
