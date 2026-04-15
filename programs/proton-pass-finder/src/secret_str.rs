use core::str::FromStr;
use derive_more::FromStr;
use secrecy::ExposeSecret;
use serde::Deserialize;

#[secret(str)]
pub struct VaultName;

#[secret(str)]
pub struct VaultId;

#[secret(str)]
pub struct ShareId;

#[secret(str)]
pub struct ItemTitle;

#[secret(str)]
pub struct ItemLoginEmail;

#[secret(str)]
pub struct ItemLoginUsername;

#[secret(str)]
pub struct ItemLoginPassword;

#[secret(str)]
pub struct Username;

#[secret(str)]
pub struct Password;

macro_rules! secret {
    attr(str) ($vis:vis struct $Struct:ident;) => {
        #[derive(Debug, Clone, Deserialize, FromStr, Default)]
        $vis struct $Struct(SecretString);

        impl $Struct {
            pub fn new(s: String) -> Self {
                Self(s.into())
            }
        }

        impl ExposeSecret<str> for $Struct {
            fn expose_secret(&self) -> &str {
                self.0.expose_secret()
            }
        }
    };
}
use secret;

#[derive(Debug, Default, Deserialize)]
pub struct SecretString(secrecy::SecretString);

impl From<String> for SecretString {
    fn from(value: String) -> Self {
        Self(value.into())
    }
}

impl FromStr for SecretString {
    type Err = !;

    fn from_str(s: &str) -> std::result::Result<Self, Self::Err> {
        Ok(Self(s.to_string().into()))
    }
}

impl ExposeSecret<str> for SecretString {
    fn expose_secret(&self) -> &str {
        self.0.expose_secret()
    }
}

impl Clone for SecretString {
    fn clone(&self) -> Self {
        Self(self.0.expose_secret().into())
    }
}
