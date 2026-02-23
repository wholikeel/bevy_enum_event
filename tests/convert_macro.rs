use bevy_enum_event::EnumEvent;

#[derive(EnumEvent)]
enum Message {
    Increment,
    Decrement,
}

fn convert_test<T>(_v: T) -> &'static str {
    std::any::type_name::<T>()
}

#[test]
fn test_convert_macro() {
    let msg = Message::Increment;

    let result = convert_message!(convert_test, msg);

    assert!(result.contains("Increment"));

    let result2 = convert_message!(convert_test, Message::Decrement);
    assert!(result2.contains("Decrement"));
}
