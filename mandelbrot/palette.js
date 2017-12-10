
/**
 * module used to create color palettes
 * useful for rendering mandelbrot set images.
 */
const Palette = (function() {
    const exports = {};

    /**
    ** @public
    ** create a randomish palette.
    ** this will create a different palette on each call
    ** and between each run.
    **
    ** @param max int palette size (and max mandelbrot iterations)
    ** @return int[] array of max palette entries
    */
    exports.randomPalette = function (max) {
        const palette = [];
        for(let i = 0; i < max; i += 1) {
            const r = Math.floor(Math.random() * 256);
            const g = Math.floor(Math.random() * 256);
            const b = Math.floor(Math.random() * 256);
            palette.push("#" + ("000000" + (r * 256 * 256 + g * 256 + b).toString(16)).slice(-6));
        }

        return palette;
    }

    /**
     * @private
     * 
     * generate a fixed series of random-ish numbers.
     * We do this so we always get the same 'random' palette.
     *
     * @return float 0 .. 1.0 
    */
    function randomSequence(seed){
        if(typeof seed == undefined) seed = 1;
        return function() {
            let x = Math.sin(seed++) * 10000;
            return x - Math.floor(x);
        }
    };

    /**
    ** @public
    ** create a random-ish palette that is the same of each run.
    **
    ** @param max int palette size (and max mandelbrot iterations)
    ** @return int[] array of max palette entries
    */
    exports.fixedRandomPalette = function (max) {
        const random = randomSequence(3);
        const palette = [];
        for(let i = 0; i < max; i += 1) {
            const r = Math.floor(random() * 256);
            const g = Math.floor(random() * 256);
            const b = Math.floor(random() * 256);
            palette.push("#" + ("000000" + (r * 256 * 256 + g * 256 + b).toString(16)).slice(-6));
        }

        return palette;
    }


    /**
    ** @private
    ** calculate a color for the given mandelbrot n
    **
    ** @param n mandelbrot escape iteration
    ** @param offset arbitratry offset
    ** @param scale arbitrary scaling value
    */
    function color(n, offset, scale) {
        n = ((n * scale) + offset) % 1024;
        if (n < 256) {
            return n;
        } else if (n < 512) {
            return 255 - (n - 255);
        } else {
            return 0;
        }
    }


    /**
     * @public
     * create a nice looking mandelbrot palette 
     *
     * @param max int palette size (and max mandelbrot iterations)
     * @return int[] array of max palette entries
     */
    exports.mandelbrotPalette = function (max) {
        const palette = [];
        for(let i = 0; i < max; i += 1) {
            const r = color(i, 128, 4);
            const g = color(i, 0, 4);
            const b = color(i, 356, 4);
            // palette.push("#" + ("000000" + (r * 256 * 256 + g * 256 + b).toString(16)).slice(-6));
            // palette.push("#" + ("000000" + (r << 16 | g << 8 | b).toString(16)).slice(-6));
            // palette.push("#" + ("000000" + (b | ((g | (r << 8)) << 8)).toString(16)).slice(-6));
            palette.push("rgba(" + r + "," + g + "," + b + ",255)")
                        
        }

        return palette;
    }

    return exports;

})();
