(module

    (;
    ;; calculate the mandelbrot value for the given
    ;; coordinate on the mandelbrot plane 
    ;;
    ;; @param mx float horizontal coord -1.0 <= mx <= 1.0
    ;; @param mx float vertical coord -2.5 <= my <= 1.0
    ;; @param max int maximum iterations
    ;; @return int number of iterations of algorithm (0 <= n <= max)
    ;)
    (func $mandelbrot (param $mx f64) (param $my f64) (param $max i32) (result i32)

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

        ;; return n;       // color is determined by number of iterations
        get_local $n
    )

    (export "mandelbrot" (func $mandelbrot))
)