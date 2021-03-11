#[macro_use]
extern crate serde_json;

fn main() {
    let json = json!({
        "hello": "cache!"
    });
    println!("{:?}", json);
}
