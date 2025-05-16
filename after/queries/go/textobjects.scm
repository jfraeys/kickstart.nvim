;; extends
; Custom text objects for Go
; Place this in: ~/.config/nvim/after/queries/go/textobjects.scm

; Function text objects
(function_declaration) @function.outer

(function_declaration
  body: (block) @function.inner)

; Method text objects
(method_declaration) @function.outer

(method_declaration
  body: (block) @function.inner)

; Function literal (closure) text objects
(func_literal) @function.outer

(func_literal
  body: (block) @function.inner)

; Class text objects (structs, interfaces)
(type_declaration) @class.outer

; (struct_type
;   "{" "}" @class.inner)

(interface_type
  "{" "}" @class.inner)

; Parameter text objects
(parameter_list) @parameter.outer

(parameter_list
  "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "parameter.inner" @_start @_end))

; Argument text objects
(argument_list) @parameter.outer

(argument_list
  "(" . (_) @_start (_)? @_end . ")"
  (#make-range! "parameter.inner" @_start @_end))

; Comment text objects
(comment) @comment.outer

; Block text objects
(block) @block.outer

(block
  "{" . (_) @_start (_)? @_end . "}"
  (#make-range! "block.inner" @_start @_end))

; Statement text objects
; (simple_statement) @statement.outer
(expression_statement) @statement.outer
(if_statement) @statement.outer
(for_statement) @statement.outer
; (switch_statement) @statement.outer
(select_statement) @statement.outer
(return_statement) @statement.outer
(defer_statement) @statement.outer
(go_statement) @statement.outer

; Conditional text objects
(if_statement) @conditional.outer

; (if_statement
;   body: (block) @conditional.inner)

; Loop text objects
(for_statement) @loop.outer

(for_statement
  body: (block) @loop.inner)

; Call text objects
(call_expression) @call.outer

(call_expression
  arguments: (argument_list) @call.inner)

; Assignment text objects
(assignment_statement) @assignment.outer
(short_var_declaration) @assignment.outer

; Import text objects
(import_declaration) @import.outer

(import_spec_list) @import.inner

; Package text objects
(package_clause) @package.outer

; Attribute/field text objects
(field_declaration) @attribute.outer

