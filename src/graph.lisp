;;;; -*- Lisp -*-
;;;;
;;;; Copyright (c) 2012, Georgia Tech Research Corporation
;;;; All rights reserved.
;;;;
;;;; Author(s): Neil T. Dantam <ntd@gatech.edu>
;;;; Georgia Tech Humanoid Robotics Lab
;;;; Under Direction of Prof. Mike Stilman
;;;;
;;;; This file is provided under the following "BSD-style" License:
;;;;
;;;;   Redistribution and use in source and binary forms, with or
;;;;   without modification, are permitted provided that the following
;;;;   conditions are met:
;;;;   * Redistributions of source code must retain the above
;;;;     copyright notice, this list of conditions and the following
;;;;     disclaimer.
;;;;   * Redistributions in binary form must reproduce the above
;;;;     copyright notice, this list of conditions and the following
;;;;     disclaimer in the documentation and/or other materials
;;;;     provided with the distribution.
;;;;
;;;;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
;;;;   CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
;;;;   INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
;;;;   MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;;;;   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
;;;;   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;;;   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
;;;;   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;;;;   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;;;;   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;;;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
;;;;   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
;;;;   EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(in-package :motion-grammar-kit)



(defun csv->graph (file &optional symbols)
  (let ((csv (read-csv file)))
    (let ((edges)
          (symbols (if symbols
                       symbols
                       (loop for i below (length csv) collect i))))
      (loop
         for i in symbols
         for row in csv
         do (loop
               for j in symbols
               for x in row
               do (cond
                    ((string= x "0"))
                    ((string= x "1") (push (list i j) edges))
                    (t (error "Uknown element: ~A" x)))))
      edges)))

(defun graph-dot (edges &key
                  output
                  node-font-size
                  directed
                  rankdir
                  )
  "Graphviz output of dfa.
fa: finite automaton
output: output file, type determined by suffix (png,pdf,eps)"
  (let* ((nodes (fold (lambda (set list)
                        (destructuring-bind (a b) list
                          (finite-set-add (finite-set-add set a) b)))
                      nil edges))
         (numbers (finite-set-enumerate nodes)))
    (output-dot output
                (lambda (s)
                  (if directed
                      (format s "~&digraph {~%")
                      (format s "~&graph {~%"))
                  (dot-options s
                               :rankdir rankdir
                               :node-font-size node-font-size)
                  ;; attributes
                  ;(format s "  overlap=\"false\";~&")
                  ;(format s "  overlap=\"ipsep\";~&")
                  ;(format s "  mode=\"ipsep\";~&")
                  ;(format s "  epsilon=\".00000001\";~&")
                  ;(format s "  splines=\"true\";~&")
                  ;(format s "  ratio=\"compress\";~&")
                  ;(format s "~&  edges[weight=1.8];~&")
                  ;(format s "~&  node[nodesep=0.1,ranksep=0.1];~&")
                  ;(format s "~&  node[width=1];~&")
                  ;(format s "~&  edge[width=2];~&")
                 ; (format s "  concentrate=\"true\";~&")
                  ;(format s "node=\"true\";")
                  ;; state labels
                  (format s "~:{~&  ~A[label=\"~A\",shape=\"oval\"];~}"
                          (loop for n in nodes
                             collect (list (funcall numbers n) n )))
                  ;; edges
                  (format s (if directed
                                "~:{~&  ~A -> ~A~&~}"
                                "~:{~&  ~A -- ~A~&~}")
                          (loop for (a b) in edges
                             collect (list (funcall numbers a) (funcall numbers b))))
                  (format s "~&}~%"))
                ;:program "neato"
                )))

(defun graph-vertices (edges)
  (fold (lambda (set e) (finite-set-add (finite-set-add set (first e))
                                   (second e)))
        (make-finite-set :compare #'gsymbol-compare)
        edges))

(defun graph-predecessors (edges)
  (let ((hash (make-hash-table :test #'equal)))
    (map nil (lambda (e)
               (destructuring-bind (v0 v1) e
                 (push v0 (gethash v1 hash))))
         edges)
    (lambda (v1) (gethash v1 hash))))

(defun graph-successors (edges)
  (let ((hash (make-hash-table :test #'equal)))
    (map nil (lambda (e)
               (destructuring-bind (v0 v1) e
                 (push v1 (gethash v0 hash))))
         edges)
    (lambda (v0) (gethash v0 hash))))


(defun random-graph (vertex-count &key
                     (edge-count (floor (/ (* vertex-count vertex-count)
                                           4)))
                     randomize-counts)
  (declare (type fixnum vertex-count edge-count))
  (multiple-value-bind (vertex-count edge-count)
      (if randomize-counts
          (values (random-whole vertex-count)
                  (random-whole edge-count))
          (values vertex-count edge-count))
    (let ((edges))
      (dotimes (i edge-count)
        (setq edges (finite-set-add edges (list (random vertex-count)
                                                (random vertex-count)))))
      edges)))
