+++
title = "Rocket for Djangonauts 01"
draft = true
+++

# Rocket for Djangonauts 01

## Hello World

Rocket is a web framework for Rust that is great for building fast and
safe web applications. In this series, we'll do as much of the Django
polls tutorial as possible using Rust and Rocket. We'll also be using
Diesel for database access.

## Prerequisites

The first thing you need to do is install Rust. You can do this by
visiting rustup.rs and following the instructions there. Once you have
Rust installed, we can create a new project.

## Creating a new project

To create a new project, we'll use the `cargo` command. `cargo` is kind
of like `pip` for Python or `npm` for Node.js. It's the package manager
for Rust but, like `npm`, it also runs tasks and commands for you. Since
our project is going to mimic the polls tutorial, we'll name it `polls`.

```sh
cargo new polls
```

You should now have a new directory named `polls` with the following
files in it:

```text
polls
├── Cargo.toml
└── src
    └── main.rs
```

The `Cargo.toml` file is where you define your project's dependencies
and other configuration directives. The `src/main.rs` file is where your
project's main code will go. This is the file that Rust will use as the
main entry point to your program. If you open up this file, it's pretty
barebones at the moment:

```rust
fn main() {
    println!("Hello, world!");
}
```

If you run this program with `cargo run`, you should see `Hello, world!`
printed out in your terminal. As a first step with Rust, go ahead and
change the string and then recompile and run your code with `cargo run`
again. You should see your new string printed out.

## Dependencies

Our first and primary dependency is our web framework, Rocket. We'll go
ahead and add it to our requirements by running `cargo add rocket`. This
will add the newest version of Rocket to our `Cargo.toml` file. If you
open the file, you should see something like this:

```toml
[dependencies]
rocket = "0.5.1"
```

This is the version I'll be using for the tutorial, so if yours is
newer, you might have to adjust your code accordingly. You'll find all
of Rocket's documentation on its website at rocket.rs.

## Hello, Rocket

Now that we have Rocket installed, we can run our server and see it in
action. We'll start by replacing what's in `main.rs` with the following:

```rust
#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, Rocket!"
}
```

Let's walk through this code real quick. At the top, in the
`#[marco_use]` line, we're telling Rust that it's OK to use the macros
defined in the `rocket` crate. The `#[get("/")]` line is one of those
Rocket macros (macros are kind of like decorators in Python). This macro
shows that our `index` function will be called when a `GET` request is
made to the `/` endpoint. The `index` function itself is pretty simple.
It returns a string slice that says `"Hello Rocket!"`. It returns this
as a `&'static str`, which is a string that is stored and available for
the entire run of the program. `'static` is what tells it to last for so
long.

String slices and lifetimes are a bit of a complex topic in Rust, so I'm
going to do my best to avoid them for this tutorial. Once you're more
comfortable with Rust (more comfortable than I am, at least), you're
welcome to update this code to better use Rust's memory safety features.

To run this code, you can use `cargo run`. You should see Rocket start
up with a bunch of output about things like "shields" and "fairings".
Don't worry about what those items are for now. So long as you see
something like:

```sh
📬 Routes:
   >> (index) GET /
```

you're good to go. You can now open up your browser and navigate to
`127.0.0.1:8000` to see your "Hello, Rocket!" message.
