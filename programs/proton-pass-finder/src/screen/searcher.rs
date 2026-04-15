use fuzzy_matcher::FuzzyMatcher as _;
use iced::{Element, Length, Task};
use itertools::Itertools as _;
use secrecy::ExposeSecret as _;

use crate::SingleItem;

#[derive(Debug, Clone)]
pub enum Message {
    Query(String),
}

pub struct Screen {
    pub query: String,
    pub contents: Vec<SingleItem>,
    /// The matcher for all items in the list
    pub matcher: fuzzy_matcher::skim::SkimMatcherV2,
}

impl Screen {
    pub fn update(&mut self, message: Message) -> Task<crate::Message> {
        match message {
            Message::Query(query) => {
                self.query = query;
            }
        }
        Task::none()
    }

    pub fn view(&self) -> Element<'_, crate::Message> {
        let v_space = iced::widget::vertical_space().height(Length::Fixed(10.0));

        let elements = self
            .contents
            .iter()
            .filter_map(|item| {
                self.matcher
                    .fuzzy_indices(item.contents.content.title.expose_secret(), &self.query)
                    .map(|x| (item, x))
            })
            .sorted_by_key(|(_item, (score, _indices))| *score)
            .map(|(item, (_score, indices))| {
                let _ = indices;
                let text: &str = item.contents.content.title.expose_secret();

                let mut highlighted = vec![false; text.chars().count()];

                for index in indices {
                    highlighted[index] = true;
                }

                dbg!(&highlighted);

                let spans: Vec<_> = text
                    .chars()
                    .zip_eq(highlighted)
                    .map(|(ch, is_highlighted)| {
                        iced::widget::span(ch)
                            .color_maybe(is_highlighted.then_some(iced::color!(0xff0000)))
                    })
                    .collect();

                let text = iced::widget::rich_text(spans);
                text.into()
            });

        let input = iced::widget::text_input("", &self.query)
            .on_input(|input| crate::Message::Searcher(Message::Query(input)));

        iced::widget::column![input, v_space, iced::widget::column(elements)].into()
    }
}
