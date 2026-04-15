#![allow(clippy::large_enum_variant)]
#![feature(never_type)]
#![feature(macro_attr)]

use fuzzy_matcher::FuzzyMatcher;

mod secret_str;
use secret_str::*;

#[derive(Debug, Clone, Deserialize)]
struct PassItemOuter {
    share_id: ShareId,
    vault_id: VaultId,
    content: ItemContent,
    state: PassItemState,
    create_time: String,
    modify_time: String,
}

#[derive(Debug, Clone, Deserialize)]
enum PassItemState {
    Active,
    Trashed,
}

#[serde_with::serde_as]
#[derive(Debug, Clone, Deserialize)]
struct ItemContent {
    title: ItemTitle,
    content: PassItem,
    #[serde(default)]
    extra_fields: Vec<ExtraField>,
    #[serde(default)]
    #[serde_as(as = "serde_with::NoneAsEmptyString")]
    note: Option<SecretString>,
    #[serde(default)]
    #[serde_as(as = "serde_with::NoneAsEmptyString")]
    passkeys: Option<SecretString>,
    #[serde(default)]
    flags: Vec<SecretString>,
}

#[derive(Debug, Clone, Deserialize)]
struct ExtraField {
    name: SecretString,
    content: ExtraFieldContent,
}

#[derive(Debug, Clone, Deserialize)]
enum ExtraFieldContent {
    Text(SecretString),
    Hidden(SecretString),
    Timestamp(SecretBox<u32>),
}

#[serde_with::serde_as]
#[derive(Debug, Clone, Deserialize)]
enum PassItem {
    Alias,
    Note,
    Login {
        #[serde(default)]
        #[serde_as(as = "serde_with::NoneAsEmptyString")]
        email: Option<ItemLoginEmail>,
        #[serde(default)]
        #[serde_as(as = "serde_with::NoneAsEmptyString")]
        totp_uri: Option<SecretString>,
        #[serde(default)]
        #[serde_as(as = "serde_with::NoneAsEmptyString")]
        username: Option<ItemLoginUsername>,
        password: ItemLoginPassword,
        #[serde(default)]
        urls: Vec<String>,
    },
    SshKey {
        private_key: SecretString,
        public_key: SecretString,
        #[serde(default)]
        sections: Vec<SecretString>,
    },
    CreditCard {
        cardholder_name: SecretString,
        card_type: SecretString,
        number: SecretString,
        verification_number: SecretString,
        expiration_date: SecretString,
        pin: SecretString,
    },
    Custom {
        #[serde(default)]
        sections: Vec<SecretString>,
    },
}

use std::{process::Command, time::Duration};

use expectrl::Expect;
use eyre::{Result, ensure};
use iced::{
    Color, Element, Length, Subscription, Task, color,
    widget::{column, container, text_input},
};
use iced_layershell::{Application as _, reexport::Anchor};
use itertools::Itertools;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use secrecy::{ExposeSecret, SecretBox};

fn main() {
    let settings = iced_layershell::settings::Settings {
        layer_settings: iced_layershell::settings::LayerShellSettings {
            size: Some((200, 400)),
            anchor: Anchor::Top | Anchor::Left,
            ..Default::default()
        },
        ..Default::default()
    };

    ProtonPassFinder::run(settings).unwrap()
}

impl TryFrom<Message> for iced_layershell::actions::LayershellCustomActions {
    type Error = Message;
    fn try_from(value: Message) -> Result<Self, Self::Error> {
        Err(value)
    }
}

use serde::Deserialize;

struct ProtonPassFinder {
    screen: screen::Screen,
}

mod screen;

#[derive(Debug, Clone)]
enum Message {
    LoginForm(screen::login_form::Message),
    Searcher(screen::searcher::Message),
    Tick,
}

struct SingleItem {
    vault: Vault,
    contents: PassItemOuter,
}

impl iced_layershell::Application for ProtonPassFinder {
    type Message = Message;
    type Flags = ();
    type Theme = iced::Theme;
    type Executor = iced::executor::Default;

    fn new(_flags: ()) -> (Self, iced::Task<Message>) {
        (
            Self {
                screen: get_vaults().map_or_else(
                    |_| screen::Screen::LoginForm(screen::login_form::Screen::default()),
                    |vaults| {
                        let items: Vec<_> = vaults
                            .par_iter()
                            .flat_map(|vault| {
                                get_vault_items(vault)
                                    .expect("failed to get vault item")
                                    .iter()
                                    .map(|item| SingleItem {
                                        vault: vault.clone(),
                                        contents: item.clone(),
                                    })
                                    .collect_vec()
                            })
                            .collect();

                        screen::Screen::Searcher(screen::searcher::Screen {
                            query: "".into(),
                            matcher: fuzzy_matcher::skim::SkimMatcherV2::default(),
                            contents: items,
                        })
                    },
                ),
            },
            Task::none(),
        )
    }

    fn namespace(&self) -> String {
        String::from("proton-pass-finder")
    }

    fn subscription(&self) -> Subscription<Self::Message> {
        iced::time::every(Duration::from_millis(20)).map(|_| Message::Tick)
    }

    fn update(&mut self, message: Message) -> iced::Task<Message> {
        match message {
            Message::LoginForm(message) => {
                let screen::Screen::LoginForm(screen) = &mut self.screen else {
                    return Task::none();
                };
                return screen.update(message);
            }
            Message::Searcher(message) => {
                let screen::Screen::Searcher(screen) = &mut self.screen else {
                    return Task::none();
                };
                return screen.update(message);
            }
            Message::Tick => {
                // do nothing
            }
        };

        iced::Task::none()
    }

    fn view(&self) -> Element<'_, Message> {
        let element = match &self.screen {
            screen::Screen::LoginForm(screen) => screen.view(),
            screen::Screen::Searcher(screen) => screen.view(),
        };

        container(element)
            .width(Length::Fill)
            .height(Length::Fill)
            .center_x(Length::Fill)
            .style(|_theme| container::Style {
                background: Some(Color::BLACK.into()),
                text_color: Some(Color::WHITE),
                ..Default::default()
            })
            .into()
    }
}

/// Login to Proton Pass.
fn login(username: &Username, password: &Password) -> Result<()> {
    let mut cmd = expectrl::spawn("pass-cli login --interactive")?;

    cmd.expect("Enter username: ")?;
    cmd.send_line(username.expose_secret())?;
    cmd.expect("Enter password: ")?;
    cmd.send_line(password.expose_secret())?;
    cmd.expect(expectrl::Eof)?;

    Ok(())
}

#[derive(Debug, Clone, Default, Deserialize)]
struct Vault {
    name: VaultName,
    vault_id: VaultId,
    share_id: ShareId,
}
// pass item list $vault_name --output json

/// Get every single vault
fn get_vaults() -> Result<Vec<Vault>> {
    let output = Command::new("pass-cli")
        .args(["vault", "list", "--output", "json"])
        .output()?;

    ensure!(
        output.status.success(),
        "failed with: {}",
        String::from_utf8(output.stderr).unwrap()
    );

    #[derive(Deserialize)]
    struct Output {
        vaults: Vec<Vault>,
    }

    let output: Output = serde_json::from_slice(&output.stdout)?;

    Ok(output.vaults)
}

/// Get all items for a single vault
fn get_vault_items(vault: &Vault) -> Result<Vec<PassItemOuter>> {
    let output = Command::new("pass-cli")
        .args(["item", "list"])
        .arg(vault.name.expose_secret())
        .args(["--output", "json"])
        .output()?;

    ensure!(
        output.status.success(),
        "failed with: {}",
        String::from_utf8(output.stderr).unwrap()
    );

    #[derive(Deserialize)]
    struct Output {
        items: Vec<PassItemOuter>,
    }

    let output: Output = serde_json::from_slice(&output.stdout)?;

    // println!("{output}");

    Ok(output.items)
}
