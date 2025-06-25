# racket-emacs-trial-kit

The main purpose of the trial kit is to make it easy to experience
some Racket support in Emacs without having to:

* Change your existing Emacs configuration [1]
* Figure out how to configure Emacs for some Racket support
* Manually fetch certain dependencies

![Demo](racket-emacs-trial-kit-linux.png?raw=true "Demo")

## Requirements

* [emacs](https://emacs.org)
* [git](https://git-scm.com/)
* [racket](https://racket-lang.org)

## What You Get

The Emacs setup provides:

* Racket code handling (e.g. syntax highlighting, indentation, and
  more) via [racket-mode](https://github.com/greghendershott/racket-mode)
* Rainbow delimiters
* Dark theme

Without having to:

* Manually fetch certain dependencies
* Change your existing Emacs configuration
* Figure out how to configure Emacs for some Racket support

## Initial Setup

Initial invocations:

```
git clone https://github.com/sogaiu/racket-emacs-trial-kit
cd racket-emacs-trial-kit
racket retk.rkt
```

The above lines may take some time to complete as there will likely
be:

* multiple git cloning operations
* Emacs-related compilation

There may be some related output to the console or terminal before an
application window for Emacs shows up.

Emacs may display a buffer named `*elpaca-log*`showing some
setup-related activity.  Other buffers likely can be ignored or
dismissed.

Please wait for elpaca's activity to finish.  One can tell once there
are no longer any packages listed.

If you got this far, that should be it regarding setup.

See [here](doc/misc.md) for additional info if there were any issues
with the above sequence.

## Verifying Things Are Working

### Syntax Highlighting

I typically start by opening a `.rkt` file.  This repository contains
`sample.rkt` for this purpose.  Once opened, the lines near the top of
the buffer should be something like:

```racket
#lang racket

;; informal
(+ 1 2) ;; => 3

(define (my-fn x)
  (+ x 2))

(my-fn 1) ;; => 3
```

Before the buffer is fully highlighted, one may see the message:

> Waiting for back end to start...

between the menu bar and the main buffer holding the source code.

After a short wait, the code should be syntax-highlighted.

Note that the menu bar should include menus for `Racket-Hash-Lang` and
`Racket-XP`.

### REPL Support

To verify the REPL support works, do one of:

* `M-x racket-run`
* From the menu bar, select: `Racket-Hash-Lang` -> `Run` -> `in REPL`
* Press `F5` (behavior is slightly different from items above)

A second buffer named `*Racket REPL </>*` should appear with content
like:

```
————— run sample.rkt —————
3
3
1 test passed
sample.rkt>
```

You can type things in that buffer directly, but it's also possible
to "send" expressions or code to it via commands while the
focus is in the source buffer.

To try this out, put point (your cursor) at the end of `(+ 1 2)` near
the top of `sample.rkt` and do one of:

* `M-x racket-send-last-sexp`
* `C-x C-e`
* From the menu bar, select: `Racket-Hash-Lang` -> `Eval` -> `Last
  S-Expression`

The content of the `*Racket REPL </>*` buffer should then be like:

```
(+ 1 2) =>
3
sample.rkt>
```

## Typical Use

Start Emacs by:

```
racket retk.rkt
```

## Operating Systems with Confirmed Success

* Android via Termux (`clang` as `cc`, `racket` built from source)
* Void Linux

## Footnotes

[1] One of the new features of Emacs 29.1 is being able to start it up
using different information for intitialization.  If invoked with
`--init-directory=<some-dir>`, `<some-dir>` is sort of like another
`.emacs.d`.  This is the mechanism used by the code in this repository
to provide the feature of "not interfering with your existing Emacs
setup".

