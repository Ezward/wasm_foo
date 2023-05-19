(module

    ;;
    ;; memory is imported from environments; this is sized so that
    ;; it can hold the necessary RBGa bitmap.
    ;;
    (memory (import "imports" "mem") 1)

    (;
    ;; calculate the mandelbrot value for the
    ;; coordinates given bounding rect on the mandelbrot plane 
    ;;
    ;; @param max i32 maximum iterations
    ;; @param mx f64 horizontal coord on mandelbrot plane -1.0 <= mx <= 1.0
    ;; @param my f64 vertical coord on mandelbrot plane -2.5 <= my <= 1.0
    ;; @param mWidth f64 mandelbrot width (mWidth < 2.0 AND mx + mWidth <= 1.0)
    ;; @param mHeight f64 mandelbrot height (mHeight <= 3.5 AND my + mHeight <= 1.0)
    ;; @param px i32 horizontal pixel coordinate
    ;; @param py i32 vertical pixel coordinate
    ;; @param pWidth i32 width in pixels of drawing area
    ;; @param pHeight i32 height in pixels of drawing area
    ;)
    (func $mandelbrotRect 
                (param $max i32) 
                (param $mx f64) (param $my f64) (param $mWidth f64) (param $mHeight f64) 
                (param $px i32) (param $py i32) (param $pWidth i32) (param $pHeight i32)

        (local $n i32)
        (local $x i32)
        (local $y i32)
        (local $mandely f64)
        (local $pixely i32)
        (local $pixelOffset i32)

        ;;
        ;; for(let y = 0; y < pHeight; y += 1) {
        ;;     //
        ;;     // scale pixel into mandelbrot vertical range -1 to 1
        ;;     //
        ;;     const mandely = my + (y * mHeight / pHeight);
        ;;     const pixely = py + y;
        ;;     for(let x = 0; x < pWidth; x += 1) {
        ;;         //
        ;;         // scale pixel coordinate into mandelbrot horizontal scale -2.5 to 1
        ;;         //
        ;;         const mandelx = mx + (x * mWidth / pWidth);
        ;;         const pixelx = px + x;
        ;;         const n = mandelbrotFunc(mandelx, mandely, max, pixelx, pixely);
        ;;         if(n >= max) {
        ;;             // black;
        ;;         } else {
        ;;             // white;
        ;;         }
        ;;     }
        ;; }
        ;;

        ;; for(let y = 0; y < pHeight; y += 1) 
        i32.const 0
        local.set $y
        (loop $for_y
            local.get $y
            local.get $pHeight
            i32.lt_s
            (if (then
                ;;     //
                ;;     // scale pixel into mandelbrot vertical range -1 to 1
                ;;     //
                ;;     const mandely = my + (y * mHeight / pHeight);
                local.get $y
                f64.convert_i32_s   ;; convert y to float
                local.get $mHeight
                f64.mul
                local.get $pHeight
                f64.convert_i32_s   ;; convert pixel height to float
                f64.div
                local.get $my
                f64.add
                local.set $mandely

                ;;     const pixely = py + y;
                local.get $py
                local.get $y
                i32.add
                local.set $pixely

                ;;     for(let x = 0; x < pWidth; x += 1) {
                i32.const 0
                local.set $x
                (loop $for_x
                    local.get $x
                    local.get $pWidth
                    i32.lt_s
                    (if (then
                        local.get $max  ;; leave on stack as first arg to call; $max

                        ;;         //
                        ;;         // scale pixel coordinate into mandelbrot horizontal scale -2.5 to 1
                        ;;         //
                        ;;         const mandelx = mx + (x * mWidth / pWidth);
                        local.get $x
                        f64.convert_i32_s     ;; convert pixel x to float
                        local.get $mWidth
                        f64.mul
                        local.get $pWidth
                        f64.convert_i32_s     ;; convert pixel width to float
                        f64.div
                        local.get $mx
                        f64.add
                        ;; leave on stack as second arg to call; $mandelx

                        local.get $mandely  ;; this will be third arg to call; mandely

                        ;;         const pixelx = px + x;
                        local.get $px
                        local.get $x
                        i32.add
                        ;; leave on stack as fourth arg to call; pixelx

                        local.get $pixely   ;; fifth arg to call; pixely

                        ;;         const n = mandelbrotPoint(max, mandelx, mandely, pixelx, pixely);
                        call $mandelbrotPoint   ;; this pushes n on the value stack
                        local.set $n

                        ;;         if(n < max) {
                        ;;             // white;
                        ;;         } else {
                        ;;             // black;
                        ;;         }
                        local.get $n
                        local.get $max
                        i32.lt_s
                        (if 
                            (then
                                ;; (i32.store (local.get $pixelOffset) (i32.const 0xFFFFFFFF))
                                (i32.store (local.get $pixelOffset) (call $mandelbrotColor (local.get $n)))
                            )
                            (else
                                (i32.store (local.get $pixelOffset) (i32.const 0xFF000000))
                            )
                        )

                        ;; pixelOffset += 4
                        (local.set $pixelOffset (i32.add (local.get $pixelOffset) (i32.const 4)))

                        ;; x += 1
                        (local.set $x (i32.add (local.get $x) (i32.const 1)))

                        br $for_x
                    ))
                )

                ;; y += 1
                local.get $y
                i32.const 1
                i32.add
                local.set $y

                br $for_y
            ))
        )
    )

    (;
    ;; calculate the mandelbrot value for the given
    ;; coordinate on the mandelbrot plane 
    ;;
    ;; @param max i32 maximum iterations
    ;; @param mx f64 horizontal coord -1.0 <= mx <= 1.0
    ;; @param my f64 vertical coord -2.5 <= my <= 1.0
    ;; @param px i32 horizontal pixel coordinate
    ;; @param py i32 vertical pixel coordinate
    ;; @return i32 number of iterations
    ;)
    (func $mandelbrotPoint (param $max i32) (param $mx f64) (param $my f64) (param $px i32) (param $py i32) (result i32)

        ;; 
        ;; calculate to convergence or max 1000 iterations
        ;; 
        ;; let x = 0.0;
        ;; let y = 0.0;
        ;; let n = 0;   // number of iterations
        ;; while((n < max) && (x*x + y*y < 4)) {
        ;;     const newx = x*x - y*y + mx;
        ;;     y = 2 * x * y + my;
        ;;     x = newx;
        ;;     n += 1;
        ;; }
        ;; return n;       // color is determined by number of iterations

        ;; let x = 0.0;
        ;; let y = 0.0;
        ;; let n = 0;
        (local $x f64)
        (local $y f64)
        (local $n i32)

        ;; while((n < max) && (x*x + y*y < 4)) {
        (loop $while
            local.get $n
            local.get $max
            i32.lt_s
            (if (then
                local.get $x
                local.get $x
                f64.mul
                local.get $y
                local.get $y
                f64.mul
                f64.add
                f64.const 4.0
                f64.lt
                (if (then
                    ;;     const newx = x*x - y*y + mx;
                    local.get $x
                    local.get $x
                    f64.mul
                    local.get $y
                    local.get $y
                    f64.mul
                    f64.sub
                    local.get $mx
                    f64.add         ;; newx will stay on stack

                    ;;     y = 2 * x * y + my;
                    local.get $x
                    local.get $y
                    f64.mul
                    f64.const 2.0
                    f64.mul
                    local.get $my
                    f64.add
                    local.set $y

                    ;;     x = newx;
                    local.set $x    ;; get from top of stack

                    ;;     n += 1;
                    local.get $n
                    i32.const 1
                    i32.add
                    local.set $n

                    br $while   ;; back to top of loop
                ))
            ))
        )

        ;; return number of iterations
        local.get $n
    )

    (;
    ;; calculate the color value 0..255 given mandelbrot iteration and offset/scale modifiers
    ;;
    ;; @param n i32 is the mandelbrot escape value (iterations) for the pixel
    ;; @param offset i32 is arbitrary offset to apply to scaled n
    ;; @param scale i32 is arbitrary scale to apply to n
    ;; @return i32 is color value 0..255
    ;)
    (func $color (param $n i32) (param $offset i32) (param $scale i32) (result i32)
        ;; 
        ;; function color(n, offset, scale) {
        ;;     n = ((n * scale) + offset) % 1024;
        ;;     if (n < 256) {
        ;;         return n;
        ;;     } else if (n < 512) {
        ;;         return 255 - (n - 255);
        ;;     } else {
        ;;         return 0;
        ;;     }
        ;; }
        ;; 

        ;; n = ((n * scale) + offset) % 1024;
        (local.set 
            $n 
            (i32.rem_u 
                (i32.add 
                    (i32.mul 
                        (local.get $n) 
                        (local.get $scale)
                    )
                    (local.get $offset) 
                )
                (i32.const 1024) 
            )
        )

        ;; if (n < 256) {
        local.get $n
        i32.const 256
        i32.lt_u
        (if (result i32) 
            (then
                ;;     return n;
                local.get $n
            )
            (else    ;; } else if (n < 512) {
                local.get $n
                i32.const 512
                i32.lt_u
                (if (result i32)
                    (then
                        ;;     return 255 - (n - 256);
                        (i32.sub (i32.const 255) (i32.sub (local.get $n) (i32.const 256)))
                    )
                    (else
                        ;;     return 0;
                        i32.const 0
                    )
                )
            )
        )   
    )


    (;
    ;; calculate the rbg color for a pixel given it's mandelbrot number.
    ;;
    ;; @param n i32 which is the pixel's mandelbrot escape number (iteration count)
    ;; @return i32 whihc is the rgba value of the pixel.
    ;)
    (func $mandelbrotColor (param $n i32) (result i32)
        ;;
        ;; return red | (((((green << 8) | blue) << 8) | alpha) << 8)
        ;;
        (i32.or
            (call $color (local.get $n) (i32.const 160) (i32.const 4))                  ;; red
            (i32.shl
                (i32.or 
                    (call $color (local.get $n) (i32.const 0) (i32.const 4))            ;; green
                    (i32.shl 
                        (i32.or 
                            (call $color (local.get $n) (i32.const 352) (i32.const 4))  ;; blue
                            (i32.shl
                                (i32.const 0xFF)                                        ;; alpha
                                (i32.const 8)
                            )
                        )
                        (i32.const 8)
                    )
                )
                (i32.const 8)
            )
        )
    )
    

    (export "mandelbrot" (func $mandelbrotRect))
)