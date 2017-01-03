(define (pal-to-ntsc pattern)
  (let* ((filelist (cadr (file-glob pattern 1))))
    (while (not (null? filelist))
           (let* ((filename (car filelist))
                  (image (car (gimp-file-load RUN-NONINTERACTIVE
                                              filename filename)))
                  (drawable (car (gimp-image-get-active-layer image))))
             (gimp-curves-spline drawable HISTOGRAM-VALUE 4 #(32 0 255 223))
             (gimp-file-save RUN-NONINTERACTIVE
                             image drawable filename filename)
             (gimp-image-delete image))
           (set! filelist (cdr filelist)))))
