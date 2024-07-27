# This file is tracked in Git. Avoid storing real secrets here if possible.

module Hennepin::Secret
  POST_DATA = if ENV.key?("SECRET_HENNEPIN")
      ENV["SECRET_HENNEPIN"]
    else
      warn "Warning: Environment variable 'SECRET_HENNEPIN' is not set. Using default test data."
      "name=fakename&user_pin=1234"
    end

  # To use real data, replace the string above with your actual data:
  # "name=yourname&user_pin=yourpin"
  # Then rename this file and update .gitignore
end

# Usage:
# - For testing: Leave as is, uses default fake data if SECRET_HENNEPIN is not set
# - For real use: Set SECRET_HENNEPIN environment variable
# - To hardcode real data:
#   1. Replace the string in the 'else' branch with your real data
#   2. Rename this file (e.g., hennepin_real_secret.rb),
#      the present name (hennepin_secrets.rb) is specifically listed as a committable file name
#   3. Update .gitignore to exclude the new filename
# - Never commit files with real secrets to a public repository
# - If you've ever committed real secrets, even if deleted later, don't make the repository public
