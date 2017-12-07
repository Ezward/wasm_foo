(module
    (; 
    ;; Calculate factorial of a given integer.
    ;; factorial(5) == 1 * 2 * 3 * 4 * 5 
    ;;
    ;; @param $p1 value to factorial
    ;; @return 1 if $p1 <= 0 else 1*2*..$p1
    ;)
    (func $factorial (param $p1 i32) (result i32) (local $factorial i32)
        ;; factorial = 1
        ;; while p1 > 0
        ;;   factorial *= p1
        ;;   p1 -= 1
        ;; end
        ;; return factorial


        ;; factorial = 1
        i32.const 1
        set_local $factorial

        ;; while p1 > 0
        loop $while_p1_gt_0
            get_local $p1
            i32.const 0
            i32.gt_s
            if
                ;; factorial *= p1
                get_local $factorial
                get_local $p1
                i32.mul
                set_local $factorial

                ;; p1 -= 1
                get_local $p1
                i32.const 1
                i32.sub
                set_local $p1

                ;; back to top of loop
                br $while_p1_gt_0
            end
        end

        ;; return factorial
        get_local $factorial
    )
    (export "factorial" (func $factorial))
)