fn main() {
    println!("cargo:rustc-link-arg-bin=hello-rust=-T../../platforms/virt.ld");
 }
