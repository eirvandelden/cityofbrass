Loosen the Gemfile rails constraint only if it blocks 8.1.4; run `bundle update rails --conservative`; run tests, lint, and bundler-audit.

Remove the `json >= 2.0` pin (added for Rails 6.1) from the Gemfile, run `bundle update json --conservative`, then run the tests, rubocop and bundler-audit on json 3.x.
