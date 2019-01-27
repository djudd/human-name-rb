#![recursion_limit="1024"]

#[macro_use]
extern crate helix;
extern crate human_name;

ruby! {
    class RustHumanNameOption {
        struct {
            option: Option<RustHumanName>
        }

        def initialize(helix, name: String) {
            RustHumanNameOption {
                helix,
                option: human_name::Name::parse(&name).map( |parsed|
                    RustHumanName { helix, underlying: parsed }
                )
            }
        }
    }

    class RustHumanName {
        struct {
            underlying: human_name::Name
        }

        def initialize(_helix) {
            panic!("private")
        }

        def parse_utf8(name: String) -> Option<RustHumanName> {
            RustHumanNameOption::new(name).option
        }

        def surname(&self) -> String {
            self.underlying.surname().to_string()
        }

        def given_name(&self) -> Option<String> {
            self.underlying.given_name().map(|s| s.to_string())
        }

        def initials(&self) -> String {
            self.underlying.initials().to_string()
        }

        def first_initial(&self) -> String {
            self.underlying.first_initial().to_string()
        }

        def middle_initials(&self) -> Option<String> {
            self.underlying.middle_initials().map(|s| s.to_string())
        }

        def middle_names(&self) -> Option<String> {
            self.underlying.middle_name().map(|s| s.to_string())
        }

        def suffix(&self) -> Option<String> {
            self.underlying.suffix().map(|s| s.to_string())
        }

        def display_first_last(&self) -> String {
            self.underlying.display_first_last().to_string()
        }

        def display_full(&self) -> String {
            self.underlying.display_full().to_string()
        }

        def display_initial_surname(&self) -> String {
            self.underlying.display_initial_surname().to_string()
        }

        def goes_by_middle_name(&self) -> bool {
            self.underlying.goes_by_middle_name()
        }

        def length(&self) -> u64 {
            self.underlying.byte_len() as u64
        }

        def consistent_with(&self, other: &RustHumanName) -> bool {
            self.underlying.consistent_with(&other.underlying)
        }

        def matches_slug_or_localpart_utf8(&self, string: String) -> bool {
            self.underlying.matches_slug_or_localpart(&string)
        }

        #[ruby_name = "=="]
        def eq(&self, other: &RustHumanName) -> bool {
            self.consistent_with(other)
        }

        def hash(&self) -> u64 {
            self.underlying.hash
        }

        def inspect(&self) -> String {
            format!("HumanName::Name({})", self.underlying.display_full())
        }
    }
}
