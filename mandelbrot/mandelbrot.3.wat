(module

    (;
    ;; set a dot on a bitmap given coordinates, color and bitmap context
    ;;
    ;; @param x i32 horizontal coordinate
    ;; @param y i32 vertical coordinate
    ;; @param color i32 palette index to choose color
    ;)
    (func $dot (import "imports" "dot") (param $x i32) (param $y i32) (param $color i32))

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

        (local $x i32)
        (local $y i32)
        (local $mandely f64)
        (local $pixely i32)

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
        ;;     }
        ;; }
        ;;

        ;; for(let y = 0; y < pHeight; y += 1) {
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
                        call $mandelbrotPoint

                        ;; x += 1
                        local.get $x
                        i32.const 1
                        i32.add
                        local.set $x

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
    ;)
    (func $mandelbrotPoint (param $max i32) (param $mx f64) (param $my f64) (param $px i32) (param $py i32)

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

        ;; 
        ;; set the dot
        ;;
        local.get $px
        local.get $py
        local.get $n
        call $dot
    )

    (export "mandelbrot" (func $mandelbrotRect))
)