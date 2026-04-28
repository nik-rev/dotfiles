#![feature(default_field_values)]

use std::{collections::HashMap, process::Stdio};

use iced::{
    Length,
    widget::{Column, button, row, space, text},
};
use itertools::Itertools;

fn main() {
    iced::application(App::new, App::update, App::view)
        .window(iced::window::Settings {
            size: (200.0, 300.0).into(),
            position: iced::window::Position::Centered,
            resizable: false,
            closeable: false,
            minimizable: false,
            decorations: false,
            ..Default::default()
        })
        .subscription(App::subscription)
        .run()
        .unwrap();
}

#[derive(Default, Clone, Copy)]
struct Command {
    name: &'static str,
    args: &'static [&'static str] = &[],
    env: &'static [(&'static str, &'static str)] = &[]
}

struct App {
    /// When this character is pressed, the given command is executed
    commands: HashMap<char, Command>,
}

#[derive(Clone)]
enum Message {
    Keyboard(iced::keyboard::Event),
    Exit,
    Selected(char),
}

type Task = iced::Task<Message>;

type Element<'a> = iced::Element<'a, Message>;

type Subscription = iced::Subscription<Message>;

impl App {
    fn new() -> Self {
        Self {
            commands: HashMap::from_iter(
                [
                    Command {
                        name: cfg_select! {
                            target_family = "windows" => "zed",
                            target_family = "unix" => "zeditor"
                        },
                        ..
                    },
                    Command {
                        name: "glide-bin",
                        ..
                    },
                    Command {
                        name: "kdenlive",
                        env: &[("QT_SCALE_FACTOR", "1.5")],
                        ..
                    },
                    Command { name: "gimp", .. },
                    Command {
                        name: "obs-studio",
                        ..
                    },
                ]
                .into_iter()
                .enumerate()
                .map(|(i, cmd)| (char::from(b'a' + u8::try_from(i).unwrap()), cmd)),
            ),
        }
    }

    fn subscription(&self) -> Subscription {
        iced::keyboard::listen().map(Message::Keyboard)
    }

    fn update(&mut self, message: Message) -> Task {
        match message {
            Message::Keyboard(event) => match event {
                iced::keyboard::Event::KeyPressed {
                    modifiers, text, ..
                } if let Some(text) = &text
                    && modifiers.is_empty()
                    && let Ok(char) = text.chars().exactly_one()
                    && let Some(command) = self.commands.get(&char).cloned() =>
                {
                    return Task::future(async move {
                        let _ = async_process::Command::new(command.name)
                            .args(command.args)
                            .envs(command.env.iter().copied())
                            .stdout(Stdio::null())
                            .stderr(Stdio::null())
                            .spawn();
                        Message::Exit
                    });
                }
                _ => {}
            },
            Message::Exit => {
                return iced::exit();
            }
            Message::Selected(char) if let Some(command) = self.commands.get(&char).cloned() => {
                return Task::future(async move {
                    let _ = async_process::Command::new(command.name)
                        .args(command.args)
                        .envs(command.env.iter().copied())
                        .stdout(Stdio::null())
                        .stderr(Stdio::null())
                        .spawn();
                    Message::Exit
                });
            }
            _ => {}
        }

        Task::none()
    }

    fn view(&self) -> Element<'_> {
        Column::from_iter(self.commands.iter().map(|(ch, cmd)| {
            button(row![text(ch), space::horizontal(), text(cmd.name)].width(Length::Fill))
                .on_press(Message::Selected(*ch))
                .into()
        }))
        .spacing(18.0)
        .into()
    }
}
