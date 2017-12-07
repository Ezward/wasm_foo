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
        set_local $y
        loop $for_y
            get_local $y
            get_local $pHeight
            i32.lt_s
            if
                ;;     //
                ;;     // scale pixel into mandelbrot vertical range -1 to 1
                ;;     //
                ;;     const mandely = my + (y * mHeight / pHeight);
                get_local $y
                f64.convert_s/i32   ;; convert y to float
                get_local $mHeight
                f64.mul
                get_local $pHeight
                f64.convert_s/i32   ;; convert pixel height to float
                f64.div
                get_local $my
                f64.add
                set_local $mandely

                ;;     const pixely = py + y;
                get_local $py
                get_local $y
                i32.add
                set_local $pixely

                ;;     for(let x = 0; x < pWidth; x += 1) {
                i32.const 0
                set_local $x
                loop $for_x
                    get_local $x
                    get_local $pWidth
                    i32.lt_s
                    if
                        get_local $max  ;; leave on stack as first arg to call; $max

                        ;;         //
                        ;;         // scale pixel coordinate into mandelbrot horizontal scale -2.5 to 1
                        ;;         //
                        ;;         const mandelx = mx + (x * mWidth / pWidth);
                        get_local $x
                        f64.convert_s/i32     ;; convert pixel x to float
                        get_local $mWidth
                        f64.mul
                        get_local $pWidth
                        f64.convert_s/i32     ;; convert pixel width to float
                        f64.div
                        get_local $mx
                        f64.add
                        ;; leave on stack as second arg to call; $mandelx

                        get_local $mandely  ;; this will be third arg to call; mandely

                        ;;         const pixelx = px + x;
                        get_local $px
                        get_local $x
                        i32.add
                        ;; leave on stack as fourth arg to call; pixelx

                        get_local $pixely   ;; fifth arg to call; pixely

                        ;;         const n = mandelbrotPoint(max, mandelx, mandely, pixelx, pixely);
                        call $mandelbrotPoint

                        ;; x += 1
                        get_local $x
                        i32.const 1
                        i32.add
                        set_local $x

                        br $for_x
                    end
                end

                ;; y += 1
                get_local $y
                i32.const 1
                i32.add
                set_local $y

                br $for_y
            end
        end
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
        loop $while
            get_local $n
            get_local $max
            i32.lt_s
            if
                get_local $x
                get_local $x
                f64.mul
                get_local $y
                get_local $y
                f64.mul
                f64.add
                f64.const 4.0
                f64.lt
                if
                    ;;     const newx = x*x - y*y + mx;
                    get_local $x
                    get_local $x
                    f64.mul
                    get_local $y
                    get_local $y
                    f64.mul
                    f64.sub
                    get_local $mx
                    f64.add         ;; newx will stay on stack

                    ;;     y = 2 * x * y + my;
                    get_local $x
                    get_local $y
                    f64.mul
                    f64.const 2.0
                    f64.mul
                    get_local $my
                    f64.add
                    set_local $y

                    ;;     x = newx;
                    set_local $x    ;; get from top of stack

                    ;;     n += 1;
                    get_local $n
                    i32.const 1
                    i32.add
                    set_local $n

                    br $while   ;; back to top of loop
                end
            end
        end

        ;; 
        ;; set the dot
        ;;
        get_local $px
        get_local $py
        get_local $n
        call $dot
    )

    (export "mandelbrot" (func $mandelbrotRect))
)