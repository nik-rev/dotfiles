use iced::{Element, Task};
use secrecy::ExposeSecret as _;

use crate::secret_str::{Password, Username};

#[derive(Debug, Clone)]
pub enum Message {
    UsernameChanged(Username),
    PasswordChanged(Password),
    TryLogin,
}

#[derive(Default)]
pub struct Screen {
    username: Username,
    password: Password,
}

impl Screen {
    pub fn update(&mut self, message: Message) -> Task<crate::Message> {
        match message {
            Message::UsernameChanged(username) => {
                self.username = username;
            }
            Message::PasswordChanged(password) => {
                self.password = password;
            }
            Message::TryLogin => {
                let _ = crate::login(&self.username, &self.password);
            }
        }

        Task::none()
    }

    pub fn view(&self) -> Element<'_, crate::Message> {
        iced::widget::column![
            iced::widget::text_input("username", self.username.expose_secret())
                .secure(true)
                .on_input(
                    |username| crate::Message::LoginForm(Message::UsernameChanged(Username::new(
                        username
                    )))
                ),
            iced::widget::text_input("password", self.password.expose_secret())
                .secure(true)
                .on_input(
                    |password| crate::Message::LoginForm(Message::PasswordChanged(Password::new(
                        password
                    )))
                )
                .on_submit(crate::Message::LoginForm(Message::TryLogin)),
        ]
        .into()
    }
}
