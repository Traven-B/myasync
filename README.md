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

- `lib/`: Contains the current implementation
- `archive/concurrent_implementations/`: Houses previous versions using different concurrency approaches:
  - `_app_Async_do.rb`: Implementation using `async/http/internet`
  - `_app_async_def.rb`: Version using `async/await` with syntactic sugar
- `lib/local_server.rb`: a sinatra server used when myasync --local is specified

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
