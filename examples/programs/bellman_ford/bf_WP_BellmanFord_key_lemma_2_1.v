(* This file is generated by Why3's Coq driver *)
(* Beware! Only edit allowed sections below    *)
Require Import BuiltIn.
Require BuiltIn.
Require int.Int.

(* Why3 assumption *)
Definition unit  := unit.

Parameter map : forall (a:Type) {a_WT:WhyType a} (b:Type) {b_WT:WhyType b},
  Type.
Axiom map_WhyType : forall (a:Type) {a_WT:WhyType a}
  (b:Type) {b_WT:WhyType b}, WhyType (map a b).
Existing Instance map_WhyType.

Parameter get: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b.

Parameter set: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  (map a b) -> a -> b -> (map a b).

Axiom Select_eq : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (m:(map a b)), forall (a1:a) (a2:a), forall (b1:b), (a1 = a2) ->
  ((get (set m a1 b1) a2) = b1).

Axiom Select_neq : forall {a:Type} {a_WT:WhyType a}
  {b:Type} {b_WT:WhyType b}, forall (m:(map a b)), forall (a1:a) (a2:a),
  forall (b1:b), (~ (a1 = a2)) -> ((get (set m a1 b1) a2) = (get m a2)).

Parameter const: forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  b -> (map a b).

Axiom Const : forall {a:Type} {a_WT:WhyType a} {b:Type} {b_WT:WhyType b},
  forall (b1:b) (a1:a), ((get (const b1:(map a b)) a1) = b1).

(* Why3 assumption *)
Inductive list (a:Type) {a_WT:WhyType a} :=
  | Nil : list a
  | Cons : a -> (list a) -> list a.
Axiom list_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (list a).
Existing Instance list_WhyType.
Implicit Arguments Nil [[a] [a_WT]].
Implicit Arguments Cons [[a] [a_WT]].

(* Why3 assumption *)
Fixpoint length {a:Type} {a_WT:WhyType a}(l:(list
  a)) {struct l}: BuiltIn.int :=
  match l with
  | Nil => 0%Z
  | (Cons _ r) => (1%Z + (length r))%Z
  end.

Axiom Length_nonnegative : forall {a:Type} {a_WT:WhyType a}, forall (l:(list
  a)), (0%Z <= (length l))%Z.

Axiom Length_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((length l) = 0%Z) <-> (l = (Nil :(list a))).

Parameter set1 : forall (a:Type) {a_WT:WhyType a}, Type.
Axiom set1_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (set1 a).
Existing Instance set1_WhyType.

Parameter mem: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> Prop.

(* Why3 assumption *)
Definition infix_eqeq {a:Type} {a_WT:WhyType a}(s1:(set1 a)) (s2:(set1
  a)): Prop := forall (x:a), (mem x s1) <-> (mem x s2).

Axiom extensionality : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)), (infix_eqeq s1 s2) -> (s1 = s2).

(* Why3 assumption *)
Definition subset {a:Type} {a_WT:WhyType a}(s1:(set1 a)) (s2:(set1
  a)): Prop := forall (x:a), (mem x s1) -> (mem x s2).

Axiom subset_trans : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (s3:(set1 a)), (subset s1 s2) -> ((subset s2 s3) ->
  (subset s1 s3)).

Parameter empty: forall {a:Type} {a_WT:WhyType a}, (set1 a).

(* Why3 assumption *)
Definition is_empty {a:Type} {a_WT:WhyType a}(s:(set1 a)): Prop :=
  forall (x:a), ~ (mem x s).

Axiom empty_def1 : forall {a:Type} {a_WT:WhyType a}, (is_empty (empty :(set1
  a))).

Parameter add: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> (set1 a).

Axiom add_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a),
  forall (s:(set1 a)), (mem x (add y s)) <-> ((x = y) \/ (mem x s)).

Parameter remove: forall {a:Type} {a_WT:WhyType a}, a -> (set1 a) -> (set1
  a).

Axiom remove_def1 : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (y:a)
  (s:(set1 a)), (mem x (remove y s)) <-> ((~ (x = y)) /\ (mem x s)).

Axiom subset_remove : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (s:(set1
  a)), (subset (remove x s) s).

Parameter union: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom union_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (union s1 s2)) <-> ((mem x s1) \/ (mem x s2)).

Parameter inter: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom inter_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (inter s1 s2)) <-> ((mem x s1) /\ (mem x s2)).

Parameter diff: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> (set1 a) ->
  (set1 a).

Axiom diff_def1 : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)) (x:a), (mem x (diff s1 s2)) <-> ((mem x s1) /\ ~ (mem x s2)).

Axiom subset_diff : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1 a))
  (s2:(set1 a)), (subset (diff s1 s2) s1).

Parameter choose: forall {a:Type} {a_WT:WhyType a}, (set1 a) -> a.

Axiom choose_def : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a)),
  (~ (is_empty s)) -> (mem (choose s) s).

Parameter cardinal: forall {a:Type} {a_WT:WhyType a}, (set1 a) ->
  BuiltIn.int.

Axiom cardinal_nonneg : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1
  a)), (0%Z <= (cardinal s))%Z.

Axiom cardinal_empty : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a)),
  ((cardinal s) = 0%Z) <-> (is_empty s).

Axiom cardinal_add : forall {a:Type} {a_WT:WhyType a}, forall (x:a),
  forall (s:(set1 a)), (~ (mem x s)) -> ((cardinal (add x
  s)) = (1%Z + (cardinal s))%Z).

Axiom cardinal_remove : forall {a:Type} {a_WT:WhyType a}, forall (x:a),
  forall (s:(set1 a)), (mem x s) ->
  ((cardinal s) = (1%Z + (cardinal (remove x s)))%Z).

Axiom cardinal_subset : forall {a:Type} {a_WT:WhyType a}, forall (s1:(set1
  a)) (s2:(set1 a)), (subset s1 s2) -> ((cardinal s1) <= (cardinal s2))%Z.

Axiom cardinal1 : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a)),
  ((cardinal s) = 1%Z) -> forall (x:a), (mem x s) -> (x = (choose s)).

Parameter nth: forall {a:Type} {a_WT:WhyType a}, BuiltIn.int -> (set1 a) ->
  a.

Axiom nth_injective : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a))
  (i:BuiltIn.int) (j:BuiltIn.int), ((0%Z <= i)%Z /\ (i < (cardinal s))%Z) ->
  (((0%Z <= j)%Z /\ (j < (cardinal s))%Z) -> (((nth i s) = (nth j s)) ->
  (i = j))).

Axiom nth_surjective : forall {a:Type} {a_WT:WhyType a}, forall (s:(set1 a))
  (x:a), (mem x s) -> exists i:BuiltIn.int, ((0%Z <= i)%Z /\
  (i < (cardinal s))%Z) -> (x = (nth i s)).

Parameter vertex : Type.
Axiom vertex_WhyType : WhyType vertex.
Existing Instance vertex_WhyType.

Parameter vertices: (set1 vertex).

Parameter edges: (set1 (vertex* vertex)%type).

(* Why3 assumption *)
Definition edge(x:vertex) (y:vertex): Prop := (mem (x, y) edges).

Axiom edges_def : forall (x:vertex) (y:vertex), (mem (x, y) edges) -> ((mem x
  vertices) /\ (mem y vertices)).

Parameter s: vertex.

Axiom s_in_graph : (mem s vertices).

Axiom vertices_cardinal_pos : (0%Z < (cardinal vertices))%Z.

(* Why3 assumption *)
Fixpoint infix_plpl {a:Type} {a_WT:WhyType a}(l1:(list a)) (l2:(list
  a)) {struct l1}: (list a) :=
  match l1 with
  | Nil => l2
  | (Cons x1 r1) => (Cons x1 (infix_plpl r1 l2))
  end.

Axiom Append_assoc : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)) (l3:(list a)), ((infix_plpl l1 (infix_plpl l2
  l3)) = (infix_plpl (infix_plpl l1 l2) l3)).

Axiom Append_l_nil : forall {a:Type} {a_WT:WhyType a}, forall (l:(list a)),
  ((infix_plpl l (Nil :(list a))) = l).

Axiom Append_length : forall {a:Type} {a_WT:WhyType a}, forall (l1:(list a))
  (l2:(list a)), ((length (infix_plpl l1
  l2)) = ((length l1) + (length l2))%Z).

(* Why3 assumption *)
Fixpoint mem1 {a:Type} {a_WT:WhyType a}(x:a) (l:(list a)) {struct l}: Prop :=
  match l with
  | Nil => False
  | (Cons y r) => (x = y) \/ (mem1 x r)
  end.

Axiom mem_append : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l1:(list
  a)) (l2:(list a)), (mem1 x (infix_plpl l1 l2)) <-> ((mem1 x l1) \/ (mem1 x
  l2)).

Axiom mem_decomp : forall {a:Type} {a_WT:WhyType a}, forall (x:a) (l:(list
  a)), (mem1 x l) -> exists l1:(list a), exists l2:(list a),
  (l = (infix_plpl l1 (Cons x l2))).

(* Why3 assumption *)
Inductive path : vertex -> (list vertex) -> vertex -> Prop :=
  | Path_empty : forall (x:vertex), (path x (Nil :(list vertex)) x)
  | Path_cons : forall (x:vertex) (y:vertex) (z:vertex) (l:(list vertex)),
      (edge x y) -> ((path y l z) -> (path x (Cons x l) z)).

Axiom path_right_extension : forall (x:vertex) (y:vertex) (z:vertex) (l:(list
  vertex)), (path x l y) -> ((edge y z) -> (path x (infix_plpl l (Cons y
  (Nil :(list vertex)))) z)).

Axiom path_right_inversion : forall (x:vertex) (z:vertex) (l:(list vertex)),
  (path x l z) -> (((x = z) /\ (l = (Nil :(list vertex)))) \/
  exists y:vertex, exists l':(list vertex), (path x l' y) /\ ((edge y z) /\
  (l = (infix_plpl l' (Cons y (Nil :(list vertex))))))).

Axiom path_trans : forall (x:vertex) (y:vertex) (z:vertex) (l1:(list vertex))
  (l2:(list vertex)), (path x l1 y) -> ((path y l2 z) -> (path x
  (infix_plpl l1 l2) z)).

Axiom empty_path : forall (x:vertex) (y:vertex), (path x (Nil :(list vertex))
  y) -> (x = y).

Axiom path_decomposition : forall (x:vertex) (y:vertex) (z:vertex) (l1:(list
  vertex)) (l2:(list vertex)), (path x (infix_plpl l1 (Cons y l2)) z) ->
  ((path x l1 y) /\ (path y (Cons y l2) z)).

Parameter weight: vertex -> vertex -> BuiltIn.int.

(* Why3 assumption *)
Fixpoint path_weight(l:(list vertex)) (dst:vertex) {struct l}: BuiltIn.int :=
  match l with
  | Nil => 0%Z
  | (Cons x Nil) => (weight x dst)
  | (Cons x ((Cons y _) as r)) => ((weight x y) + (path_weight r dst))%Z
  end.

Axiom path_weight_right_extension : forall (x:vertex) (y:vertex) (l:(list
  vertex)), ((path_weight (infix_plpl l (Cons x (Nil :(list vertex))))
  y) = ((path_weight l x) + (weight x y))%Z).

Axiom path_weight_decomposition : forall (y:vertex) (z:vertex) (l1:(list
  vertex)) (l2:(list vertex)), ((path_weight (infix_plpl l1 (Cons y l2))
  z) = ((path_weight l1 y) + (path_weight (Cons y l2) z))%Z).

Axiom path_in_vertices : forall (v1:vertex) (v2:vertex) (l:(list vertex)),
  (mem v1 vertices) -> ((path v1 l v2) -> (mem v2 vertices)).

(* Why3 assumption *)
Definition pigeon_set(s1:(set1 vertex)): Prop := forall (l:(list vertex)),
  (forall (e:vertex), (mem1 e l) -> (mem e s1)) ->
  (((cardinal s1) < (length l))%Z -> exists e:vertex, exists l1:(list
  vertex), exists l2:(list vertex), exists l3:(list vertex),
  (l = (infix_plpl l1 (Cons e (infix_plpl l2 (Cons e l3)))))).

Axiom Induction : (forall (s1:(set1 vertex)), (is_empty s1) ->
  (pigeon_set s1)) -> ((forall (s1:(set1 vertex)), (pigeon_set s1) ->
  forall (t:vertex), (~ (mem t s1)) -> (pigeon_set (add t s1))) ->
  forall (s1:(set1 vertex)), (pigeon_set s1)).

Axiom corner : forall (s1:(set1 vertex)) (l:(list vertex)),
  ((length l) = (cardinal s1)) -> ((forall (e:vertex), (mem1 e l) -> (mem e
  s1)) -> ((exists e:vertex, (exists l1:(list vertex), (exists l2:(list
  vertex), (exists l3:(list vertex), (l = (infix_plpl l1 (Cons e
  (infix_plpl l2 (Cons e l3))))))))) \/ forall (e:vertex), (mem e s1) ->
  (mem1 e l))).

Axiom pigeon_0 : (pigeon_set (empty :(set1 vertex))).

Axiom pigeon_1 : forall (s1:(set1 vertex)), (pigeon_set s1) ->
  forall (t:vertex), (pigeon_set (add t s1)).

Axiom pigeon_2 : forall (s1:(set1 vertex)), (pigeon_set s1).

Axiom pigeonhole : forall (s1:(set1 vertex)) (l:(list vertex)),
  (forall (e:vertex), (mem1 e l) -> (mem e s1)) ->
  (((cardinal s1) < (length l))%Z -> exists e:vertex, exists l1:(list
  vertex), exists l2:(list vertex), exists l3:(list vertex),
  (l = (infix_plpl l1 (Cons e (infix_plpl l2 (Cons e l3)))))).

Axiom long_path_decomposition_pigeon1 : forall (l:(list vertex)) (v:vertex),
  (path s l v) -> ((~ (l = (Nil :(list vertex)))) -> forall (v1:vertex),
  (mem1 v1 (Cons v l)) -> (mem v1 vertices)).

Axiom long_path_decomposition_pigeon2 : forall (l:(list vertex)) (v:vertex),
  (forall (v1:vertex), (mem1 v1 (Cons v l)) -> (mem v1 vertices)) ->
  (((cardinal vertices) < (length (Cons v l)))%Z -> exists e:vertex,
  exists l1:(list vertex), exists l2:(list vertex), exists l3:(list vertex),
  ((Cons v l) = (infix_plpl l1 (Cons e (infix_plpl l2 (Cons e l3)))))).

Axiom long_path_decomposition_pigeon3 : forall (l:(list vertex)) (v:vertex),
  (exists e:vertex, (exists l1:(list vertex), (exists l2:(list vertex),
  (exists l3:(list vertex), ((Cons v l) = (infix_plpl l1 (Cons e
  (infix_plpl l2 (Cons e l3))))))))) -> ((exists l1:(list vertex),
  (exists l2:(list vertex), (l = (infix_plpl l1 (Cons v l2))))) \/
  exists n:vertex, exists l1:(list vertex), exists l2:(list vertex),
  exists l3:(list vertex), (l = (infix_plpl l1 (Cons n (infix_plpl l2 (Cons n
  l3)))))).

Axiom long_path_decomposition : forall (l:(list vertex)) (v:vertex), (path s
  l v) -> (((cardinal vertices) <= (length l))%Z -> ((exists l1:(list
  vertex), (exists l2:(list vertex), (l = (infix_plpl l1 (Cons v l2))))) \/
  exists n:vertex, exists l1:(list vertex), exists l2:(list vertex),
  exists l3:(list vertex), (l = (infix_plpl l1 (Cons n (infix_plpl l2 (Cons n
  l3))))))).

Axiom simple_path : forall (v:vertex) (l:(list vertex)), (path s l v) ->
  exists l':(list vertex), (path s l' v) /\
  ((length l') < (cardinal vertices))%Z.

(* Why3 assumption *)
Definition negative_cycle(v:vertex): Prop := (mem v vertices) /\
  ((exists l1:(list vertex), (path s l1 v)) /\ exists l2:(list vertex),
  (path v l2 v) /\ ((path_weight l2 v) < 0%Z)%Z).

Axiom key_lemma_1 : forall (v:vertex) (n:BuiltIn.int), (forall (l:(list
  vertex)), (path s l v) -> (((length l) < (cardinal vertices))%Z ->
  (n <= (path_weight l v))%Z)) -> ((exists l:(list vertex), (path s l v) /\
  ((path_weight l v) < n)%Z) -> exists u:vertex, (negative_cycle u)).

(* Why3 assumption *)
Inductive t  :=
  | Finite : BuiltIn.int -> t 
  | Infinite : t .
Axiom t_WhyType : WhyType t.
Existing Instance t_WhyType.

(* Why3 assumption *)
Definition add1(x:t) (y:t): t :=
  match x with
  | Infinite => Infinite
  | (Finite x1) =>
      match y with
      | Infinite => Infinite
      | (Finite y1) => (Finite (x1 + y1)%Z)
      end
  end.

(* Why3 assumption *)
Definition lt(x:t) (y:t): Prop :=
  match x with
  | Infinite => False
  | (Finite x1) =>
      match y with
      | Infinite => True
      | (Finite y1) => (x1 < y1)%Z
      end
  end.

(* Why3 assumption *)
Definition le(x:t) (y:t): Prop := (lt x y) \/ (x = y).

Axiom Refl : forall (x:t), (le x x).

Axiom Trans : forall (x:t) (y:t) (z:t), (le x y) -> ((le y z) -> (le x z)).

Axiom Antisymm : forall (x:t) (y:t), (le x y) -> ((le y x) -> (x = y)).

Axiom Total : forall (x:t) (y:t), (le x y) \/ (le y x).

(* Why3 assumption *)
Inductive ref (a:Type) {a_WT:WhyType a} :=
  | mk_ref : a -> ref a.
Axiom ref_WhyType : forall (a:Type) {a_WT:WhyType a}, WhyType (ref a).
Existing Instance ref_WhyType.
Implicit Arguments mk_ref [[a] [a_WT]].

(* Why3 assumption *)
Definition contents {a:Type} {a_WT:WhyType a}(v:(ref a)): a :=
  match v with
  | (mk_ref x) => x
  end.

(* Why3 assumption *)
Definition t1 (a:Type) {a_WT:WhyType a} := (ref (set1 a)).

(* Why3 assumption *)
Definition distmap  := (map vertex t).

(* Why3 assumption *)
Definition inv1(m:(map vertex t)) (pass:BuiltIn.int) (via:(set1 (vertex*
  vertex)%type)): Prop := forall (v:vertex), (mem v vertices) -> match (get m
  v) with
  | (Finite n) => (exists l:(list vertex), (path s l v) /\ ((path_weight l
      v) = n)) /\ ((forall (l:(list vertex)), (path s l v) ->
      (((length l) < pass)%Z -> (n <= (path_weight l v))%Z)) /\
      forall (u:vertex) (l:(list vertex)), (path s l u) ->
      (((length l) < pass)%Z -> ((mem (u, v) via) -> (n <= ((path_weight l
      u) + (weight u v))%Z)%Z)))
  | Infinite => (forall (l:(list vertex)), (path s l v) ->
      (pass <= (length l))%Z) /\ forall (u:vertex), (mem (u, v) via) ->
      forall (lu:(list vertex)), (path s lu u) -> (pass <= (length lu))%Z
  end.

(* Why3 assumption *)
Definition inv2(m:(map vertex t)) (via:(set1 (vertex* vertex)%type)): Prop :=
  forall (u:vertex) (v:vertex), (mem (u, v) via) -> (le (get m v)
  (add1 (get m u) (Finite (weight u v)))).

Require Import Why3.
Ltac ae := why3 "alt-ergo" timelimit 30.
Ltac Z3 := why3 "z3" timelimit 10.

Lemma length_nonneg: forall a {a_WT: WhyType a}, forall l: list a, (length l >= 0)%Z.
induction l; ae.
Qed.

(* Why3 goal *)
Theorem key_lemma_2 : forall (m:(map vertex t)), (inv1 m (cardinal vertices)
  (empty :(set1 (vertex* vertex)%type))) -> ((inv2 m edges) ->
  forall (v:vertex), ~ (negative_cycle v)).
intros m hinv1. unfold inv2. intros hinv2.
intros v (hv, ((l1, h1), (l2, (h2a, h2b)))).
assert
  (H: forall n: Z, (0 <= n)%Z ->
      forall vi: vertex, forall l: list vertex, (length l <= n)%Z ->
      path v l vi ->
      le (get m vi) (add1 (get m v) (Finite (path_weight l vi)))).
intros n hn; pattern n; apply natlike_ind. 3: auto.
intros vi l; destruct l.
simpl.
intros _ hpath. assert (vi = v) by ae. subst vi.
unfold le, add1.
right; ae.
intros h _. 
absurd ((length (Cons v0 l) <= 0)%Z); auto.
unfold length; fold @length.
generalize (length_nonneg _ l).
omega.
clear n hn. intros n hn IH.
intros vi l hl hpath.
destruct (path_right_inversion v vi l hpath) as [(eq1,eq2)|(y,(l',(y1,(y2,y3))))].
subst; simpl. ae.
assert (hl': (length l = length l' + 1)%Z).
generalize (Append_length l' (Cons y Nil)).
ae.
subst l. rewrite path_weight_right_extension.
rewrite hl' in hl. clear hl'.
assert (hl': (length l' <= n)%Z) by omega.
generalize (IH y l' hl' y1).
generalize (hinv2 y vi y2); clear hinv2.
unfold le, add1.
destruct (get m vi); destruct (get m v); destruct (get m y); ae.
assert (hl2a: (0 <= length l2)%Z).
  generalize (length_nonneg _ l2). omega.
assert (hl2b: (length l2 <= length l2)%Z) by omega.
generalize (H (length l2) hl2a v l2 hl2b h2a); clear H hl2a hl2b.
unfold le, add1; destruct (get m v) as [] _eqn.
ae.
absurd (get m v = Infinite); auto.
ae.
Qed.

