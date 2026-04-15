pub mod login_form;
pub mod searcher;

pub enum Screen {
    LoginForm(login_form::Screen),
    Searcher(searcher::Screen),
}
