;;;; -*- Lisp -*-
;;;;
;;;; Copyright (c) 2011, Georgia Tech Research Corporation
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


;;; DFA
;;;  -(Q, E, d, q0, F),
;;;    - Q: states
;;;    - E: alphabet
;;;    - d: Q*E :-> Q
;;;    - q0: start state
;;;    - F: accept state


(defun dfa-dot (d &key output final start)
  "Graphviz output of dfa.
d: list of transitions '((state-0 token state-1)...)
final: list of accept states
start: start state
output: output file, type determined by suffix (png,pdf,eps)"
  (labels ((helper (s)
             (format s "~&digraph {~%")
             (when start
               (format s "~&  start[shape=none];")
               (format s "~&  start -> ~A;" start))
             (format s "~{~&  ~A [ shape=doublecircle ];~}" final)
             (map 'nil (lambda (x)
                         (format s "~&  ~A -> ~A [label=\"~A\"];~%"
                                 (first x) (third x) (second x)))
                  d)
             (format s "~&}~%"))
           (dot (ext)
             (let ((p (sb-ext:run-program "dot" (list (concatenate 'string "-T" ext))
                                          :wait nil :search t :input :stream :output output
                                          :if-output-exists :supersede)))
               (helper (sb-ext:process-input p))
               (close (sb-ext:process-input p))
               (sb-ext:process-wait p))))
    (cond
      ((and (stringp output) (ppcre:scan "\.png$" output))
       (dot "png"))
      ((and (stringp output) (ppcre:scan "\.ps$" output))
       (dot "ps"))
      ((and (stringp output) (ppcre:scan "\.eps$" output))
       (dot "eps"))
      ((and (stringp output) (ppcre:scan "\.pdf$" output))
       (dot "pdf"))
      ((streamp output)
       (helper output))
      (t
       (with-output-to-string (s)
         (helper s))))))

