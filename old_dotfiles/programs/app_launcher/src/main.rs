#![feature(default_field_values)]

use std::{collections::HashMap, process::Stdio, time::Duration};

use iced::{
    Color, Length,
    futures::StreamExt,
    widget::{Column, button, container, row, space, text},
};
use ipc_channel::ipc::{IpcOneShotServer, IpcSender};
use itertools::Itertools;

use crate::window_id::WindowId;

mod window_id;

#[derive(serde::Serialize, serde::Deserialize)]
struct PickerOpened;

fn main() {
    // let is_server = std::env::args().next().is_some_and(|it| it == "server");

    // if !is_server {
    //     let a = "lol";

    //     let tx: IpcSender<PickerOpened> = IpcSender::connect(a.to_string()).unwrap();
    //     tx.send(PickerOpened).unwrap();
    // }

    // let (server, token) = IpcOneShotServer::<PickerOpened>::new().unwrap();

    // let (rx, msg) = server.accept().unwrap();

    // let mut a = rx.to_stream();

    // async move { while let Some(xx) = a.next().await {} };

    let theme: fn(&App) -> iced::Theme = |_| {
        iced::Theme::custom(
            "window_theme",
            iced::theme::Palette {
                // This makes the window's background fully transparent.
                background: Color::BLACK.scale_alpha(0.0),
                text: Color::WHITE,
                primary: Color::WHITE,
                success: Color::WHITE,
                warning: Color::WHITE,
                danger: Color::WHITE,
            },
        )
    };

    iced::application(App::new, App::update, App::view)
        .theme(theme)
        .window(iced::window::Settings {
            size: (200.0, 300.0).into(),
            position: iced::window::Position::Centered,
            visible: false,
            resizable: false,
            // This ALLOWS the window to be transparent,
            // but does not necessarily make it so
            transparent: true,
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
    window_id: WindowId,
    visible: bool,
}

#[derive(Clone)]
enum Message {
    OpenWindow(Option<iced::window::Id>),
    Keyboard(iced::keyboard::Event),
    ToggleWindow(std::time::Instant),
    Exit,
    Selected(char),
}

type Task = iced::Task<Message>;

type Element<'a> = iced::Element<'a, Message>;

type Subscription = iced::Subscription<Message>;

impl App {
    fn new() -> (Self, Task) {
        let window_id = iced::window::latest();

        let this = Self {
            window_id: WindowId::new(),
            visible: false, // start off invisible, we don't want the app to show at startup
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
        };

        (this, window_id.map(Message::OpenWindow))
    }

    fn subscription(&self) -> Subscription {
        iced::Subscription::batch([
            iced::keyboard::listen().map(Message::Keyboard),
            iced::time::every(Duration::from_secs(10)).map(Message::ToggleWindow),
        ])
    }

    fn update(&mut self, message: Message) -> Task {
        // iced::window::latest().then(|window| window.unwrap());

        match message {
            Message::OpenWindow(Some(window_id)) => self.window_id.set(window_id),
            Message::ToggleWindow(_) => {
                let is_visible = self.visible;
                self.visible = !self.visible;
                if is_visible {
                    return iced::window::enable_mouse_passthrough(self.window_id.into())
                        .chain(iced::window::gain_focus(self.window_id.into()));
                } else {
                    return iced::window::disable_mouse_passthrough(self.window_id.into());
                }
            }
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
                iced::keyboard::Event::KeyPressed {
                    key: iced::keyboard::Key::Named(iced::keyboard::key::Named::Escape),
                    ..
                } => {
                    return iced::exit();
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
        if !self.visible {
            return container(space::vertical())
                .style(|_| Color::BLACK.scale_alpha(0.0).into())
                .into();
        }

        container(
            Column::from_iter(self.commands.iter().map(|(ch, cmd)| {
                button(row![text(ch), space::horizontal(), text(cmd.name)].width(Length::Fill))
                    .on_press(Message::Selected(*ch))
                    .into()
            }))
            .spacing(18.0),
        )
        .style(|_| container::Style {
            background: Some(Color::BLACK.into()),
            ..Default::default()
        })
        .into()
    }
}
