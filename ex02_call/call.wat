(module
    (func $add (param $p1 i32) (param $p2 i32) (result i32)
        get_local $p1
        get_local $p2
        i32.add)
    (func $mul (param $p1 i32) (param $p2 i32) (result i32)
        get_local $p1
        get_local $p2
        i32.mul)
    (func $calc (param $p1 i32) (param $p2 i32) (param $p3 i32) (result i32)
        get_local $p1
        get_local $p2
        call $add
        get_local $p3
        call $mul)
    (export "calc" (func $calc))
)