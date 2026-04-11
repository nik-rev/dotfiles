use chrono::Local;
use iced::widget::{container, text};
use iced::{Color, Element, Length, Subscription, Theme};
use iced_layershell::Application;
use iced_layershell::reexport::Anchor;
use iced_layershell::settings::{LayerShellSettings, Settings};
use std::time::Duration;

pub fn main() {
    let settings = Settings {
        layer_settings: LayerShellSettings {
            size: Some((36, 18)),
            anchor: Anchor::Bottom | Anchor::Right,
            exclusive_zone: -1, // Overlay
            ..Default::default()
        },
        ..Default::default()
    };

    Clock::run(settings).unwrap()
}

impl TryFrom<Message> for iced_layershell::actions::LayershellCustomActions {
    type Error = Message;
    fn try_from(value: Message) -> Result<Self, Self::Error> {
        Err(value)
    }
}

struct Clock {
    time: String,
}

#[derive(Debug, Clone, Copy)]
enum Message {
    Tick,
}

impl Application for Clock {
    type Message = Message;
    type Flags = ();
    type Theme = Theme;
    type Executor = iced::executor::Default;

    fn new(_flags: ()) -> (Self, iced::Task<Message>) {
        (
            Self {
                time: Local::now().format("%H:%M").to_string(),
            },
            iced::Task::none(),
        )
    }

    fn namespace(&self) -> String {
        String::from("Niri Clock")
    }

    fn update(&mut self, message: Message) -> iced::Task<Message> {
        match message {
            Message::Tick => {
                self.time = Local::now().format("%H:%M").to_string();
            }
        }
        iced::Task::none()
    }

    fn view(&self) -> Element<'_, Message> {
        container(text(&self.time).size(12).color(Color::WHITE))
            .width(Length::Fill)
            .height(Length::Fill)
            .center_x(Length::Fill)
            .center_y(Length::Fill)
            .style(|_theme| container::Style {
                background: Some(Color::BLACK.into()),
                ..Default::default()
            })
            .into()
    }

    fn subscription(&self) -> Subscription<Message> {
        iced::time::every(Duration::from_secs(1)).map(|_| Message::Tick)
    }
}
