%{
%}

%start <Model_parser.model_element list> output

%token <string> SPACE
%token <string> ATOM
%token STORE
%token CONST
%token AS
%token <string> INT_STR
%token <string> MINUS_INT_STR
%token LPAREN RPAREN
%token EOF
%%

output:
| EOF { [] }
| possible_space text { [] }
| possible_space LPAREN pairs RPAREN { $3 }

pairs:
| possible_space { [] }
| possible_space LPAREN term SPACE value RPAREN pairs 
    { (Model_parser.create_model_element ~name:$3 ~value:$5 ())::$7 }
    
possible_space:
| { "" }
| SPACE { $1 }

term:
| text { $1 }
| LPAREN term_list RPAREN 
    { "(" ^ $2 ^ ")" }

term_list:
| possible_space { $1 }
| possible_space term term_list { $1 ^ $2 ^ $3 }

text:
| MINUS_INT_STR { $1 }
| INT_STR { $1 }
| text_without_int { $1 }

text_without_int:
| ATOM { $1 }
| STORE { "store" }
| CONST { "const"  }
| AS { "as" }

value:
| integer { $1 }
| other_val_str { Model_parser.Other $1 }
| array { Model_parser.Array $1 }

integer:
| INT_STR { Model_parser.Integer $1 }
| LPAREN possible_space MINUS_INT_STR possible_space RPAREN 
    { Model_parser.Integer $3 }

(* Everything that cannot be integer (positive and negative) and array. *)
other_val_str:
| text_without_int { $1 }
| LPAREN possible_space RPAREN { "(" ^ $2 ^ ")" }
| LPAREN possible_space paren_other_val_str RPAREN 
    { "(" ^ $3 ^ ")" }

(* Everything that cannot be negative integer and start of an array  *)
paren_other_val_str:
| other_than_neg_int_and_array_store term_list { $1 ^ $2 }
| LPAREN possible_space other_than_const_array possible_space RPAREN 
    { "(" ^ $3 ^ ")" }

other_than_neg_int_and_array_store:
| INT_STR { $1 }
| ATOM { $1 }
| CONST { "const"  }
| AS { "as" }

other_than_const_array:
| MINUS_INT_STR { $1 }
| INT_STR { $1 }
| CONST { "const"  }

(* Example:
   (store (store ((as const (Array Int Int)) 0) 1 2) 3 4) *)
array:
| LPAREN possible_space 
    LPAREN possible_space 
      AS SPACE CONST possible_space array_skipped_part possible_space 
    RPAREN possible_space 
    integer possible_space 
  RPAREN 
    { Model_parser.array_create_constant ~value:$13 }
| LPAREN possible_space 
    STORE possible_space array possible_space integer SPACE integer
    possible_space 
  RPAREN 
    { Model_parser.array_add_element ~array:$5 ~index:$7 ~value:$9 }

array_skipped_part:
| LPAREN term_list RPAREN {}
