# myasync

myasync is a command line program written in [Ruby][] that scrapes web
pages from public library websites. It uses CSS selector rules to parse the
pages and lists checked-out books and books on hold ready for pickup.

The program uses Ruby's concurrency support to handle multiple HTTP requests
simultaneously. It is modular, allowing you to define modules for different
library websites and customize the scraping logic for each.


## Setting Up the Project

1. **Clone the Repository**:
   ```bash
   git clone --depth 1 https://github.com/Traven-B/myasync.git
   cd myasync
   ```

2. **Install Dependencies**:

   Ensure you have Bundler installed:
   ```bash
   which bundle
   ```

   If not found:
   ```bash
   gem install bundler
   ```

   Configure Bundler to install gems locally:
   ```bash
   bundle config set --local path vendor/bundle
   ```

   to create a `.bundle/config` file with instruction to install gems in project directory.
   ```
   ---
   BUNDLE_PATH: "vendor/bundle"
   ```

   Install the required gems:
   ```bash
   bundle install
   ```

3. **Run the Application**:
   Use `bundle exec` to ensure the correct gem versions are used:

   ```bash
   bundle exec ruby app/mymodest --mock
   ```

## Usage

```sh
app/myasync -h
Usage: myasync [OPTIONS]
Scrape pages at public libraries' web sites.
    -m, --mock                       this option mocks everything
    -s, --sleep-range 2,2.2          1 (or 2) comma separated numbers specifying
                                     (range of) seconds that mocked requests sleep
    -l, --local                      use server on localhost
    -t, --trace                      trace where it's all happening
    -h, --help, --usage              Show this message
```

Example program output:

```sh
Hennepin Books Out

The Astronomer
Tuesday December 04, 2018

Subterranean Twin Cities
Wednesday December 05, 2018
Renewed: 1 time
2 people waiting

Hennepin Books on Hold

A History of America in Ten Strikes
Wednesday November 14, 2018

St. Paul Books Out

St. Paul Books on Hold

The mysterious flame of Queen Loana
Saturday November 17, 2018
```

## Project Structure

- `lib/`: Contains the main code using the Faraday HTTP gem - a more adaptable but involved implementation.
    - `application.rb` (symlink): Points to one of the two async implementations below.
    - `_app_Async_do.rb`: Implementation using `Async do ... end` blocks within a method.
    - `_app_async_def.rb`: Version using `async/await` with syntactic sugar.
- `archive/`: Contains earlier code using the `async/http/internet` gem.
    - A similar setup with two different async idioms is present there as well.
- `use_async_method_or_block.sh`: Script to switch which async implementation is active by updating the `application.rb` symlink.
- `lib/local_server.rb`: Sinatra server used when `myasync --local` is specified.

> **Note:** The active async implementation is controlled by the `application.rb` symlink. Use the provided script to switch between versions as needed.

## Switching Async Implementations

To choose which async implementation is active, use:

```

./use_async_method_or_block.sh async_def    \# Use async/await version
./use_async_method_or_block.sh Async_do     \# Use Async do ... end version

```

Running the script with no arguments reports which version is currently active.

> **Note on Git and symlinks:**
> Git tracks the symlink’s name and target path (not the contents of the target file). If you switch the symlink to point to a different file, `git status` may show it as modified. You only need to `git add` and commit if you want to record the new target in version control.

## Development

For more information on how to customize this code for your use, please refer to our sister project in the Ruby-like language Crystal.

Please refer to the following documents from the Crystal project for detailed information:

- [Detailed README](https://github.com/Traven-B/mymodern/blob/main/project_docs/DETAILED_README.md) for **detailed installation instructions**, and subsequent setup and usage notes.
- [Project Structure Documentation](https://github.com/Traven-B/mymodern/blob/main/project_docs/PROJECT_STRUCTURE.md) which outlines the specific parts you'll need to adapt or modify to work with your library's website.

## Contributing

1. Fork the repository (<https://github.com/Traven-B/myasync/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Traven-B](https://github.com/Traven-B) Michael Kamb - creator, maintainer

[Ruby]: https://www.ruby-lang.org
