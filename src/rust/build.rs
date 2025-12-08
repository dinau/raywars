#[cfg(windows)]
extern crate windres;

use windres::Build;
fn main() {
    Build::new().compile("res/ray.rc").unwrap();
}

#[cfg(not(target_os = "windows"))]
fn main() {
    // Linux/macOS nothing to do
}
