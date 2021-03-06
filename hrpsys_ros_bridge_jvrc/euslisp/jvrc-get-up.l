#!/usr/bin/env roseus

(require "package://hrpsys_ros_bridge_jvrc/euslisp/jaxon_jvrc-interface.l")
(load "package://drc_task_common/euslisp/robot-util.l")
(when (not (boundp '*jaxon_jvrc*))
  (jaxon_jvrc-init)
  (setq *robot* *jaxon_jvrc*)
  )

(defun send-pose (&key (real nil) (base-time 5000))
  (when real
    (send *ri* :angle-vector (send *robot* :angle-vector) base-time)
    (send *ri* :wait-interpolation)
    ))

(defun prepare-for-getting-up (&key (face-down nil) (real nil) (base-time 5000))
  (send *ri* :start-grasp)
  (when face-down
    (send *robot* :init-pose)
    (send-pose :real real :base-time base-time)
    (send *robot* :rarm-elbow-p :joint-angle 60)
    (send *robot* :larm-elbow-p :joint-angle 60)
    (send-pose :real real :base-time base-time)
    (send *robot* :rarm :shoulder-r :joint-angle -180)
    (send *robot* :larm :shoulder-r :joint-angle 180)
    (send-pose :real real :base-time base-time)
    )
  (send *robot* :init-pose)
  (send *robot* :rarm-shoulder-r :joint-angle -180)
  (send *robot* :larm-shoulder-r :joint-angle 180)
  (send-pose :real real :base-time base-time)
  (send *robot* :rarm-shoulder-y :joint-angle -180)
  (send *robot* :larm-shoulder-y :joint-angle 180)
  (send-pose :real real :base-time base-time)
  )

;;うつ伏せから起き上がり
(defun get-up-face-down (&key (face-down nil) (real nil) (base-time 5000))
  (prepare-for-getting-up :face-down face-down :real real :base-time base-time)
  (send *robot* :rleg-ankle-p :joint-angle -70)
  (send *robot* :lleg-ankle-p :joint-angle -70)
  (send-pose :real real :base-time base-time)
  (send *robot* :larm-shoulder-r :joint-angle 170)
  (send *robot* :rarm-shoulder-r :joint-angle -170)
  (send-pose :real real :base-time base-time)
  (send *robot* :rarm-shoulder-p :joint-angle 50)
  (send *robot* :larm-shoulder-p :joint-angle 50)
  (send-pose :real real :base-time base-time)
  (send *robot* :rleg-ankle-p :joint-angle -40)
  (send *robot* :lleg-ankle-p :joint-angle -40)
  (send *robot* :rleg-crotch-p :joint-angle -45)
  (send *robot* :lleg-crotch-p :joint-angle -45)
  (send *robot* :larm-shoulder-p :joint-angle 70)
  (send *robot* :rarm-shoulder-p :joint-angle 70)
  (send-pose :real real :base-time base-time)
  (send *robot* :lleg-ankle-p :joint-angle -70)
  (send *robot* :rleg-ankle-p :joint-angle -70)
  (send *robot* :lleg-crotch-p :joint-angle -75)
  (send *robot* :rleg-crotch-p :joint-angle -75)
  (send *robot* :rleg-knee-p :joint-angle 75)
  (send *robot* :lleg-knee-p :joint-angle 75)
  (send-pose :real real :base-time base-time)
  (send *robot* :lleg-knee-p :joint-angle 110)
  (send *robot* :rleg-knee-p :joint-angle 110)
  (send *robot* :rleg-crotch-p :joint-angle -110)
  (send *robot* :lleg-crotch-p :joint-angle -110)
  (send-pose :real real :base-time base-time)
  (send *robot* :rarm-shoulder-p :joint-angle 100)
  (send *robot* :larm-shoulder-p :joint-angle 100)
  (send *robot* :rleg-knee-p :joint-angle 150)
  (send *robot* :lleg-knee-p :joint-angle 150)
  (send-pose :real real :base-time base-time)
  (send *robot* :lleg-crotch-p :joint-angle -110)
  (send *robot* :rleg-crotch-p :joint-angle -110)
  (send *robot* :larm-shoulder-p :joint-angle 130)
  (send *robot* :rarm-shoulder-p :joint-angle 130)
  (send-pose :real real :base-time (* 5 base-time))
  (send *robot* :lleg-crotch-p :joint-angle -100)
  (send *robot* :rleg-crotch-p :joint-angle -100)
  (send *robot* :rarm-shoulder-p :joint-angle 180)
  (send *robot* :larm-shoulder-p :joint-angle 180)
  (send-pose :real real :base-time (* 5 base-time))
  (warn "start auto-balancer!!!~%")
  (send *ri* :start-auto-balancer)
  (send *robot* :reset-pose)
  (send *robot* :rarm-elbow-p :joint-angle -180)
  (send *robot* :larm-elbow-p :joint-angle -180)
  (send-pose :real real :base-time (* 5 base-time))
  (warn "start stabilizer!!!~%")
  (send *ri* :start-st)
  (send *robot* :reset-pose)
  (send-pose :real real :base-time (* 2 base-time))
  )

(defun get-up (&key (real t) (base-time 1000))
  (send *ri* :stop-st)
  (send *ri* :stop-auto-balancer)
  (send *ri* :stop-impedance :larm)
  (send *ri* :stop-impedance :rarm)
  (send *ri* :start-grasp)
  (if (y-or-n-p "aomuke?~%")
      (okiagari) ;;
    (get-up-face-down :real real :face-down t :base-time base-time)
    ))


(defun apply-mirror
  ()
  (let ((rarm-angle (send *robot* :rarm :angle-vector))
        (rleg-angle (send *robot* :rleg :angle-vector))
        )
    (get-mirror-angle-vector)
    (send *robot* :rarm :angle-vector rarm-angle)
    (send *robot* :rleg :angle-vector rleg-angle)
    )
  )


(defun okiagari
  ()
  (send *ri* :stop-st)
  (send *ri* :stop-auto-balancer)
  (send *ri* :stop-impedance :rarm)
  (send *ri* :stop-impedance :larm)
  (send *ri* :start-grasp)
  (send *robot* :init-pose)
  (send *robot* :rleg :crotch-r :joint-angle -40)
  (send *robot* :lleg :crotch-r :joint-angle 40)
  (send *ri* :angle-vector (send *robot* :angle-vector) 200)
  (send *robot* :reset-pose)
  (send *ri* :wait-interpolation)
  (send *robot* :rarm :move-end-pos (float-vector -200 0 0))
  (send *robot* :rarm :move-end-pos (float-vector -200 0 0))
  ;(mirror-m2r)
  (send *robot* :rleg :move-end-pos (float-vector 0 0 300))
  (send *robot* :rleg :move-end-rot 50 :y)
  (send *robot* :rleg :crotch-p :joint-angle -90)
  ;(mirror-m2r)
  (send *robot* :rleg :crotch-p :joint-angle -50)
  (send *robot* :rleg :move-end-pos (float-vector -300 0 0))
  (mirror-m2r :time 4000); needed
  (send *robot* :torso :waist-p :joint-angle 35)
  ;(m2r)
  (send *robot* :rarm :move-end-rot 70 :y)
  ;(mirror-m2r)
  (send *robot* :rarm :move-end-pos (float-vector 300 0 -300))
  (mirror-m2r)
  (send *robot* :rleg :move-end-rot 20 :y)
  ;(mirror-m2r)
  ;(return)
  ;(send *robot* :rarm :inverse-kinematics (send (send (send *robot* :rarm :end-coords) :copy-worldcoords) :translate (float-vector 200 0 0)) :rotation-axis nil)
  (send *robot* :rleg :ankle-p :joint-angle -40)
  ;(mirror-m2r)
  (send *robot* :rarm :move-end-pos (float-vector 0 100 0))
  ;(mirror-m2r)
  ;(return)
  (send *ri* :stop-grasp)
  (send *robot* :rleg :knee-p :joint-angle 158)
  (send *robot* :rleg :crotch-p :joint-angle -70)
  (send *robot* :rarm :move-end-rot 20 :z)
  (send *robot* :rarm :move-end-pos (float-vector 0 0 150))
  (send *robot* :rarm :move-end-rot 20 :y)
  (mirror-m2r)
  ;; (send *robot* :rleg :knee-p :joint-angle 150)
  ;; (send *robot* :rleg :crotch-p :joint-angle -50)
  ;; (send *robot* :rarm :shoulder-p :joint-angle 20)
  ;; (apply-mirror)
  ;; (send *ri* :angle-vector (send *robot* :angle-vector))
  ;; (send *ri* :wait-interpolation)
  ;(send *robot* :angle-vector #f(0.000206 -4.879037e-05 -55.0 150.0 -76.0 0.000223 -0.000206 4.879037e-05 -55.0 150.0 -76.0 -0.000223 0.0 35.0 0.0 0.0 0.0 10.1592 20.0 -15.8252 39.408 -21.278 -51.6488 -4.60999 5.91639 -10.1592 20.0 15.8252 -39.408 -21.278 51.6488 4.60999 5.91639)) ;; almost fin
  (send *robot* :angle-vector
        #f(0.000206 -4.879037e-05 -59.0 150.0 -70.0 0.000223 -0.000206 4.879037e-05 -59.0 150.0 -70.0 -0.000223 0.0 35.0 0.0 0.0 35.0 -3.43392 7.95497 -15.8251 60.2331 -9.21772 -57.613 3.43684 5.3938 3.43392 7.95497 15.8251 -60.2331 -9.21772 57.613 -3.43684 5.3938))
  ;(send *robot* :rleg :crotch-p :joint-angle -70)
  ;(send *robot* :rarm :wrist-p :joint-angle -20)
  (mirror-m2r)
  ;; (send *robot* :move-centroid-on-foot  :both (list :rleg :lleg :rarm :larm))
  ;; (mirror-m2r)
  ;(return)
  ;; (send *robot* :angle-vector #f(-0.057911 0.066627 -43.4131 145.631 -79.3683 -0.079079 -0.075584 0.064285 -43.1086 145.662 -79.3056 -0.075552 0.012312 34.9673 -0.001709 -0.000174 0.015047 -3.42247 7.92237 -15.8251 60.2319 -9.22878 -57.6131 3.43799 5.39088 3.41695 7.9251 15.83 -60.2314 -9.22422 57.613 -3.44573 5.39201))
  (mirror-m2r)
  (send *ri* :start-auto-balancer)
  (unix::sleep 3)
  ;(send *robot* :legs :move-end-pos (float-vector 0 0 -30))
  ;(m2r)
  ;(send *ri* :start-grasp)
  (send *robot* :reset-pose)
  (send *robot* :legs :move-end-pos (float-vector 0 0 150))
  (send *ri* :angle-vector (send *robot* :angle-vector))
  (send *ri* :wait-interpolation)
  (send *ri* :start-st)
  )
(defun m2r ()
  (send *ri* :angle-vector (send *robot* :angle-vector))
  (send *ri* :wait-interpolation)
  )

(defun mirror-m2r (&key (time 5000))
  (apply-mirror)
  (send *ri* :angle-vector (send *robot* :angle-vector) time)
  (send *ri* :wait-interpolation)
  )
