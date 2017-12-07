(module
    (func $max (param $p1 i32) (param $p2 i32) (result i32)
        get_local $p1       ;; push $p1 onto value stack
        get_local $p2       ;; push $p2 onto value stack
        i32.gt_s            ;; push ($p1 > $p2) ? 1 : 0
        if (result i32)     ;; pop condidtion; if condition != 0 then
            get_local $p1   ;; push result as $p1
        else                ;; condition == 0
            get_local $p2   ;; push result as $p2
        end
        ;; implicit return of i32 at top of value stack
    )
    (export "max" (func $max))
)