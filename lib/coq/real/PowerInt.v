(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require Import Rfunctions.
Require BuiltIn.
Require int.Int.
Require real.Real.
Require real.RealInfix.

Require Import Exponentiation.

(* Why3 goal *)
Notation power := powerRZ.

Lemma power_is_exponentiation :
  forall x n, (0 <= n)%Z -> power x n = Exponentiation.power _ R1 Rmult x n.
Proof.
intros x [|n|n] H.
easy.
2: now elim H.
unfold Exponentiation.power, powerRZ.
simpl.
induction (nat_of_P n).
easy.
simpl.
now rewrite IHn0.
Qed.

(* Why3 goal *)
Lemma Power_0 : forall (x:R), ((power x 0%Z) = 1%R).
Proof.
intros x.
easy.
Qed.

(* Why3 goal *)
Lemma Power_s : forall (x:R) (n:Z), (0%Z <= n)%Z -> ((power x
  (n + 1%Z)%Z) = (x * (power x n))%R).
Proof.
intros x n h1.
rewrite 2!power_is_exponentiation by auto with zarith.
now apply Power_s.
Qed.

(* Why3 goal *)
Lemma Power_s_alt : forall (x:R) (n:Z), (0%Z < n)%Z -> ((power x
  n) = (x * (power x (n - 1%Z)%Z))%R).
intros x n h1.
rewrite <- Power_s.
f_equal; omega.
omega.
Qed.

(* Why3 goal *)
Lemma Power_1 : forall (x:R), ((power x 1%Z) = x).
Proof.
exact Rmult_1_r.
Qed.

(* Why3 goal *)
Lemma Power_sum : forall (x:R) (n:Z) (m:Z), (0%Z <= n)%Z -> ((0%Z <= m)%Z ->
  ((power x (n + m)%Z) = ((power x n) * (power x m))%R)).
Proof.
intros x n m h1 h2.
rewrite 3!power_is_exponentiation by auto with zarith.
apply Power_sum ; auto with real.
Qed.

(* Why3 goal *)
Lemma Power_mult : forall (x:R) (n:Z) (m:Z), (0%Z <= n)%Z -> ((0%Z <= m)%Z ->
  ((power x (n * m)%Z) = (power (power x n) m))).
Proof.
intros x n m h1 h2.
rewrite 3!power_is_exponentiation by auto with zarith.
apply Power_mult ; auto with real.
Qed.

(* Why3 goal *)
Lemma Power_mult2 : forall (x:R) (y:R) (n:Z), (0%Z <= n)%Z ->
  ((power (x * y)%R n) = ((power x n) * (power y n))%R).
Proof.
intros x y n h1.
rewrite 3!power_is_exponentiation by auto with zarith.
apply Power_mult2 ; auto with real.
Qed.

(* Why3 goal *)
Lemma Pow_ge_one : forall (x:R) (n:Z), ((0%Z <= n)%Z /\ (1%R <= x)%R) ->
  (1%R <= (power x n))%R.
intros x n (h1,h2).
generalize h1.
pattern n; apply Z_lt_induction; auto.
clear n h1; intros n Hind h1.
assert (h: (n = 0 \/ 0 < n)%Z) by omega.
destruct h.
subst n; rewrite Power_0; auto with *.
replace n with ((n-1)+1)%Z by omega.
rewrite Power_s; auto with zarith.
assert (h : (1 <= power x (n-1))%R).
apply Hind; omega.
replace 1%R with (1*1)%R by auto with real.
apply Rmult_le_compat; auto with real.
Qed.


