# wasm_foo
wasm experiments

The `mandelbrot` folder contains a number of attempts at a mandelbrot drawing program with the intent being to see if we can draw more quickly to a canvas using wasm.  The wasm implementations are written in WAT, the Web Assembly Text format; so they are hand-written web assembly, not generated from a higher level language.

[mandelbrot.html](https://ezward.github.io/wasm_foo/mandelbrot/mandelbrot.html) is a pure JavaScript implementation.  The key method calculates the number of iterations of the Mandelbrot algorithm for a single pixel in the canvas.  It looks like this:
```javascript
    /*
    ** calculate the mandelbrot value for the given
    ** coordinate on the mandelbrot plane 
    **
    ** @param mx float horizontal coord -1.0 <= mx <= 1.0
    ** @param mx float vertical coord -2.5 <= my <= 1.0
    ** @param max int maximum iterations
    ** @return int number of iterations of algorithm (0 <= n <= max)
    */
    function mandelbrot(mx, my, max) {
        //
        // calculate to convergence or max 1000 iterations
        //
        let x = 0.0;
        let y = 0.0;
        let n = 0;      // number of iterations
        while((n < max) && (x*x + y*y < 4)) {
            const newx = x*x - y*y + mx;
            y = 2 * x * y + my;
            x = newx;
            n += 1;
        }

        return n;       // color is determined by number of iterations
    }
```

There is an outer loop in JavaScript that calls this function (passed as `mandelbrotFunc`) for each pixel in the canvas.  The color of the pixel is looked up from a palette using the iteration count for that pixel, then that color is used to draw a 1 pixel rectangle on the canvas.  The key part of the outer loop looks like this;
```javascript
    context.clearRect(0, 0, width, height);

    const max = palette.length;   // color is directly determined by number of iterations, so max color is max iterations

    for(let y = 0; y < height; y += 1) {
        //
        // scale pixel into mandelbrot vertical range -1 to 1
        //
        const my = 2.0 * y / height - 1;
        for(let x = 0; x < width; x += 1) {
            //
            // scale pixel coordinate into mandelbrot horizontal scale -2.5 to 1
            //
            const mx = 3.5 * x / width - 2.5;

            const n = mandelbrotFunc(mx, my, max);

            context.fillStyle = (n < max) ? palette[n] : "black";
            context.fillRect(x, y, 1, 1);
        }
    }
```

[mandelbrot.wasm.html](https://ezward.github.io/wasm_foo/mandelbrot/mandelbrot.wasm.html) replaces that JavaScript function with a web assembly function defined in [mandelbrot.wat](mandelbrot/mandelbrot.wat).  It does the same thing; it calculates the number of iterations of the Mandelbrot algorithm for a given pixel on the canvas.  

[mandelbrot.2.wasm.html](https://ezward.github.io/wasm_foo/mandelbrot/mandelbrot.2.wasm.html), rather than returning the number of iterations, calls a drawDot() function imported from the JavaScript to draw the dot.  The drawDot() function does the palette lookup, then draws the one-pixel rectangle.  
>> TODO: the drawDot() function can be sped up considerably by using a closer to capture the the drawing context rather than looking it up on each pixel.

[mandelbrot.3.wasm.html](https://ezward.github.io/wasm_foo/mandelbrot/mandelbrot.3.wasm.html)

[mandelbrot.4.wasm.html](https://ezward.github.io/wasm_foo/mandelbrot/mandelbrot.4.wasm.html)

[Mandelbrot in WASM](https://ezward.github.io/wasm_foo/mandelbrot/index.html)

