;; Custom highlights for Go
;; Place this in: ~/.config/nvim/after/queries/go/highlights.scm

;; Highlight struct field names
(field_declaration
  name: (field_identifier) @struct.field)

;; Highlight function receivers in method declarations
(parameter_declaration
  name: (identifier) @function.receiver
  type: (pointer_type (type_identifier))) ;; Pointer receivers

(parameter_declaration
  name: (identifier) @function.receiver
  type: (type_identifier)) ;; Value receivers

;; Highlight type parameters (Go 1.18+ Generics)
; (type_parameter
;   name: (type_identifier) @type.parameter)

;; Better highlight for method calls
(selector_expression
  field: (field_identifier) @method.call)

;; Improved context highlighting for function parameters
(function_declaration
  name: (identifier) @function.name
  parameters: (parameter_list
    (parameter_declaration
      name: (identifier) @function.parameter)))

;; Interface method names (fixed issue with invalid method_spec)
; (interface_type
;   (field
;     name: (field_identifier) @interface.method)) ;; Interface methods

;; Highlight builtin functions
((identifier) @function.builtin
  (#any-of? @function.builtin "append" "cap" "close" "complex" "copy" "delete"
                             "imag" "len" "make" "new" "panic" "print" "println"
                             "real" "recover"))

;; Constants in ALL_CAPS (common Go convention)
((identifier) @constant
  (#match? @constant "^[A-Z][A-Z0-9_]+$"))

;; Error variables (by Go convention, starting with "Err")
((identifier) @variable.error
  (#match? @variable.error "^Err[A-Z]\\w*"))

;; Type declaration highlighting
(type_spec
  name: (type_identifier) @type.definition)

;; Enhance composite literal highlighting
(composite_literal
  type: (_) @composite.type)

;; Go build tags
(comment) @preproc.build
  (#match? @preproc.build "^//go:build")

;; Go generate directives
(comment) @preproc.generate
  (#match? @preproc.generate "^//go:generate")

