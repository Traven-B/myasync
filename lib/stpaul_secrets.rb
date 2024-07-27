# This file is tracked in Git. Avoid storing real secrets here if possible.

module StPaul::Secret
  POST_DATA = if ENV.key?("SECRET_STPAUL")
      ENV["SECRET_STPAUL"]
    else
      warn "Warning: Environment variable 'SECRET_STPAUL' is not set. Using default test data."
      "name=fakename&user_pin=1234"
    end

  # To use real data, replace the string above with your actual data:
  # "name=yourname&user_pin=yourpin"
  # Then rename this file and update .gitignore
end

# Usage:
# - For testing: Leave as is, uses default fake data if SECRET_STPAUL is not set
# - For real use: Set SECRET_STPAUL environment variable
# - To hardcode real data:
#   1. Replace the string in the 'else' branch with your real data
#   2. Rename this file (e.g., stpaul_real_secret.rb),
#      the present name (stpaul_secrets.rb) is specifically listed as a committable file name
#   3. Update .gitignore to exclude the new filename
# - Never commit files with real secrets to a public repository
# - If you've ever committed real secrets, even if deleted later, don't make the repository public
