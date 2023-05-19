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

        ;; return n;       // color is determined by number of iterations
        local.get $n
    )

    (export "mandelbrot" (func $mandelbrot))
)