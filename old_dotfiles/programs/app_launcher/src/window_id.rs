use std::sync::atomic::AtomicBool;

/// Represents ID of the main window.
#[derive(Copy, Clone)]
pub struct WindowId {
    /// This is always `Some`, because
    inner: Option<iced::window::Id>,
}

impl WindowId {
    pub fn new() -> Self {
        Self { inner: None }
    }

    pub fn set(&mut self, id: iced::window::Id) {
        static SET: AtomicBool = AtomicBool::new(false);
        if SET.fetch_and(true, std::sync::atomic::Ordering::Relaxed) {
            panic!("cannot set window id again");
        }
        *self = Self { inner: Some(id) };
    }

    pub fn value(self) -> iced::window::Id {
        self.inner.expect("id is always set")
    }
}

impl From<WindowId> for iced::window::Id {
    fn from(value: WindowId) -> Self {
        value.value()
    }
}
